# Home-Lab Documentation  
Lenovo **ThinkCentre M70Q Tiny** (Core i5-10500T · 16 GB RAM · 256 GB NVMe)

> A single-node Proxmox VE lab running **VMs**, **LXC containers**, and a small **k3s** cluster.  
> Goal — self-host as many daily-use services as possible, document everything, and keep it reproducible.

---

## 🚀 Quick Glance

| Layer | Highlights |
|-------|------------|
| **Hypervisor** | Proxmox VE 8 (single node) |
| **LAN** | `192.168.8.0/24` on `vmbr0` (1 GbE) |
| **Lab Overlay** | `192.168.50.0/24` on `vmbr50` (k3s, NAT) |
| **Storage** | NVMe system SSD (250 GB) • 2 TB HDD data pool (media/data) • USB hub: 1 TB HOT (Immich+TM), 1 TB COLD (rsync snapshots) • 2× USB flash for configs |
| **Core Services** | pfSense FW • AdGuard Home • Nginx Proxy Mgr • Prometheus + Grafana + Alertmanager • Jellyfin stack • Immich • SMB share |
| **Helpful Tools** | Glance Startpage • ConvertX • FileBrowser |
| **Automation** | Docker Compose for apps • Proxmox vzdump + rsync backups |
| **Power / UPS** | APC Back-UPS BX1200MI + apcupsd (on‑battery/off‑battery hooks, Telegram notify, Flask JSON API) |

---

## 📂 Repository Layout

```

my-homelab-docs/
├── README.md
├── Network & Infrastructure/
│   ├── adguard-home.md
│   ├── nginx-proxy-manager.md
│   ├── pfsense.md
│   └── proxmox.md
├── helpful-tools/
│   ├── convertx.md
│   ├── glance.md
│   ├── glance.yml
│   └── k3s-cluster.md
├── media-playback/
│   ├── download-automation.md
│   ├── download-automation.yml
│   ├── jellyfin-jellyser.md
│   └── jellyfin-jellyser.yml
├── monitoring-observability/
│   ├── alert-rules.yml
│   ├── grafana.md
│   ├── install_node_exporter.sh
│   ├── prometheus-alertmanager.md
│   └── uptime_kuma.md
└── storage-files/
    ├── filebrowser.md
    ├── filebrowser.yml
    ├── immich.md
    ├── immich.yml
    ├── samba.md
    └── smb.conf


````

## 🔄 Backups & Maintenance

| Item            | Method                                | Frequency |
| --------------- | ------------------------------------- | --------- |
| Proxmox configs | `vzdump` to USB stick A (daily)       | nightly   |
| Proxmox configs | `vzdump` to USB stick B (weekly)      | weekly    |
| LXC / VM disks  | Scheduled vzdump → 2 TB HDD pool      | nightly   |
| Media library   | ZFS snapshots + rsync to external HDD | nightly   |
| Immich DB       | `pg_dump` via cron                    | nightly   |
| Git repo        | Pushed to GitHub (+private mirror)    | on change |
| Immich & TimeMachine (hot→cold) | rsync via systemd timer (03:30) → /mnt/cold | nightly |
| UPS status / battery tests      | apcupsd + exporter + manual test            | monthly |

---

## 🧩 Credits

* **Proxmox VE** – [https://proxmox.com](https://proxmox.com)
* **k3s** – [https://k3s.io](https://k3s.io)
* **Docker & Docker Compose** – [https://docker.com](https://docker.com)
* **Glance** – [https://github.com/glanceapp/glance](https://github.com/glanceapp/glance)
* Inspired by dozens of homelabbers sharing their stacks ❤️


