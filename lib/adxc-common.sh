#!/usr/bin/env bash

# Purpose:
#   Common runtime loading logic for aDXC-GAMA.

ADXC_HOME="${ADXC_HOME:-/opt/adxc}"

if [ -f "$ADXC_HOME/lib/adxc-colors.sh" ]; then
    . "$ADXC_HOME/lib/adxc-colors.sh"
fi

adxc_version() {
    if [ -f "$ADXC_HOME/VERSION" ]; then
        cat "$ADXC_HOME/VERSION"
    else
        echo "unknown"
    fi
}

adxc_hostname() {
    if command -v hostname >/dev/null 2>&1; then
        hostname -s 2>/dev/null || hostname
    elif [ -r /proc/sys/kernel/hostname ]; then
        cat /proc/sys/kernel/hostname
    else
        uname -n 2>/dev/null || echo unknown-host
    fi
}

adxc_user_home() {
    local user_name="$1"
    getent passwd "$user_name" | awk -F: '{print $6}'
}

adxc_load_user_config() {
    ADXC_USER="${USER:-$(id -un)}"
    ADXC_USER_HOME="${HOME:-$(adxc_user_home "$ADXC_USER")}"
    ADXC_RUNTIME_DIR="${ADXC_RUNTIME_DIR:-$ADXC_USER_HOME/.adxc}"

    if [ "$(id -u)" -eq 0 ]; then
        ADXC_ROLE="ADMIN"
    else
        ADXC_ROLE="SUPPORT"
    fi

    ADXC_ACTIVE_PROFILES=""

    if [ -f "$ADXC_RUNTIME_DIR/config" ]; then
        # shellcheck disable=SC1090
        . "$ADXC_RUNTIME_DIR/config"
    fi
}

adxc_require_admin_role() {
    if [ "$(id -u)" -eq 0 ]; then
        return 0
    fi

    case "${ADXC_ROLE:-}" in
        ADMIN|admin|root)
            return 0
            ;;
        *)
            adxc_error "adxc-admin requires ADMIN role"
            exit 1
            ;;
    esac
}

adxc_print_section() {
    local title="$1"
    printf "\n%s\n" "============================================================"
    printf "%s\n" "$title"
    printf "%s\n\n" "============================================================"
}

adxc_safe_name() {
    printf '%s' "$1" | tr -cd 'A-Za-z0-9_.-'
}
