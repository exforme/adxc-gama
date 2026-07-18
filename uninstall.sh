#!/usr/bin/env bash
set -e
DEST_DIR="${ADXC_INSTALL_DIR:-/opt/adxc}"
if [ "$(id -u)" -ne 0 ] && [ "$DEST_DIR" = "/opt/adxc" ]; then
    echo "ERROR: root is required to uninstall from /opt/adxc"
    exit 1
fi
rm -f /usr/local/bin/adxc /usr/local/bin/adxc-help /usr/local/bin/adxc-cmd /usr/local/bin/adxc-admin /usr/local/bin/adxc-miqm-control /usr/local/bin/adxc-miqm-healthcheck
rm -rf "$DEST_DIR"
echo "aDXC-GAMA removed from: $DEST_DIR"
