#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# Enable a user for aDXC-GAMA
# -----------------------------------------------------------------------------
# Standard mode:
#   adxc-enable-user.sh <user>
#
# Force mode:
#   adxc-enable-user.sh --force <user>
#
# Standard mode installs ~/.adxc/activate.sh and prints instructions.
# Force mode also updates the user's shell startup file so aDXC activates on
# every login and displays the activation notification banner.
# -----------------------------------------------------------------------------

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ADXC_ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
ACTIVATE_TEMPLATE="${ADXC_ROOT_DIR}/templates/user-home/adxc-runtime/activate.sh"
FORCE_MODE="NO"
TARGET_USER=""

print_error() {
    printf 'ERROR: %s\n' "$1" >&2
}

print_usage() {
    cat <<USAGE
Usage:
  adxc-enable-user.sh <user>
  adxc-enable-user.sh --force <user>

Examples:
  adxc-enable-user.sh mqm
  adxc-enable-user.sh --force mqm
USAGE
}

require_root() {
    if [[ "$(id -u)" -ne 0 ]]; then
        print_error "User enablement must be executed as root."
        exit 1
    fi
}

parse_arguments() {
    while [[ "${#}" -gt 0 ]]; do
        case "$1" in
            --force)
                FORCE_MODE="YES"
                shift
                ;;
            --help|-h)
                print_usage
                exit 0
                ;;
            *)
                if [[ -z "${TARGET_USER}" ]]; then
                    TARGET_USER="$1"
                else
                    print_error "Unexpected argument: $1"
                    print_usage
                    exit 1
                fi
                shift
                ;;
        esac
    done

    if [[ -z "${TARGET_USER}" ]]; then
        print_error "Missing user name."
        print_usage
        exit 1
    fi
}

resolve_user_home() {
    USER_HOME="$(getent passwd "${TARGET_USER}" | awk -F: '{print $6}')"

    if [[ -z "${USER_HOME}" || ! -d "${USER_HOME}" ]]; then
        print_error "Home directory not found for user ${TARGET_USER}."
        exit 1
    fi
}

install_activation_script() {
    mkdir -p "${USER_HOME}/.adxc"
    cp "${ACTIVATE_TEMPLATE}" "${USER_HOME}/.adxc/activate.sh"

    # Store the installation path for the user session.
    cat > "${USER_HOME}/.adxc/env" <<EOF_ENV
ADXC_HOME="${ADXC_ROOT_DIR}"
EOF_ENV

    chown -R "${TARGET_USER}:${TARGET_USER}" "${USER_HOME}/.adxc" 2>/dev/null || chown -R "${TARGET_USER}" "${USER_HOME}/.adxc"
    chmod 0755 "${USER_HOME}/.adxc"
    chmod 0644 "${USER_HOME}/.adxc/activate.sh" "${USER_HOME}/.adxc/env"
}

ensure_shell_startup_activation() {
    local shell_startup_file="${USER_HOME}/.bashrc"
    local marker_begin="# >>> aDXC-GAMA auto activation >>>"
    local marker_end="# <<< aDXC-GAMA auto activation <<<"

    touch "${shell_startup_file}"

    if grep -qF "${marker_begin}" "${shell_startup_file}"; then
        printf 'aDXC auto activation already exists in %s\n' "${shell_startup_file}"
        return 0
    fi

    cat >> "${shell_startup_file}" <<EOF_BASHRC

${marker_begin}
if [ -f "\${HOME}/.adxc/activate.sh" ]; then
    # aDXC-GAMA force activation: every interactive login shows that aDXC is active.
    source "\${HOME}/.adxc/activate.sh"
fi
${marker_end}
EOF_BASHRC

    chown "${TARGET_USER}:${TARGET_USER}" "${shell_startup_file}" 2>/dev/null || chown "${TARGET_USER}" "${shell_startup_file}"
    chmod 0644 "${shell_startup_file}"
}

print_summary() {
    printf '============================================================\n'
    printf 'aDXC user enablement completed\n'
    printf '============================================================\n'
    printf '\nUser:\n'
    printf '  %s\n' "${TARGET_USER}"
    printf '\nActivation script:\n'
    printf '  %s/.adxc/activate.sh\n' "${USER_HOME}"
    printf '\nForce mode:\n'
    printf '  %s\n' "${FORCE_MODE}"

    if [[ "${FORCE_MODE}" == "YES" ]]; then
        printf '\nShell startup updated:\n'
        printf '  %s/.bashrc\n' "${USER_HOME}"
        printf '\nThe user will see an aDXC ACTIVE notification on login.\n'
    else
        printf '\nUser activation after enablement:\n'
        printf '  source ~/.adxc/activate.sh\n'
        printf '  adxc\n'
    fi
    printf '============================================================\n'
}

main() {
    require_root
    parse_arguments "$@"
    resolve_user_home
    install_activation_script

    if [[ "${FORCE_MODE}" == "YES" ]]; then
        ensure_shell_startup_activation
    fi

    print_summary
}

main "$@"
