#!/usr/bin/env bash

set -e

###############################################################################
# aDXC-GAMA Uninstaller
###############################################################################

DEST="${ADXC_INSTALL_DIR:-/opt/adxc}"
KEEP_USER_RUNTIME="no"

###############################################################################
# Parse Arguments
###############################################################################

for arg in "$@"
do
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

###############################################################################
# Root Check
###############################################################################

if [ "$(id -u)" -ne 0 ]
then
    echo "ERROR: uninstall.sh must be run as root" >&2
    exit 1
fi

###############################################################################
# Remove Application
###############################################################################

if [ -d "$DEST" ]
then
    rm -rf "$DEST"
    echo "aDXC-GAMA removed from $DEST"
else
    echo "aDXC-GAMA is not installed in $DEST"
fi

###############################################################################
# Remove User Runtimes
###############################################################################

if [ "$KEEP_USER_RUNTIME" = "no" ]
then

    #
    # Root runtime
    #
    rm -rf /root/.adxc 2>/dev/null || true

    #
    # Standard user runtimes
    #
    for HOME_DIR in /home/*
    do
        [ -d "$HOME_DIR/.adxc" ] || continue

        rm -rf "$HOME_DIR/.adxc"
    done

    echo "User runtime directories (~/.adxc) were purged."

else

    echo "User runtime directories (~/.adxc) were intentionally preserved."

fi

###############################################################################
# Complete
###############################################################################

echo
echo "Uninstall completed."
