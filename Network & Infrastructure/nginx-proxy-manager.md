# Nginx Proxy Manager

> **Type**: Docker container (running inside LXC 105 `proxy`)  
> **Category**: Network & Infrastructure  
> **Role**: Reverse proxy with built-in SSL (Let’s Encrypt) management

---

## 🧩 Overview

Nginx Proxy Manager (NPM) exposes internal services (e.g., Jellyfin, Immich, Nextcloud) to the public internet over HTTPS.  
It simplifies certificate issuance/renewal and provides a web UI for adding proxy hosts, redirections, 404 pages, and access control lists.

---

## ⚙️ Specifications

| Setting     | Value                          |
|-------------|--------------------------------|
| Container   | `jc21/nginx-proxy-manager:latest` |
| Runtime     | Docker (compose)               |
| Network     | `host` mode                    |
| Ports used  | 80, 443, 81 (admin UI)         |
| Volumes     | `./npm/data`, `./npm/letsencrypt` |
| IPv6        | Disabled via `DISABLE_IPV6=true` |

NPM runs in **host** network mode, so it binds directly to the LXC’s IP (`192.168.*.*`) on ports 80 / 443 / 81.

---

## 🌐 Networking

All public DNS records point to the LXC’s external address.  
Internal services are referenced by their container IP or Docker bridge name (e.g., `jellyfin:8096`).

---

## 📦 Volumes & Persistence

| Host Path              | Container Path            | Purpose                     |
|------------------------|---------------------------|-----------------------------|
| `./npm/data`           | `/data`                   | App data & SQLite DB        |
| `./npm/letsencrypt`    | `/etc/letsencrypt`        | SSL certs & keys            |

Back up both folders to preserve proxy configuration and certificates.

---

## 🚀 Compose File

```yaml
services:
  nginx-proxy-manager:
    image: 'docker.io/jc21/nginx-proxy-manager:latest'
    container_name: nginx-proxy-manager
    network_mode: host
    restart: unless-stopped
    environment:
      - DISABLE_IPV6=true
    volumes:
      - ./npm/data:/data
      - ./npm/letsencrypt:/etc/letsencrypt
```


## 📝 Notes
Use one proxy host per sub-domain (e.g., jellyfin.domain.tld).

For services behind another reverse proxy (e.g., Cloudflare), ensure real client IP headers are forwarded (X-Forwarded-For).

Keep at least one free public sub-domain for the built-in ACME HTTP-01 validation.
