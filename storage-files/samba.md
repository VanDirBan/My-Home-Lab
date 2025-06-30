# Disk (Samba Share)

> **Type**: LXC container (ID 101 `disk`)  
> **Category**: Storage & Files  
> **Role**: Central SMB server exposing shared folders to the LAN

---

## 🧩 Overview
The **disk** container runs a minimal Ubuntu installation with Samba.  
Two directories are exported over SMB so Windows, macOS, and Linux clients can map them as network drives.

---

## ⚙️ Specifications

| Setting       | Value                  |
|---------------|------------------------|
| OS            | Ubuntu (LXC, unprivileged) |
| Service       | Samba (stand-alone)    |
| SMB Version   | Defaults to SMB 3      |
| Network       | LAN only (`192.168.8.0/24`) |
| Access URL    | `\\disk.vanhome.online\` or `\\192.168.8.101\` |

---

## 📂 Shared Folders

| Share Name | Host Path | Purpose                    | Permissions (POSIX) |
|------------|-----------|----------------------------|---------------------|
| **data**   | `/data`   | General storage, media, backups | `0774` (force user/group `van`) |
| **docker** | `/docker` | Compose stacks & configs   | `0774` (force user/group `van`) |

Both shares are **browseable**, **read/write**, and **guest access is disabled**.

---

## 🔐 Security & Access Control

- **Authentication**: `security = user` — each client must authenticate.  
- **Allowed Subnet**: `hosts allow = 192.168.8.0/24`  
- **Denied**: all other networks (`hosts deny = 0.0.0.0/0`)  
- **Effective User**: All file operations run as **`van`** via `force user / force group`.

> Remember to keep the Samba user password in sync with the Linux account  
> (`sudo smbpasswd -a van` when changing).

---

## 🗃️ Backup Considerations

- **On-box snapshots**: handled by Proxmox LXC backups (vzdump).  
- **Off-box copies**: data inside `/data` is duplicated to the main media-server (rclone nightly job).  
- Configuration (`/etc/samba/smb.conf`) is small and included automatically in vzdump archives.

---

## 📝 Notes

- Log files are rotated and capped at **1 MiB** each (`max log size = 1000`).  
- Name resolution prefers broadcast (`name resolve order = bcast host`) so Windows PCs see the server without extra DNS entries.
- If additional shares are needed, copy the `[data]` stanza, adjust `path`, and reload Samba:

```bash
sudo smbcontrol all reload-config
```
