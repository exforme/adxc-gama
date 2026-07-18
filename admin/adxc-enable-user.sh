#!/usr/bin/env bash
set -e
ADXC_HOME="${ADXC_HOME:-/opt/adxc}"
ROLE=SUPPORT
PROFILES=""
FORCE=no
[ "$(id -u)" -eq 0 ] || { echo "ERROR: root is required"; exit 1; }
USER_NAME="${1:-}"
[ -n "$USER_NAME" ] || { echo "Usage: $0 USER [--role ROLE] [--profiles LIST] [--force]"; exit 1; }
shift
while [ $# -gt 0 ]; do
    case "$1" in
        --role) ROLE="$2"; shift 2 ;;
        --profiles|--profile) PROFILES="$2"; shift 2 ;;
        --force) FORCE=yes; shift ;;
        *) echo "Unknown option: $1"; exit 1 ;;
    esac
done
entry="$(getent passwd "$USER_NAME" || true)"
[ -n "$entry" ] || { echo "ERROR: Cannot resolve user: $USER_NAME"; exit 1; }
home="$(printf '%s\n' "$entry" | awk -F: '{print $6}')"
gid="$(printf '%s\n' "$entry" | awk -F: '{print $4}')"
group="$(getent group "$gid" | awk -F: '{print $1}')"
[ -n "$group" ] || group="$USER_NAME"
runtime="$home/.adxc"
[ -d "$runtime" ] && [ "$FORCE" != yes ] && { echo "ERROR: Runtime already exists: $runtime"; exit 1; }
mkdir -p "$runtime"/{profiles,cache,logs,messages}
cat > "$runtime/config" <<EOF
ADXC_HOME="$ADXC_HOME"
ADXC_ROLE="$ROLE"
ADXC_ACTIVE_PROFILES="$PROFILES"
EOF
cat > "$runtime/activate.sh" <<'EOF'
export ADXC_HOME="${ADXC_HOME:-/opt/adxc}"
export PATH="$ADXC_HOME/bin:$PATH"
[ -t 1 ] && command -v adxc >/dev/null 2>&1 && adxc
EOF
profile_file="$home/.bash_profile"
touch "$profile_file"
if ! grep -q '# >>> aDXC-GAMA activation >>>' "$profile_file"; then
cat >> "$profile_file" <<EOF

# >>> aDXC-GAMA activation >>>
[ -f "\$HOME/.adxc/activate.sh" ] && . "\$HOME/.adxc/activate.sh"
# <<< aDXC-GAMA activation <<<
EOF
fi
chown -R "$USER_NAME":"$group" "$runtime" "$profile_file"
chmod 700 "$runtime"
chmod 755 "$runtime/activate.sh"
chmod 600 "$runtime/config"
echo "aDXC enabled for user: $USER_NAME"
