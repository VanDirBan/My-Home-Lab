#!/usr/bin/env bash
set -euo pipefail

LOG=/var/log/backup_immich.log
SRC_IMMICH=/immich
SRC_TM=/time_machine
DST_BASE=/backup

{
  echo "==== $(date '+%F %T') sync start ===="
 # 1.Check
  if ! mountpoint -q "$DST_BASE"; then
    echo "[ERROR] $DST_BASE is not mounted!" >&2
    exit 1
  fi
  # 2.Immich
  rsync -aAXH --delete --info=progress2 \
        "$SRC_IMMICH/"  "$DST_BASE/immich/"

  # 3.Time Machine
  rsync -aAXH --delete --info=progress2 \
        "$SRC_TM/"      "$DST_BASE/time_machine/"

  echo "==== $(date '+%F %T') sync done ===="
} >> "$LOG" 2>&1

sync
