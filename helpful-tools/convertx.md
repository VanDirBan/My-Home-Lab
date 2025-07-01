# ConvertX

> **Type**: LXC container (ID 112 `convertx`)  
> **Category**: Helpful Tools  
> **Role**: Web-based tool for converting files between different formats

---

## 🧩 Overview

**ConvertX** is a lightweight self-hosted file conversion utility.  
It provides a drag-and-drop interface to convert between common document, image, audio, and video formats directly in the browser — without cloud uploads.

Ideal for occasional conversions without relying on external web services.

To create a new Proxmox VE ConvertX LXC, run the command below in the Proxmox VE Shell.
```
bash -c "$(curl -fsSL https://raw.githubusercontent.com/community-scripts/ProxmoxVE/main/ct/convertx.sh)"
```
Location of config file
```
/opt/convertx/.env
```

---

## ⚙️ Specifications

| Setting         | Value                                |
|-----------------|--------------------------------------|
| Access URL      | `http://convertx.vanhome.online`     |
| Port            | `3001/tcp` *(or customized)*         |
| Volumes         | Host-mounted temp folder for uploads |
| Auth            | Not required (LAN only or behind proxy) |
| Restart Policy  | `unless-stopped`                     |

---

## 🔧 Features

- Converts files between:
  - **Documents**: PDF, DOCX, TXT, etc.
  - **Images**: PNG, JPG, WEBP, HEIC, etc.
  - **Audio**: MP3, FLAC, OGG, WAV
  - **Video**: MP4, WEBM, MKV
- Drag & drop UI with progress bar
- Converted files stored temporarily for download
- Fast processing using local CPU (no external API)

---

## 🔐 Access & Security

| Option       | Status |
|--------------|--------|
| LAN access   | ✅     |
| Reverse proxy | ✅ (`convertx.vanhome.online`) |
| HTTPS        | ✅ (via Nginx Proxy Manager) |
| Auth         | ❌ (recommended to protect via HTTP basic auth if exposed) |

---

## 🗃️ Data & Cleanup

- Uploaded and converted files are stored temporarily (in `/tmp` or container-specific volume)
- No persistent storage needed
- Manual cleanup is not required — files auto-expire after conversion session ends

---

## 📝 Notes

- Not designed for batch processing or scripting — UI only  
- Great fallback if native apps fail to open/convert obscure formats  
- Consider adding a file size limit in proxy config if exposed externally

---
