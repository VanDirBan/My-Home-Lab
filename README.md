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
| **Storage** | NVMe system SSD (250 GB) • 1 TB HDD data pool • 2× USB flash for configs |
| **Core Services** | pfSense FW • AdGuard Home • Nginx Proxy Mgr • Prometheus + Grafana + Alertmanager • Jellyfin stack • Immich • SMB share |
| **Helpful Tools** | Glance Startpage • ConvertX • FileBrowser |
| **Automation** | Docker Compose for apps • Proxmox vzdump + rsync backups |

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

*Open the site locally with **`mkdocs serve`** or visit the GitHub Pages link if published.*

---

## 🗺️ High-Level Topology

```mermaid
flowchart TD
  %% LAN
  subgraph LAN ["LAN: 192.168.8.0/24"]
    direction TB
    pfSense[pfSense<br>192.168.8.1]
    adg[AdGuard Home]
    dns[(DNS)]
    proxy[Nginx Proxy Manager<br>proxy.vanhome.online]
    proxmox[Proxmox VE<br>192.168.8.64]

    pfSense --> adg --> dns
    pfSense --> proxy
    pfSense --> proxmox
  end

  %% Proxmox services
  subgraph ProxmoxNode ["Proxmox Node (M70Q)"]
    direction TB
    glance[Glance Dashboard]
    disk[(Disk - SMB Share)]
    media[Jellyfin + Jellyseerr<br>Media Stack]
    dl[qBittorrent + NZBGet<br>Downloaders]
    observ[Grafana + Prometheus<br>Monitoring]
    k3s[(k3s Cluster<br>1 Master + 2 Workers)]
  end

  %% Connections
  proxy -->|HTTPS| glance
  proxy -->|HTTPS| media
  proxy -->|HTTPS| observ
  proxy -->|HTTPS| disk
  proxy -->|HTTPS| dl
  proxmox --> k3s

````

---

## 🔑 Core Categories (Read First)

| Folder                       | What you will find                                                  |
| ---------------------------- | ------------------------------------------------------------------- |
| **network-infrastructure**   | pfSense, AdGuard Home, NPM, Proxmox host, VLAN notes                |
| **monitoring-observability** | Prometheus stack, Grafana dashboards, Uptime Kuma                   |
| **storage-files**            | SMB share, Immich photo hub, FileBrowser                            |
| **media-playback**           | Jellyfin, Jellyseerr, Audiobookshelf                                |
| **media-downloaders**        | qBittorrent, NZBGet, Prowlarr, Sonarr/Radarr/Lidarr/Readarr, Bazarr |
| **helpful-tools**            | Glance dashboard, ConvertX converter, k3s cluster description       |
| **kubernetes**               | Cluster overview + future Helm addons                               |

Each service has its own **Markdown file** with:

* *Overview* – what & why
* *Specs* – image, ports, volumes
* *Access* – URL / credentials / proxy info
* *Backup* – what to include in snapshots
* *Notes* – pitfalls, TODOs, upgrade tips

---

## 🔄 Backups & Maintenance

| Item            | Method                                | Frequency |
| --------------- | ------------------------------------- | --------- |
| Proxmox configs | `vzdump` to USB stick A (daily)       | nightly   |
| Proxmox configs | `vzdump` to USB stick B (weekly)      | weekly    |
| LXC / VM disks  | Scheduled vzdump → 1 TB HDD pool      | nightly   |
| Media library   | ZFS snapshots + rsync to external HDD | nightly   |
| Immich DB       | `pg_dump` via cron                    | nightly   |
| Git repo        | Pushed to GitHub (+private mirror)    | on change |

---

## 🧩 Credits

* **Proxmox VE** – [https://proxmox.com](https://proxmox.com)
* **k3s** – [https://k3s.io](https://k3s.io)
* **Docker & Docker Compose** – [https://docker.com](https://docker.com)
* **Glance** – [https://github.com/glanceapp/glance](https://github.com/glanceapp/glance)
* Inspired by dozens of homelabbers sharing their stacks ❤️


