#!/usr/bin/env bash

set -e

# Purpose:
#   Enable aDXC-GAMA runtime for a local user.
#
# Usage:
#   adxc-enable-user.sh USER --role SUPPORT --force
#   adxc-enable-user.sh USER --role SUPPORT --profiles OS,TQM1,TQM2 --force

ADXC_HOME="${ADXC_HOME:-/opt/adxc}"
ROLE="SUPPORT"
PROFILES=""
FORCE="no"

if [ "$(id -u)" -ne 0 ]; then
    echo "ERROR: root is required"
    exit 1
fi

USER_NAME="${1:-}"
[ -n "$USER_NAME" ] || { echo "Usage: $0 USER [--role ROLE] [--profiles PROFILE_LIST] [--force]"; exit 1; }
shift

while [ $# -gt 0 ]; do
    case "$1" in
        --role) ROLE="$2"; shift 2 ;;
        --profiles|--profile) PROFILES="$2"; shift 2 ;;
        --force) FORCE="yes"; shift ;;
        *) echo "Unknown option: $1"; exit 1 ;;
    esac
done

USER_ENTRY="$(getent passwd "$USER_NAME" || true)"
[ -n "$USER_ENTRY" ] || { echo "ERROR: Cannot resolve user: $USER_NAME"; exit 1; }

USER_HOME="$(printf '%s\n' "$USER_ENTRY" | awk -F: '{print $6}')"
USER_GID="$(printf '%s\n' "$USER_ENTRY" | awk -F: '{print $4}')"
USER_GROUP="$(getent group "$USER_GID" | awk -F: '{print $1}')"
[ -n "$USER_HOME" ] || { echo "ERROR: Cannot resolve home directory for $USER_NAME"; exit 1; }
[ -n "$USER_GROUP" ] || USER_GROUP="$USER_NAME"

RUNTIME_DIR="$USER_HOME/.adxc"

if [ -d "$RUNTIME_DIR" ] && [ "$FORCE" != "yes" ]; then
    echo "ERROR: Runtime already exists: $RUNTIME_DIR"
    echo "Use --force to rebuild."
    exit 1
fi

mkdir -p "$RUNTIME_DIR"/{profiles,cache,logs,messages}

cat > "$RUNTIME_DIR/config" <<EOF
ADXC_HOME="$ADXC_HOME"
ADXC_ROLE="$ROLE"
ADXC_ACTIVE_PROFILES="$PROFILES"
EOF

cat > "$RUNTIME_DIR/activate.sh" <<'EOF'
# aDXC-GAMA user activation
export ADXC_HOME="${ADXC_HOME:-/opt/adxc}"
export PATH="$ADXC_HOME/bin:$PATH"

if [ -t 1 ] && command -v adxc >/dev/null 2>&1; then
    adxc
fi
EOF

PROFILE_FILE="$USER_HOME/.bash_profile"
MARKER_BEGIN="# >>> aDXC-GAMA activation >>>"
MARKER_END="# <<< aDXC-GAMA activation <<<"

if [ ! -f "$PROFILE_FILE" ]; then
    touch "$PROFILE_FILE"
fi

if ! grep -q "$MARKER_BEGIN" "$PROFILE_FILE"; then
    cat >> "$PROFILE_FILE" <<EOF

$MARKER_BEGIN
[ -f "\$HOME/.adxc/activate.sh" ] && . "\$HOME/.adxc/activate.sh"
$MARKER_END
EOF
fi

chown -R "$USER_NAME":"$USER_GROUP" "$RUNTIME_DIR" "$PROFILE_FILE"
chmod 700 "$RUNTIME_DIR"
chmod 755 "$RUNTIME_DIR/activate.sh"
chmod 600 "$RUNTIME_DIR/config"

echo "aDXC enabled for user: $USER_NAME"
echo "Runtime directory: $RUNTIME_DIR"
echo "Role: $ROLE"
if [ -n "$PROFILES" ]; then
    echo "Visible profiles: $PROFILES"
else
    echo "Visible profiles: all enabled framework profiles"
fi
