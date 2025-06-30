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

---

## 🗺️ High-Level Topology

```mermaid
flowchart LR
  %% ───────────────────────────────────────────────
  %% ЛЕВАЯ ЧАСТЬ – k3s-кластер
  %% ───────────────────────────────────────────────
  subgraph k3s_cluster [k3s Cluster]
    direction TB
    k3s-master[Master Node<br/>192.168.50.131]
    k3s-worker1[Worker 1]
    k3s-worker2[Worker 2]
    k3s-master --> k3s-worker1
    k3s-master --> k3s-worker2
  end

  %% ───────────────────────────────────────────────
  %% ЦЕНТР – сервисы Proxmox-ноды
  %% ───────────────────────────────────────────────
  subgraph Proxmox_Node [Proxmox Node Services]
    direction TB
    glance[Glance Startpage]
    media[Jellyfin + Jellyseerr]
    monitor[Grafana + Prometheus]
    files[FileBrowser + Immich]
    secrets[Vaultwarden]
    download[qBittorrent + NZBGet + Indexers]
  end

  %% ───────────────────────────────────────────────
  %% ПРАВАЯ ЧАСТЬ – LAN 192.168.8.0/24
  %% ───────────────────────────────────────────────
  subgraph LAN [LAN 192.168.8.0/24]
    direction TB
    PfSense[pfSense<br/>192.168.8.1]
    proxmox[Proxmox VE<br/>192.168.8.64]
    proxy[Nginx Proxy Mgr<br/>proxy.vanhome.online]
    adg[AdGuard Home<br/>adg.vanhome.online]
    dns((DNS))
    PfSense --> proxmox
    PfSense --> proxy
    PfSense --> adg
    adg --> dns
  end

  %% ───────────────────────────────────────────────
  %% СВЯЗИ МЕЖДУ БЛОКАМИ
  %% ───────────────────────────────────────────────
  proxmox --> k3s-master            
  proxy -- HTTPS --> glance
  proxy -- HTTPS --> media
  proxy -- HTTPS --> monitor
  proxy -- HTTPS --> files
  proxy -- HTTPS --> secrets
  proxy -- HTTPS --> download


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


