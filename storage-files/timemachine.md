# Time Machine over Samba

## Shares & quotas
- Share names: `tm-mac1` (300 GB), `tm-mac2` (300 GB).
- Path on host (HOT disk): `/time_machine/tm-mac1`, `/time_machine/tm-mac2`.
- Client side: macOS creates encrypted sparsebundle by default.

## Samba config snippet (`smb.conf`)
```ini
[tm-mac1]
   path = /time_machine
   valid users = van
   browseable = yes
   writable  = yes
   vfs objects = catia fruit streams_xattr
   fruit:time machine = yes
   fruit:metadata = stream
   ea support = yes
   durable handles = yes
   kernel oplocks = no
   posix locking = no
   # hard quota via filesystem or use 'fruit:time machine max size = 300G' if on Samba 4.17+
