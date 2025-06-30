#!/bin/bash

# Node Exporter version
VERSION="1.9.1"
ARCH="linux-amd64"

# Installation directory
INSTALL_DIR="/opt/node_exporter"

# Root check
if [[ $EUID -ne 0 ]]; then
  echo "Please run this script as root"
  exit 1
fi

# Install dependencies
apt update && apt install -y wget tar

# Download and install
cd /opt || exit 1
wget https://github.com/prometheus/node_exporter/releases/download/v${VERSION}/node_exporter-${VERSION}.${ARCH}.tar.gz
tar -xzf node_exporter-${VERSION}.${ARCH}.tar.gz
mv node_exporter-${VERSION}.${ARCH} node_exporter
rm node_exporter-${VERSION}.${ARCH}.tar.gz

# Create systemd unit
cat <<EOF > /etc/systemd/system/node_exporter.service
[Unit]
Description=Prometheus Node Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=root
ExecStart=${INSTALL_DIR}/node_exporter
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# Start the service
systemctl daemon-reexec
systemctl enable --now node_exporter

# Show service status
systemctl status node_exporter --no-pager
