# APC Back-UPS BX1200MI Integration

## Components
- **Daemon**: apcupsd (USB)
- **Hooks**: `onbattery`, `offbattery`, `doshutdown` (Telegram notify via `/usr/local/bin/notify.sh`)
- **API**: Flask wrapper at `http://<host>:8888/ups/status`
- **Shutdown policy**:
  - `BATTERYLEVEL` / `TIMELEFT` thresholds in `apcupsd.conf`
  - Final command: `/sbin/apcupsd --killpower` (let UPS cut output)

## Files
- `/etc/apcupsd/apcupsd.conf` – main config
- `/etc/apcupsd/{onbattery,offbattery,doshutdown}` – custom scripts
- `/etc/systemd/system/apcupsd-api.service` – Flask JSON API

## Monitoring
- Glance uses template: |
Status: {{ .JSON.String "STATUS" }}
Charge: {{ .JSON.String "BCHARGE" }}
Load: {{ .JSON.String "LOADPCT" }}
Time Left: {{ .JSON.String "TIMELEFT" }}
Line: {{ .JSON.String "LINEV" }}
Batt: {{ .JSON.String "BATTV" }}
