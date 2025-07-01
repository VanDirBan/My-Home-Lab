# Proxmox VE

> **Type**: Bare-metal hypervisor  
> **Category**: Network & Infrastructure  
> **Role**: Hosts all virtual machines and LXC containers in the home lab

---

## 🧩 Overview
Proxmox Virtual Environment (PVE) is the core virtualization platform for the entire home lab.  
It runs directly on hardware and provides both containerized (LXC) and full-VM workloads, managed through the PVE web interface.

---

## 💽 Host Hardware

| Component | Details |
|-----------|---------|
| CPU       | Intel Core i5-10400T (6 cores / 12 threads) |
| RAM       | 16 GB DDR4 |
| Boot Mode | EFI |
| Kernel    | Linux 6.8.12-11-pve (2025-05-22) |
| Proxmox   | pve-manager 8.4.1 (non-production repo enabled) |

---

## 🗄️ Storage Layout

| Device       | Model / Notes              | Size   | Type | Usage |
|--------------|----------------------------|--------|------|-------|
| /dev/nvme0n1 | WD Blue SN580              | 250 GB | NVMe | Boot + VM/LXC disks (LVM) |
| /dev/sda     | WDC WD10SPZX-24Z10         | 1 TB   | HDD  | Extra data pool (ext4) |
| /dev/sdb1    | SanDisk Cruzer Fit (USB)   | 15 GB  | USB  | **Daily Proxmox config backup** |
| /dev/sdc1    | SanDisk Cruzer Fit (USB)   | 16 GB  | USB  | **Weekly Proxmox config backup** |

Snapshots and vzdump backups save to the internal disks; exported config archives are written to the USB sticks above.

---

## 🌐 Networking

| Bridge | Uplink / Ports                  | Purpose                   | IP / Notes |
|--------|---------------------------------|---------------------------|------------|
| vmbr0  | `eno1` (1 GbE)                  | Main LAN bridge          | 192.168.8.66/24&nbsp;(gateway 192.168.8.1) |
| vmbr1  | `enx6c1ff7197899` (2.5 GbE)     | Main WAN bridge           | External IP adress  |
| vmbr50 | *none* (software-only bridge)   | **Kubernetes overlay**    | 192.168.50.1/24 + NAT → LAN |

`vmbr50` enables internal K3s traffic; NAT masquerading rules are added via `post-up`/`post-down` hooks so that 192.168.50.0/24 can reach the main LAN and the internet.

---

## 🔄 Backup & Snapshots

* **Config backups**:  
  * Daily → `/dev/sdb1` (15 GB USB)  
  * Weekly → `/dev/sdc1` (16 GB USB)
* **VM/LXC backups**: scheduled vzdump jobs to the local HDD (`/dev/sda`), retention 7 daily + 4 weekly.
* ZFS replication is **not** configured (single-node setup).

---

## 📝 Templates

| Template | Purpose |
|----------|---------|
| Debian 12 CT | Base for lightweight service containers |
| Ubuntu 24.04 | K3s nodes and GUI testing |

Templates are cloned manually when needed.

---

## 🖥️ System Usage Snapshot

| Resource   | Value |
|------------|-------|
| CPU usage  | ~0.5 % of 12 vCPUs |
| RAM usage  | 5 GiB / 15.3 GiB (≈ 33 %) |
| Disk usage | 149.5 GiB / 219.8 GiB (≈ 68 %) |
| SWAP usage | 54 MiB / 8 GiB (≈ 0.7 %) |
| Uptime     | 216 h + |
