#!/usr/bin/env bash

set -e

# Purpose:
#   Remove framework files from ADXC_INSTALL_DIR.
#
# Notes:
#   User runtime directories under ~/.adxc are not removed.

DEST_DIR="${ADXC_INSTALL_DIR:-/opt/adxc}"

if [ "$(id -u)" -ne 0 ] && [ "$DEST_DIR" = "/opt/adxc" ]; then
    echo "ERROR: root is required to uninstall from /opt/adxc"
    exit 1
fi

rm -f /usr/local/bin/adxc /usr/local/bin/adxc-help /usr/local/bin/adxc-cmd /usr/local/bin/adxc-admin
rm -rf "$DEST_DIR"

echo "aDXC-GAMA removed from: $DEST_DIR"
