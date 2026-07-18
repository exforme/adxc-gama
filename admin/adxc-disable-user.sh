#!/usr/bin/env bash

set -e

# Purpose:
#   Disable aDXC-GAMA runtime for a local user.

KEEP_RUNTIME="no"
USER_NAME="${1:-}"
[ -n "$USER_NAME" ] || { echo "Usage: $0 USER [--keep-user-runtime]"; exit 1; }
shift

while [ $# -gt 0 ]; do
    case "$1" in
        --keep-user-runtime) KEEP_RUNTIME="yes"; shift ;;
        *) echo "Unknown option: $1"; exit 1 ;;
    esac
done

if [ "$(id -u)" -ne 0 ]; then
    echo "ERROR: root is required"
    exit 1
fi

USER_HOME="$(getent passwd "$USER_NAME" | awk -F: '{print $6}')"
[ -n "$USER_HOME" ] || { echo "ERROR: Cannot resolve home directory for $USER_NAME"; exit 1; }

PROFILE_FILE="$USER_HOME/.bash_profile"
RUNTIME_DIR="$USER_HOME/.adxc"

if [ -f "$PROFILE_FILE" ]; then
    sed -i '/# >>> aDXC-GAMA activation >>>/,/# <<< aDXC-GAMA activation <<</d' "$PROFILE_FILE"
fi

if [ "$KEEP_RUNTIME" != "yes" ]; then
    rm -rf "$RUNTIME_DIR"
fi

echo "aDXC disabled for user: $USER_NAME"
