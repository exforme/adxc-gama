#!/usr/bin/env bash
# ==============================================================================
# uninstall.sh - remove aDXC-GAMA framework
# ============================================================================== 
# Usage:
#   ./uninstall.sh
#   ./uninstall.sh --keep-user-runtime
# ============================================================================== 

set -e

DEST_DIR=${ADXC_INSTALL_DIR:-/opt/adxc}
KEEP_USER_RUNTIME="no"

for arg in "$@"; do
    case "$arg" in
        --keep-user-runtime)
            KEEP_USER_RUNTIME="yes"
            ;;
        *)
            echo "Unknown option: $arg"
            exit 1
            ;;
    esac
done

if [ "$(id -u)" -ne 0 ]; then
    echo "ERROR: uninstall.sh must be run as root" >&2
    exit 1
fi

rm -rf "$DEST_DIR"
echo "aDXC-GAMA removed from $DEST_DIR"

if [ "$KEEP_USER_RUNTIME" = "no" ]; then
    rm -rf /root/.adxc 2>/dev/null || true

    for home_dir in /home/*; do
        [ -d "$home_dir/.adxc" ] && rm -rf "$home_dir/.adxc"
    done

    echo "User runtime directories ~/.adxc were purged."
else
    echo "User runtime directories ~/.adxc were intentionally left untouched."
fi
