# pfSense

> **Type**: Virtual Machine (VM 103)  
> **Category**: Network & Infrastructure  
> **Role**: Firewall, router, and DHCP/DNS server for the home lab

---

## 🧩 Overview

pfSense is the core firewall and network gateway in this Proxmox-based home lab.  
It handles:

- WAN/LAN routing
- Firewall rules
- DNS forwarding
- DHCP address allocation
- WireGuard server

It is running as a Proxmox virtual machine with network bridges connected to both WAN and LAN.

---

## ⚙️ Specifications

| Setting   | Value                |
|-----------|----------------------|
| vCPUs     | 4                    |
| RAM       | 2 GB                 |
| Disk      | 20 GB (VirtIO)       |
| NICs      | 2 (vtnet0 - WAN, vtnet1 - LAN) |
| OS        | pfSense CE (latest)  |

---

## 🌐 Networking

| Interface | Purpose | IP Address     | Notes        |
|-----------|---------|----------------|--------------|
| vtnet0    | WAN     | DHCP from ISP  | via bridge   |
| vtnet1    | LAN     | 192.168.8.1/24 | main LAN     |

All other services route outbound traffic through pfSense.

---

## 🔐 Security Features

- Stateful firewall rules
- Port forwarding to reverse proxy (e.g., HTTPS → Nginx Proxy Manager)
- DNS resolver with custom overrides and forwarding to AdGuard Home
- VLAN support (not yet enabled)

---

## 📦 Backups

- Periodic VM snapshots via Proxmox
- XML config exports can be downloaded via Web UI:  
  *Diagnostics > Backup & Restore*


