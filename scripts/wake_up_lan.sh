#!/usr/bin/env bash
# wake-on-lan.sh -- send WoL magic packet to a host by IP
# Usage: wake-on-lan.sh <IP> [IFACE]
set -Eeuo pipefail

err() { echo "[ERROR] $*" >&2; exit 1; }

if [[ -n "${1:-}" ]]; then
  HOST_IP="$1"
else
  read -r -p "Enter target IP: " HOST_IP
  [[ -n "$HOST_IP" ]] || err "IP address was not provided"
fi

IFACE="${2:-}"
MAP_FILE="/etc/wol-hosts"   # format: IP MAC [IFACE]

# -- helpers -------------------------------------------------------------------


need_cmd() {
  command -v "$1" >/dev/null 2>&1 || err "Required command not found: $1"
}

validate_mac() {
  [[ "$1" =~ ^([[:xdigit:]]{2}:){5}[[:xdigit:]]{2}$ ]]
}

# Resolve the outgoing interface for a given IP via the kernel routing table.
get_iface_from_route() {
  ip route get "$1" 2>/dev/null \
    | awk '{ for (i=1;i<=NF;i++) if ($i=="dev") { print $(i+1); exit } }'
}

# Look up a neighbour cache entry only if it is in a usable state.
# Ignores FAILED / INCOMPLETE entries that would produce an invalid MAC.
get_mac_from_neigh() {
  ip neigh show to "$1" 2>/dev/null \
    | awk '/REACHABLE|STALE|DELAY|PROBE|PERMANENT/ {
        for (i=1;i<=NF;i++) if ($i=="lladdr") { print $(i+1); exit }
      }'
}

# Send a single ARP request to populate the neighbour cache.
# Safer than ping: works even when ICMP is filtered on the target.
arp_probe() {
  local ip="$1" iface="$2"
  if command -v arping >/dev/null 2>&1; then
    arping -c 1 -w 1 -I "$iface" "$ip" >/dev/null 2>&1 || true
  fi
}

# Read both MAC and optional IFACE from the static map file in a single pass.
# Outputs MAC on line 1, IFACE (or empty string) on line 2.
lookup_map() {
  local ip="$1" file="$2"
  [[ -r "$file" ]] || { printf '\n\n'; return 0; }
  awk -v ip="$ip" '
    $1 == ip { found=1; print $2; print (NF>=3 ? $3 : ""); exit }
    END       { if (!found) { print ""; print "" } }
  ' "$file"
}

# Retrieve the IPv4 broadcast address for a given interface.
get_broadcast_from_iface() {
  ip -4 addr show dev "$1" 2>/dev/null \
    | awk '/brd/ {
        for (i=1;i<=NF;i++) if ($i=="brd") { print $(i+1); exit }
      }'
}

# -- pre-flight checks ---------------------------------------------------------

need_cmd ip

# Prefer etherwake; fall back to wakeonlan (more widely packaged).
WOL_CMD=""
if   command -v etherwake >/dev/null 2>&1; then WOL_CMD="etherwake"
elif command -v wakeonlan >/dev/null 2>&1; then WOL_CMD="wakeonlan"
else err "Neither etherwake nor wakeonlan is installed."
fi

[[ $EUID -eq 0 ]] || err "Script must be run as root"

# -- interface resolution ------------------------------------------------------

# Read static map once so the file is not parsed multiple times.
map_data="$(lookup_map "$HOST_IP" "$MAP_FILE")"
map_mac="$(  echo "$map_data" | sed -n '1p')"
map_iface="$(echo "$map_data" | sed -n '2p')"

if [[ -z "$IFACE" ]]; then
  IFACE="$(get_iface_from_route "$HOST_IP")"
fi

if [[ -z "$IFACE" ]]; then
  IFACE="$map_iface"
fi

[[ -n "$IFACE" ]] || err "Cannot determine interface for $HOST_IP"

# Verify the interface actually exists on this machine.
ip link show "$IFACE" >/dev/null 2>&1 \
  || err "Interface '$IFACE' does not exist on this host"

# -- MAC resolution ------------------------------------------------------------

# 1. Neighbour cache (REACHABLE / STALE / DELAY / PROBE / PERMANENT states only).
MAC="$(get_mac_from_neigh "$HOST_IP")"

# 2. Active ARP probe -- only if the host might be reachable on the LAN.
if [[ -z "$MAC" ]]; then
  arp_probe "$HOST_IP" "$IFACE"
  MAC="$(get_mac_from_neigh "$HOST_IP")"
fi

# 3. Static map file -- required for sleeping / powered-off hosts.
if [[ -z "$MAC" ]]; then
  MAC="$map_mac"
fi

[[ -n "$MAC" ]] \
  || err "MAC for $HOST_IP not found. Add a static entry to $MAP_FILE for offline hosts."

validate_mac "$MAC" \
  || err "Invalid MAC address resolved: '$MAC'"

# -- send WoL packet -----------------------------------------------------------

echo "[INFO] HOST=$HOST_IP  IFACE=$IFACE  MAC=$MAC  TOOL=$WOL_CMD"
echo "[INFO] Sending WoL magic packet..."

case "$WOL_CMD" in
  etherwake)
    etherwake -i "$IFACE" "$MAC"
    ;;
  wakeonlan)
    BCAST_IP="$(get_broadcast_from_iface "$IFACE")"
    [[ -n "$BCAST_IP" ]] || err "Cannot determine broadcast IP for interface $IFACE"
    wakeonlan -i "$BCAST_IP" "$MAC"
    ;;
esac

echo "[OK] WoL magic packet sent for $HOST_IP ($MAC) via $IFACE"
