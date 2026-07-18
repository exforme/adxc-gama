#!/usr/bin/env bash
set -e; ADXC_HOME=${ADXC_HOME:-/opt/adxc}; . "$ADXC_HOME/lib/adxc-colors.sh"; [ $# -eq 1 ] || { echo "Usage: $0 <user>"; exit 1; }; home=$(getent passwd "$1" | awk -F: '{print $6}'); [ -n "$home" ] || { adxc_error "User not found: $1"; exit 1; }; rm -rf "$home/.adxc"; adxc_ok "aDXC-GAMA runtime removed for user: $1"
