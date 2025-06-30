# AdGuard Home

> **Type**: LXC Container (ID 100)  
> **Category**: Network & Infrastructure  
> **Role**: Network-wide DNS resolver and ad/tracker blocker

---

## 🧩 Overview

AdGuard Home provides DNS-based blocking of ads, trackers, and malicious domains across the entire network.  
It is configured as the primary DNS server for all local clients, either directly or via pfSense DNS forwarding.

---

## ⚙️ Specifications

| Setting   | Value                |
|-----------|----------------------|
| Container | LXC (unprivileged)   |
| vCPUs     | 2                    |
| RAM       | 1024 MB              |
| Storage   | 4 GB                 |
| Hostname  | adguard              |

---

## 🌐 Networking

| Interface | Role     | IP Address     | Notes            |
|-----------|----------|----------------|------------------|
| eth0      | LAN-only | 192.168.*.1/24 | Static IP via Proxmox |

AdGuard listens on port `53` (DNS) and `3000` (Web UI).  
Web UI is accessible at `http://192.168.*.1:3000`.

---

## 📦 Blocking Features

- Built-in DNS filter lists (ads, trackers, malware)
- Custom filtering rules
- Per-device filtering
- Safe search and parental controls (optional)

---
