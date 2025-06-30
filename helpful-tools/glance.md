# Glance (Startpage Dashboard)

> **Type**: Docker container (LXC 110 `glance`)  
> **Category**: Helpful Tools  
> **Role**: Landing-page dashboard with quick search, service monitors, calendar, and server stats

---

## 🧩 Overview
**Glance** gives a single-page overview of the entire home-lab.  
It renders multiple “monitor” widgets that perform HTTP/ICMP checks on internal and external URLs, plus a calendar widget and local/remote server-stats panels.

The dashboard is defined by a single YAML file (`startpage.yml`), so new services can be added or re-ordered in seconds.

---

## ⚙️ Specifications

| Setting         | Value                                  |
|-----------------|----------------------------------------|
| Image           | `glanceapp/glance:latest` *¹*          |
| Port            | `8080/tcp` (proxied to `https://glance.vanhome.online`) |
| Config path     | `./config/startpage.yml` → `/glance/config/startpage.yml` |
| Auth            | None (read-only dashboard)             |
| Restart policy  | `unless-stopped`                       |

> *¹ If you use a different image/tag, edit this line accordingly.*

---

## 🗂️ Widget Layout (excerpt)

| Section (widget title)        | Key Sites Shown                                                     |
|-------------------------------|---------------------------------------------------------------------|
| **Network & Infrastructure**  | AdGuard Home, pfSense, Xiaomi Router, Proxmox, Nginx Proxy Manager |
| **Media – Playback**          | Jellyfin, Jellyseerr, Audiobookshelf                               |
| **Monitoring & Observability**| Grafana, Prometheus, Uptime Kuma                                   |
| **Storage & Files**           | FileBrowser, Immich                                                |
| **Security & Secrets**        | Vaultwarden                                                        |
| **Media – Downloaders**       | qBittorrent, NZBGet                                                |
| **Media – Indexers & Managers**| Prowlarr, Sonarr, Radarr, Lidarr, Readarr, Bazarr                 |
| **Calendar** (side column)    | Monthly view, Monday-first                                         |
| **Server Stats**              | Local LXC stats + remote Proxmox node stats                        |

Each monitor widget refreshes every **1 minute** (`cache: 1m`).

---

## 🔐 Access

- **Public URL:** `https://glance.vanhome.online` (via Nginx Proxy Manager)  
- No login required; if privacy is a concern, enable HTTP auth or restrict by IP/CIDR in the proxy.

---

## 🗃️ Backup & Version Control

- `config/startpage.yml` is checked into Git along with the rest of the documentation repo.  
- Container itself is stateless; only the YAML matters for rebuilds.

---

## 📝 Notes & Tips

1. **Icons** use Simple Icons (`si:`) or Material Design Icons (`mdi:`).  
   Replace/adjust to taste—full list in Glance docs.  
2. The **server-stats** widget supports:  
   - `type: local` — stats for the container’s host  
   - `type: remote` — query `/api/system` endpoint on another Glance-enabled host (here: Proxmox).  
   Make sure the remote server is reachable over HTTPS and its cert is trusted.  
3. To add a new service, copy an existing entry in the proper section and edit `title`, `url`, and `icon`.  
4. For *critical* services you can switch from `monitor` → `monitor-advanced` and enable keyword checks or custom timeouts.  
5. If you notice “red” tiles for LAN-only URLs while off-site, whitelist your VPN subnet in pfSense or expose those sites through Zero-Tier/TAILS-SCALE.

---

