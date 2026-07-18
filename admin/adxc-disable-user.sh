#!/usr/bin/env bash
# ==============================================================================
# adxc-disable-user.sh - remove aDXC runtime for a local user
# ============================================================================== 

set -e

ADXC_HOME=${ADXC_HOME:-/opt/adxc}

# shellcheck source=/dev/null
. "$ADXC_HOME/lib/adxc-colors.sh"

if [ $# -ne 1 ]; then
    echo "Usage: $0 <user>"
    exit 1
fi

user_name="$1"
user_home=$(getent passwd "$user_name" | awk -F: '{ print $6 }')

if [ -z "$user_home" ]; then
    adxc_error "User not found: $user_name"
    exit 1
fi

rm -rf "$user_home/.adxc"
adxc_ok "aDXC-GAMA runtime removed for user: $user_name"
