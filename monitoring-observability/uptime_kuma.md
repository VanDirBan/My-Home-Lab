# Uptime Kuma

> **Type**: Docker container (LXC 107 `uptime`)  
> **Category**: Monitoring & Observability  
> **Role**: Availability monitoring with Telegram alerts

---

## 🧩 Overview

Uptime Kuma monitors the availability of key services in the home lab via ICMP ping to their domain names or IPs.  
It offers simple uptime charts, historical incident tracking, and notification support.

All core services are tracked using public domain entries like `*.vanhome.online`.

To create a new Proxmox VE Uptime Kuma LXC, run the command below in the Proxmox VE Shell.
```
bash -c "$(curl -fsSL https://raw.githubusercontent.com/community-scripts/ProxmoxVE/main/ct/uptimekuma.sh)"
```

---

## ⚙️ Specifications

| Setting      | Value                            |
|--------------|----------------------------------|
| Container    | `louislam/uptime-kuma:latest`    |
| Port         | `3001/tcp`                       |
| Data Path    | `./uptime-kuma/data/`            |
| Access URL   | `http://up.vanhome.online`       |

---

## 🔍 Monitoring Targets

All checks are configured as **Ping (ICMP)** every 15 seconds.  
Here are some of the tracked domains:

- `adg.vanhome.online` — AdGuard Home  
- `bazarr.vanhome.online` — Bazarr  
- `book.vanhome.online` — Audiobookshelf  
- `filebrowser.vanhome.online` — File manager  
- `graf.vanhome.online` — Grafana  
- `immich.vanhome.online` — Photo & video library  
- `jellyfin.vanhome.online` — Media streaming  
- `jellyser.vanhome.online` — Jellyseerr  
- `lidarr.vanhome.online` — Music download automation  
- `prom.vanhome.online` — Prometheus  
- `prowlarr.vanhome.online` — Indexer aggregator  
- `proxmox.vanhome.online` — Hypervisor  
- `proxy.vanhome.online` — Nginx Proxy Manager  
- `qbit.vanhome.online` — qBittorrent  
- `radar.vanhome.online` — Radarr  
- `readarr.vanhome.online` — Readarr  
- `sonar.vanhome.online` — Sonarr  
- `up.vanhome.online` — Uptime Kuma itself  
- `vm.vanhome.online` — Internal tools

> The actual service may run on a different port or container, but Kuma uses the domain to verify network-level availability.

---

## 📢 Telegram Alerts

| Feature       | Configured |
|---------------|------------|
| Bot-based     | ✅ Yes     |
| Chat/channel  | ✅ Yes     |
| Triggers      | Down / Up  |
| Format        | Default Kuma message (Hostname + time) |

All monitors are linked to a global Telegram bot.  
Alerts are triggered when a domain becomes unreachable and cleared when service resumes.

---

## 🔐 Access

- Accessible at: `http://up.vanhome.online`  
- Protected via local credentials or reverse proxy  
- Public access is optionally restricted via Nginx Proxy Manager

---

## 🗃️ Backup

The configuration and monitor history are stored in:

./uptime-kuma/data/

This path is mounted from the host filesystem and included in regular backups.

---

## 📝 Notes

- Uptime Kuma is ideal for **basic liveness checks**
- Does not support advanced metrics (latency percentiles, HTTP headers, etc.)
- For detailed analysis, see Prometheus and Grafana dashboards
