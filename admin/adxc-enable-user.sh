#!/usr/bin/env bash
# ==============================================================================
# adxc-enable-user.sh - enable aDXC runtime for a local user
# ============================================================================== 
# Usage:
#   adxc-enable-user.sh <user> --role support --profiles 'TQM1 TQM2'
#   adxc-enable-user.sh <user> --role admin --force
#
# Tip:
#   User home directory is resolved through getent, not assumed as /home/<user>.
# ============================================================================== 

set -e

ADXC_HOME=${ADXC_HOME:-/opt/adxc}

# shellcheck source=/dev/null
. "$ADXC_HOME/lib/adxc-colors.sh"

usage() {
    echo "Usage: $0 <user> [--role support|operator|advanced|admin] [--profiles 'TQM1 TQM2'] [--force]"
}

if [ $# -lt 1 ]; then
    usage
    exit 1
fi

user_name="$1"
shift

role="support"
profiles=""
force="no"

while [ $# -gt 0 ]; do
    case "$1" in
        --role)
            role="$2"
            shift 2
            ;;
        --profiles)
            profiles="$2"
            shift 2
            ;;
        --force|--forceful)
            force="yes"
            shift
            ;;
        *)
            echo "Unknown option: $1"
            usage
            exit 1
            ;;
    esac
done

user_home=$(getent passwd "$user_name" | awk -F: '{ print $6 }')

if [ -z "$user_home" ]; then
    adxc_error "User not found: $user_name"
    exit 1
fi

runtime_dir="$user_home/.adxc"

if [ -e "$runtime_dir" ] && [ "$force" != "yes" ]; then
    adxc_error "Runtime exists: $runtime_dir. Use --force to refresh."
    exit 1
fi

mkdir -p "$runtime_dir"/{config,profiles,cache,logs,messages}
cp "$ADXC_HOME/templates/user-home/adxc-runtime/activate.sh" "$runtime_dir/activate.sh"

cat > "$runtime_dir/config/user.conf" <<USERCONF
ADXC_ROLE="$role"
ADXC_ACTIVE_PROFILES="$profiles"
USERCONF

chown -R "$user_name":"$(id -gn "$user_name")" "$runtime_dir" 2>/dev/null || true
chmod 700 "$runtime_dir"
chmod 755 "$runtime_dir/activate.sh"

adxc_ok "aDXC-GAMA enabled for user: $user_name"
echo "Runtime directory : $runtime_dir"
echo "Role              : $role"
echo "Assigned profiles : ${profiles:-none}"
echo "Activate          : source ~/.adxc/activate.sh && adxc"
