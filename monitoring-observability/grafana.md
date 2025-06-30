# Grafana

> **Type**: Docker container (shared with Prometheus & Alertmanager in LXC 149 `prom-graf`)  
> **Category**: Monitoring & Observability  
> **Role**: Interactive dashboards for metrics collected by Prometheus

---

## 🧩 Overview

Grafana visualises time-series data from Prometheus and makes it easy to create dashboards for servers, containers and services.  
Version **11.6.0** is used, running on port **3000** inside the same container as Prometheus.

---

## ⚙️ Specifications

| Setting        | Value                           |
|----------------|---------------------------------|
| Image          | `grafana/grafana:11.6.0`        |
| Ports          | `3000/tcp`                      |
| Data directory | `/var/lib/grafana` (Docker volume) |
| Authentication | Local admin user (`admin`)      |

> Default home dashboard is configured under **Administration → General → Default preferences**.

---

## 🔌 Data Sources

| Name        | Type       | URL                      | Details                  |
|-------------|------------|--------------------------|--------------------------|
| Prometheus  | Prometheus | `http://192.168.8.149:9090`  | Default scrape interval 15 s |
| (planned) Loki | Loki | — | To be added for log aggregation |
| Alertmanager | Alertmanager | `http://192.168.8.149:9093` | For silences & alert list |

---

## 📊 Dashboards

| Dashboard                       | Source ID / JSON | Purpose                         |
|---------------------------------|------------------|---------------------------------|
| **Proxmox Node Exporter Full**  | `1860`           | CPU, RAM, disk, temps for host  |
| **Container Overview**          | custom JSON      | Per-container CPU / memory      |
| **FastAPI Service**             | custom JSON      | Latency & throughput (in future)|

Dashboards are stored in the internal SQLite DB (default) and exported as JSON files to `./dashboards/` for backup.

---

## 🔐 Users & Access

| User      | Role    | Notes                     |
|-----------|---------|---------------------------|
| `admin`   | Admin   | Password rotated after first login |
| (optional)| Viewer  | Read-only access for housemates |

---

## 🗃️ Backup

`/var/lib/grafana` is included in the container-level Docker volume backups.  
JSON exports of dashboards and datasource definitions are additionally committed to Git for version control.

---

## 📝 Notes

* Port **3000** is published only inside the LAN via Nginx Proxy Manager (`graf.domain.tld` over HTTPS).  
* Alert list panel is linked to Alertmanager’s web UI (`prom.domain.tld/alerts`).  
* When Loki is added, remember to set `max_entry_size` in `loki-local-config.yaml` to avoid truncation of long log lines.
