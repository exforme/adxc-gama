#!/usr/bin/env bash
set -e; ADXC_HOME=${ADXC_HOME:-/opt/adxc}; . "$ADXC_HOME/lib/adxc-colors.sh"
[ $# -ge 1 ] || { echo "Usage: $0 <user> [--role support|operator|advanced|admin] [--profiles 'TQM1 TQM2'] [--force]"; exit 1; }
user=$1; shift; role=support; profiles=""; force=no
while [ $# -gt 0 ]; do case "$1" in --role) role=$2; shift 2;; --profiles) profiles=$2; shift 2;; --force|--forceful) force=yes; shift;; *) echo "Unknown option: $1"; exit 1;; esac; done
home=$(getent passwd "$user" | awk -F: '{print $6}'); [ -n "$home" ] || { adxc_error "User not found: $user"; exit 1; }; rt="$home/.adxc"; [ ! -e "$rt" ] || [ "$force" = yes ] || { adxc_error "Runtime exists: $rt. Use --force to refresh."; exit 1; }
mkdir -p "$rt"/{config,profiles,cache,logs,messages}; cp "$ADXC_HOME/templates/user-home/adxc-runtime/activate.sh" "$rt/activate.sh"; printf 'ADXC_ROLE="%s"\nADXC_ACTIVE_PROFILES="%s"\n' "$role" "$profiles" > "$rt/config/user.conf"; chown -R "$user":"$(id -gn "$user")" "$rt" 2>/dev/null || true; chmod 700 "$rt"; chmod 755 "$rt/activate.sh"; adxc_ok "aDXC-GAMA enabled for user: $user"; echo "Activate: source ~/.adxc/activate.sh && adxc"
