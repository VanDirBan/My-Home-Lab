#!/usr/bin/env bash
set -Eeuo pipefail

# =============================================================================
# SATA disk health check via smartctl
# =============================================================================

DISKS=("/dev/sda" "/dev/sdb" "/dev/sdc")
LOGFILE="/var/log/disk_check.log"
NOTIFY="/usr/local/bin/notify.sh"
NOTIFY_ON_SUCCESS=0   # 1 — send notification on success, 0 — log only

# -----------------------------------------------------------------------------
# Check log file is writable
# -----------------------------------------------------------------------------
if ! touch "$LOGFILE" 2>/dev/null; then
  echo "FATAL: cannot write to $LOGFILE" >&2
  exit 1
fi

# -----------------------------------------------------------------------------
# Check that the notifier exists and is executable
# -----------------------------------------------------------------------------
if [[ ! -x "$NOTIFY" ]]; then
  echo "WARNING: $NOTIFY not found or not executable — notifications disabled" >> "$LOGFILE"
  NOTIFY=true
fi

# -----------------------------------------------------------------------------
# Unexpected error handler
# -----------------------------------------------------------------------------
on_error() {
  local LINE="$1"
  local CMD="$2"
  local MSG="🔥 check_disks.sh crashed on $(hostname) at $(date '+%F %T') (line $LINE): $CMD"
  echo "[ERROR] $MSG" >> "$LOGFILE"
  "$NOTIFY" "$MSG" >> "$LOGFILE" 2>&1
}
trap 'on_error $LINENO "$BASH_COMMAND"' ERR

# =============================================================================
# Main block
# =============================================================================

TIMESTAMP="$(date '+%F %T')"
ERRORS=()
LOG_ENTRIES=()

echo "=== [$TIMESTAMP] Disk health check on $(hostname) ===" >> "$LOGFILE"

for DISK in "${DISKS[@]}"; do

  # --------------------------------------------------------------------------
  # 1. Check disk availability via smartctl exit code bits:
  #    bit 1 (value 2) — device could not be opened or SMART is not supported
  # --------------------------------------------------------------------------
  SMART_EXIT=0
  smartctl -H "$DISK" &>/dev/null || SMART_EXIT=$?

  if (( SMART_EXIT & 2 )); then
    ERRORS+=("Disk $DISK: smartctl not supported or device not available")
    LOG_ENTRIES+=("[$DISK] ❌ Unable to check SMART status (smartctl exit: $SMART_EXIT)")
    continue
  fi

  # --------------------------------------------------------------------------
  # 2. Read health (-H) and attributes (-A) in a single call
  # --------------------------------------------------------------------------
  SMART_OUT=$(smartctl -A -H "$DISK" 2>&1 || true)

  HEALTH_LINE=$(echo "$SMART_OUT" | grep -i "SMART overall-health self-assessment test result" || true)
  TEMP_VALUE=$(echo  "$SMART_OUT" | awk '/Temperature_Celsius/ { print $NF }' | head -1)

  # --------------------------------------------------------------------------
  # 3. Evaluate the status
  # --------------------------------------------------------------------------
  if [[ -z "$HEALTH_LINE" ]]; then
    ERRORS+=("Disk $DISK: unable to determine health status")
    LOG_ENTRIES+=("[$DISK] ❌ Health status unknown, Temp: ${TEMP_VALUE:-N/A}°C")
  elif ! echo "$HEALTH_LINE" | grep -iq "PASSED"; then
    ERRORS+=("Disk $DISK: health check FAILED — $HEALTH_LINE")
    LOG_ENTRIES+=("[$DISK] ❌ FAILED — $HEALTH_LINE, Temp: ${TEMP_VALUE:-N/A}°C")
  else
    LOG_ENTRIES+=("[$DISK] ✅ OK — $HEALTH_LINE, Temp: ${TEMP_VALUE:-N/A}°C")
  fi

done

# -----------------------------------------------------------------------------
# Write results to log
# -----------------------------------------------------------------------------
for ENTRY in "${LOG_ENTRIES[@]}"; do
  echo "$ENTRY" >> "$LOGFILE"
done

echo "" >> "$LOGFILE"

# -----------------------------------------------------------------------------
# Notifications
# -----------------------------------------------------------------------------
if [[ ${#ERRORS[@]} -gt 0 ]]; then
  MSG="⚠️ Disk health issues on $(hostname) at $TIMESTAMP:"$'\n'"$(printf '%s\n' "${ERRORS[@]}")"
  "$NOTIFY" "$MSG" >> "$LOGFILE" 2>&1 &
elif [[ "$NOTIFY_ON_SUCCESS" -eq 1 ]]; then
  "$NOTIFY" "✅ Disk health check OK on $(hostname) at $TIMESTAMP" >> "$LOGFILE" 2>&1 &
fi
