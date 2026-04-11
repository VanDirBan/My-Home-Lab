#!/usr/bin/env bash
set -Eeuo pipefail
shopt -s nullglob

# =============================================================================
# FULL mirror backup: /mnt/hot -> /mnt/cold/hot-mirror
# Mirrors EVERYTHING from /mnt/hot and stores guest configs separately.
# =============================================================================

LOG=/var/log/run_backup_hot2cold.log

SRC_BASE=/mnt/hot
COLD_MOUNT=/mnt/cold
DST_BASE="$COLD_MOUNT/hot-mirror"
DST_CONFIG="$COLD_MOUNT/hot-mirror-configs"

NOTIFIER=/usr/local/bin/notify.sh

declare -a STOPPED_CTS=()
declare -a STOPPED_VMS=()

# Redirect all output (including code outside the main block) to the log
exec >> "$LOG" 2>&1

log() {
  echo "$*"
}

# -----------------------------------------------------------------------------
# Notifier sanity check
# -----------------------------------------------------------------------------
if [[ ! -x "$NOTIFIER" ]]; then
  log "WARNING: notifier $NOTIFIER not found or not executable — notifications disabled"
  NOTIFIER=true
fi

# -----------------------------------------------------------------------------
# Wait for guest to reach 'stopped' state.
# Should only be called after a forced pct/qm stop, not after graceful shutdown
# (pct/qm shutdown --timeout already blocks until the guest stops or times out).
# -----------------------------------------------------------------------------
wait_ct_stopped() {
  local id=$1
  local max_wait=${2:-30}
  local waited=0

  until pct status "$id" | grep -q stopped; do
    if (( waited >= max_wait )); then
      log "HOST [ERROR]: CT $id did not reach 'stopped' state in ${max_wait}s"
      return 1
    fi
    sleep 2
    waited=$(( waited + 2 ))
  done

  log "HOST: CT $id stopped after ${waited}s"
}

wait_vm_stopped() {
  local id=$1
  local max_wait=${2:-30}
  local waited=0

  until qm status "$id" | grep -q stopped; do
    if (( waited >= max_wait )); then
      log "HOST [ERROR]: VM $id did not reach 'stopped' state in ${max_wait}s"
      return 1
    fi
    sleep 2
    waited=$(( waited + 2 ))
  done

  log "HOST: VM $id stopped after ${waited}s"
}

# -----------------------------------------------------------------------------
# Restart guests that were stopped before the backup
# -----------------------------------------------------------------------------
start_guests_back() {
  local id

  for id in "${STOPPED_CTS[@]+"${STOPPED_CTS[@]}"}"; do
    log "HOST: starting CT $id"
    pct start "$id" || true
  done

  for id in "${STOPPED_VMS[@]+"${STOPPED_VMS[@]}"}"; do
    log "HOST: starting VM $id"
    qm start "$id" || true
  done
}

clear_stopped_lists() {
  STOPPED_CTS=()
  STOPPED_VMS=()
}

# -----------------------------------------------------------------------------
# Error handler.
# IMPORTANT: $exit_code and $line_no are captured in the trap expression itself,
# not inside the function — by the time the function runs, $? may already be reset.
# -----------------------------------------------------------------------------
on_error() {
  local exit_code=$1
  local line_no=$2
  local failed_cmd=$3

  trap - ERR  # Disarm the trap to prevent recursive calls

  local msg="🔥 FULL HOT MIRROR BACKUP ERROR on $(hostname) at $(date '+%F %T') (exit code: $exit_code, line: $line_no)"
  log "ERROR: $msg"
  log "ERROR: failed command: $failed_cmd"

  start_guests_back
  clear_stopped_lists

  if mountpoint -q "$COLD_MOUNT"; then
    log "on_error: unmounting $COLD_MOUNT"
    umount "$COLD_MOUNT" || true
  fi

  $NOTIFIER "$msg" || true

  exit "$exit_code"
}
trap 'on_error "$?" "$LINENO" "$BASH_COMMAND"' ERR

# =============================================================================
# Main
# =============================================================================
log "==== $(date '+%F %T') HOST: start FULL mirror backup ===="

# --------------------------------------------------------------------------
# 1. Mount cold storage
# --------------------------------------------------------------------------
if ! mountpoint -q "$COLD_MOUNT"; then
  log "HOST: mounting $COLD_MOUNT"
  mount "$COLD_MOUNT"
fi

if ! mountpoint -q "$COLD_MOUNT"; then
  log "HOST [ERROR]: $COLD_MOUNT not mounted, abort."
  exit 1
fi

# --------------------------------------------------------------------------
# 2. Verify source path exists
# --------------------------------------------------------------------------
if [[ ! -d "$SRC_BASE" ]]; then
  log "HOST [ERROR]: source path $SRC_BASE not found"
  exit 1
fi

# --------------------------------------------------------------------------
# 3. Check available space
# Approximation: bytes used by SRC minus bytes already used by DST.
# More accurate than comparing against full SRC size on repeated runs,
# since rsync will overwrite existing data rather than add to it.
# --------------------------------------------------------------------------
log "HOST: checking available space on $COLD_MOUNT"

SRC_USED=$(du -sB1 "$SRC_BASE" | awk '{print $1}')
DST_USED=0
if [[ -d "$DST_BASE" ]]; then
  DST_USED=$(du -sB1 "$DST_BASE" | awk '{print $1}')
fi
COLD_FREE=$(df --output=avail -B1 "$COLD_MOUNT" | awk 'NR==2 {print $1}')
NEEDED=$(( SRC_USED > DST_USED ? SRC_USED - DST_USED : 0 ))

log "HOST: space check — src_used=${SRC_USED} B, dst_used=${DST_USED} B, approx_need=${NEEDED} B, free=${COLD_FREE} B"

if (( NEEDED == 0 )); then
  log "HOST: dst already >= src size; rsync will only update changed files"
elif (( NEEDED > COLD_FREE )); then
  log "HOST [ERROR]: not enough space on cold: approx need ${NEEDED} bytes, free ${COLD_FREE} bytes"
  exit 1
fi

# --------------------------------------------------------------------------
# 4. Prepare destination directories
# --------------------------------------------------------------------------
mkdir -p "$DST_BASE"
mkdir -p "$DST_CONFIG/lxc"
mkdir -p "$DST_CONFIG/qemu"

# --------------------------------------------------------------------------
# 5 & 6. Iterate guests in /mnt/hot/images: save configs and stop running ones
# Single pass instead of two separate loops over the same directory.
# --------------------------------------------------------------------------
if [[ ! -d "$SRC_BASE/images" ]]; then
  log "HOST: WARNING — $SRC_BASE/images not found, no guests to process"
else
  log "HOST: processing guests in $SRC_BASE/images (save configs + stop running)"

  for guest_path in "$SRC_BASE"/images/*/; do
    [[ -d "$guest_path" ]] || continue

    id=$(basename "$guest_path")
    [[ "$id" =~ ^[0-9]+$ ]] || continue

    # -- Config backup and shutdown: LXC container --
    if pct config "$id" >/dev/null 2>&1; then
      cp -a "/etc/pve/lxc/$id.conf" "$DST_CONFIG/lxc/$id.conf" \
        && log "HOST: saved LXC config for $id" \
        || log "HOST: WARNING — failed to copy LXC config for $id"

      if pct status "$id" | grep -q running; then
        log "HOST: shutting down CT $id (graceful, timeout 180s)"
        if pct shutdown "$id" --timeout 180; then
          log "HOST: CT $id shut down gracefully"
        else
          log "HOST: graceful shutdown failed for CT $id, forcing stop"
          pct stop "$id"
          wait_ct_stopped "$id" 30
        fi
        STOPPED_CTS+=("$id")
      else
        log "HOST: CT $id already stopped"
      fi

    # -- Config backup and shutdown: QEMU virtual machine --
    elif qm config "$id" >/dev/null 2>&1; then
      cp -a "/etc/pve/qemu-server/$id.conf" "$DST_CONFIG/qemu/$id.conf" \
        && log "HOST: saved QEMU config for $id" \
        || log "HOST: WARNING — failed to copy QEMU config for $id"

      if qm status "$id" | grep -q running; then
        log "HOST: shutting down VM $id (graceful, timeout 180s)"
        if qm shutdown "$id" --timeout 180; then
          log "HOST: VM $id shut down gracefully"
        else
          log "HOST: graceful shutdown failed for VM $id, forcing stop"
          qm stop "$id"
          wait_vm_stopped "$id" 30
        fi
        STOPPED_VMS+=("$id")
      else
        log "HOST: VM $id already stopped"
      fi

    else
      log "HOST: WARNING — ID $id found in images/, but no matching CT/VM config"
    fi
  done
fi

# --------------------------------------------------------------------------
# 7. Mirror entire /mnt/hot to cold storage
# --------------------------------------------------------------------------
log "HOST: rsync full mirror from $SRC_BASE/ to $DST_BASE/"
rsync -aHAXS \
      --numeric-ids \
      --delete \
      --no-whole-file \
      --inplace \
      --human-readable \
      --info=progress2,stats2 \
      "$SRC_BASE/" "$DST_BASE/"

# --------------------------------------------------------------------------
# 8. Flush kernel write buffers
# --------------------------------------------------------------------------
log "HOST: sync (flush)"
sync

# --------------------------------------------------------------------------
# 9. Restart guests that were running before the backup
# --------------------------------------------------------------------------
start_guests_back
clear_stopped_lists

# --------------------------------------------------------------------------
# 10. Unmount cold storage
# --------------------------------------------------------------------------
log "HOST: umount $COLD_MOUNT"
umount "$COLD_MOUNT"

log "==== $(date '+%F %T') HOST: FULL mirror backup finished successfully ===="
