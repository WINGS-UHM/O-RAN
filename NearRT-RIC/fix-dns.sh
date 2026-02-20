#!/usr/bin/env bash
set -euo pipefail

IFACE="${1:-eno1}"
DNS1="${2:-8.8.8.8}"
DNS2="${3:-8.8.4.4}"

echo "[INFO] Ensuring systemd-resolved is enabled..."
sudo systemctl enable --now systemd-resolved

echo "[INFO] Linking resolv.conf to systemd stub..."
sudo ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf

echo "[INFO] Setting DNS servers for interface ${IFACE}..."
sudo resolvectl dns "$IFACE" "$DNS1" "$DNS2"
sudo resolvectl domain "$IFACE" "~."

echo "[INFO] Verifying configuration..."
resolvectl status "$IFACE"

echo "[INFO] Testing resolution..."
getent hosts google.com || true

echo "[INFO] DNS fix complete."
