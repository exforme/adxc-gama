#!/usr/bin/env bash
set -e
USER_NAME="${1:-}"; [ -n "$USER_NAME" ] || { echo "Usage: $0 USER [--keep-user-runtime]"; exit 1; }
KEEP=no; shift || true; [ "${1:-}" = "--keep-user-runtime" ] && KEEP=yes
[ "$(id -u)" -eq 0 ] || { echo "ERROR: root is required"; exit 1; }
home="$(getent passwd "$USER_NAME" | awk -F: '{print $6}')"; [ -n "$home" ] || { echo "ERROR: Cannot resolve home directory"; exit 1; }
[ -f "$home/.bash_profile" ] && sed -i '/# >>> aDXC-GAMA activation >>>/,/# <<< aDXC-GAMA activation <<</d' "$home/.bash_profile"
[ "$KEEP" = yes ] || rm -rf "$home/.adxc"
echo "aDXC disabled for user: $USER_NAME"
