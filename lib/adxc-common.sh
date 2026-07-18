#!/usr/bin/env bash
ADXC_HOME="${ADXC_HOME:-/opt/adxc}"
[ -f "$ADXC_HOME/lib/adxc-colors.sh" ] && . "$ADXC_HOME/lib/adxc-colors.sh"

adxc_version() {
    [ -f "$ADXC_HOME/VERSION" ] && cat "$ADXC_HOME/VERSION" || echo unknown
}

adxc_hostname() {
    hostname -s 2>/dev/null || hostname 2>/dev/null || uname -n 2>/dev/null || echo unknown-host
}

adxc_load_user_config() {
    ADXC_USER="${USER:-$(id -un)}"
    ADXC_USER_HOME="${HOME:-}"
    ADXC_RUNTIME_DIR="${ADXC_RUNTIME_DIR:-$ADXC_USER_HOME/.adxc}"

    if [ "$(id -u)" -eq 0 ]; then
        ADXC_ROLE="ADMIN"
    else
        ADXC_ROLE="SUPPORT"
    fi

    ADXC_ACTIVE_PROFILES=""
    [ -f "$ADXC_RUNTIME_DIR/config" ] && . "$ADXC_RUNTIME_DIR/config"
}

adxc_require_admin_role() {
    [ "$(id -u)" -eq 0 ] && return 0
    case "${ADXC_ROLE:-}" in
        ADMIN|admin|root) return 0 ;;
        *) adxc_error "adxc-admin requires ADMIN role"; exit 1 ;;
    esac
}

adxc_print_section() {
    printf "\n%s\n%s\n%s\n\n" "============================================================" "$1" "============================================================"
}

adxc_safe_name() {
    printf '%s' "$1" | tr -cd 'A-Za-z0-9_.-'
}
