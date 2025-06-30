# FileBrowser

> **Type**: Docker container (LXC 106 `FileBrowser`)  
> **Category**: Storage & Files  
> **Role**: Lightweight web-based file manager

---

## 🧩 Overview

FileBrowser provides a web interface to browse, upload, download, and organize files within the home lab.  
It is used to manage data inside shared volumes and simplify access from desktop or mobile browsers.

---

## ⚙️ Specifications

| Setting      | Value                            |
|--------------|----------------------------------|
| Container    | `filebrowser/filebrowser:latest` |
| Port         | `8080/tcp`                       |
| Access URL   | `https://filebrowser.vanhome.online` |
| Data path    | Host-mounted directory           |

---

## 🗂️ Directory Access

The container is mounted to a host directory that grants access to shared files, logs, and downloads.

```yaml
volumes:
  - /mnt/data:/srv
```
All files appear in the web UI under /srv/.

## 🔐 Access & Permissions
Feature	Status
Authentication	Enabled
Admin UI	Enabled
User Roles	Admin / Read-only
External Access	Restricted via reverse proxy

Users can browse directories, upload/download files, and rename/delete if permissions allow.

## 🔧 Use Cases
Access downloaded files (e.g., media, configs)

Upload .yml, .json, or logs from browser

Temporary sharing with friends or local network users

## 🗃️ Backup
The container itself is stateless. All persistent data is stored in mounted host volumes (/mnt/data).
No special backup for FileBrowser is required — backup the files it accesses.

## 📝 Notes
Reverse proxy is configured via Nginx Proxy Manager under filebrowser.vanhome.online

Use HTTPS + authentication for secure access

Simple and lightweight alternative to full NAS or Samba shares
