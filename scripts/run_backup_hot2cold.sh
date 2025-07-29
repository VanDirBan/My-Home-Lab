#!/usr/bin/env bash
set -euo pipefail

LOG=/var/log/run_backup_hot2cold.log
CTID=101
MOUNT=/mnt/cold
NOTIFIER=/usr/local/bin/notify.sh

on_error() {
  local MSG="HOT→COLD BACKUP ERROR on $(hostname) at $(date '+%F %T')"
  echo "ERROR: $MSG" >> "$LOG"
  $NOTIFIER "$MSG" &
}
trap on_error ERR
{
  echo "==== $(date '+%F %T') HOST: start hot→cold sync ===="

  # 1. Mount cold disk
  if ! mountpoint -q "$MOUNT"; then
    echo "HOST: mounting $MOUNT"
    mount "$MOUNT"
  fi

  if ! mountpoint -q "$MOUNT"; then
    echo "HOST [ERROR]: $MOUNT not mounted, abort." >&2
    exit 1
  fi

  # 2. Run container script
  echo "HOST: executing backup_immich.sh in CT $CTID"
  pct exec $CTID -- /usr/local/sbin/backup_immich.sh

  # 3. Umount
  echo "HOST: umount $MOUNT"
  umount "$MOUNT"

  echo "==== $(date '+%F %T') HOST: backup finished ===="
} >> "$LOG" 2>&1
