# Immich

> **Type**: Docker Stack (LXC 108 `immich`)  
> **Category**: Storage & Files  
> **Role**: Self-hosted photo & video library with AI-powered search and face recognition

---

## 🧩 Overview
Immich stores and serves personal photos and videos, offering mobile/desktop upload, on-device backups, albums, face clustering, object tagging, and fast search.  
The stack contains four services:

| Service                 | Purpose                               | Container Name          |
|-------------------------|---------------------------------------|-------------------------|
| **immich-server**       | REST / WebSocket API & web UI         | `immich_server`         |
| **immich-machine-learning** | Face / object inference pipeline | `immich_machine_learning`|
| **postgres**            | Metadata database (PostgreSQL + pgvector) | `immich_postgres`   |
| **redis**               | Job queue & cache                     | `immich_redis`          |

---

## ⚙️ Key Settings

| Setting        | Value / Variable                   |
|----------------|------------------------------------|
| Stack name     | `immich`                           |
| Public URL     | `https://immich.vanhome.online`    |
| Published port | `2283/tcp` (proxied via NPM)       |
| Upload path    | `${UPLOAD_LOCATION}` → eg. `/data/photos` |
| DB path        | `${DB_DATA_LOCATION}` → eg. `/data/immich-db` |
| Model cache    | Docker volume `model-cache`        |
| Healthchecks   | Enabled for every container        |
| Restart policy | `always`                           |

Environment variables live in `.env`;

---

## 💾 Storage Layout

| Path (host)                           | Mounted In Container              | Description                    |
|---------------------------------------|-----------------------------------|--------------------------------|
| `${UPLOAD_LOCATION}` (e.g. `/data/photos`) | `/usr/src/app/upload` (server) | Original media & thumbnails    |
| `${DB_DATA_LOCATION}` (e.g. `/data/immich-db`) | `/var/lib/postgresql/data` (postgres) | PostgreSQL data               |
| Docker volume `model-cache`           | `/cache` (machine-learning)       | Downloaded ML models           |

Full-resolution files remain untouched; Immich creates resized JPEG/WEBP previews alongside.

---

## 🔐 Access & Auth

| Feature             | Status                |
|---------------------|-----------------------|
| Account system      | Built-in (email / password) |
| OAuth               | Not configured        |
| Reverse proxy       | Nginx Proxy Manager (`immich.vanhome.online`, HTTPS) |
| LAN only?           | Yes, but access via VPN |

---

## 🏎️ Hardware Acceleration (optional)

The stack supports CUDA, QuickSync, VA-API, etc.  
Currently containers run **CPU-only** (`immich-server`, `immich-machine-learning`).  
To enable acceleration, swap image tags (`-cuda`, `-quicksync`, …) and add device passthrough lines in an override compose file.

---

## 🗃️ Backup Strategy

| Component | Method                                      | Frequency |
|-----------|---------------------------------------------|-----------|
| **Photos** (`UPLOAD_LOCATION`) | rsync → HDD + cloud bucket | nightly   |
| **Postgres**                   | `pg_dump` → `/backups/immich.sql` | nightly   |
| Docker volumes                 | Included in Proxmox LXC vzdump     | weekly    |

Ensure media and database snapshots are consistent (pause uploads or use WAL-streaming if required).

---

## 📝 Notes

* Mobile apps (Android / iOS) configured to auto-upload to `immich.vanhome.online`.
* Web-UI accessible at `https://immich.vanhome.online`.
* Redis TTL and worker concurrency default values are kept; tweak via `.env` for heavy loads.
* After major upgrades run `immich migrate` (happens automatically in latest images).

