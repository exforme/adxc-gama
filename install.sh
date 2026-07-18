#!/usr/bin/env bash

set -e

# Purpose:
#   Install aDXC-GAMA into /opt/adxc or ADXC_INSTALL_DIR.
#
# Usage:
#   ./install.sh
#   ADXC_INSTALL_DIR=/some/path ./install.sh

SOURCE_DIR="$(cd "$(dirname "$0")" && pwd)"
DEST_DIR="${ADXC_INSTALL_DIR:-/opt/adxc}"

if [ "$(id -u)" -ne 0 ] && [ "$DEST_DIR" = "/opt/adxc" ]; then
    echo "ERROR: root is required to install into /opt/adxc"
    exit 1
fi

echo "Installing aDXC-GAMA from: $SOURCE_DIR"
echo "Installing aDXC-GAMA to  : $DEST_DIR"

mkdir -p "$DEST_DIR"

for item in VERSION README.md MANIFEST.md bin admin lib messages profiles commands templates uninstall.sh; do
    rm -rf "$DEST_DIR/$item"
    cp -R "$SOURCE_DIR/$item" "$DEST_DIR/$item"
done

find "$DEST_DIR" -type d -exec chmod 755 {} \;
find "$DEST_DIR" -type f -exec chmod 644 {} \;
find "$DEST_DIR/bin" "$DEST_DIR/admin" -type f -exec chmod 755 {} \;
chmod 755 "$DEST_DIR/uninstall.sh"

ln -sf "$DEST_DIR/bin/adxc" /usr/local/bin/adxc
ln -sf "$DEST_DIR/bin/adxc-help" /usr/local/bin/adxc-help
ln -sf "$DEST_DIR/bin/adxc-cmd" /usr/local/bin/adxc-cmd
ln -sf "$DEST_DIR/bin/adxc-admin" /usr/local/bin/adxc-admin

bash -n "$DEST_DIR"/bin/*
bash -n "$DEST_DIR"/admin/*
bash -n "$DEST_DIR"/lib/*.sh

cat <<EOF

Installation complete.

Main commands:
  adxc
  adxc --menu
  adxc <profile>
  adxc-help
  adxc-help --list-all
  adxc-cmd --list
  adxc-admin

Enable user example:
  $DEST_DIR/admin/adxc-enable-user.sh monkey --role SUPPORT --force

EOF
