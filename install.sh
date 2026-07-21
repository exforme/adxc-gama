#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# aDXC-GAMA installer
# -----------------------------------------------------------------------------
# Responsibilities:
#   - validate root execution
#   - validate source package tree
#   - validate shell syntax before installation
#   - backup an existing /opt/adxc installation
#   - install to /opt/adxc by default
#   - enforce root ownership and safe permissions
#   - optionally activate root runtime
#   - print clear post-installation next steps
#
# Usage:
#   ./install.sh
#   ./install.sh /opt/adxc
#   ./install.sh --activate-root
#   ./install.sh /opt/adxc --activate-root
# -----------------------------------------------------------------------------

set -euo pipefail

ADXC_VERSION="0.3.0-rc7"
DEFAULT_INSTALL_DIR="/opt/adxc"
INSTALL_DIR="${DEFAULT_INSTALL_DIR}"
ACTIVATE_ROOT="NO"
SOURCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

print_line() {
    printf '%s\n' '============================================================'
}

print_error() {
    printf 'ERROR: %s\n' "$1" >&2
}

require_root() {
    if [[ "$(id -u)" -ne 0 ]]; then
        print_error "aDXC installation must be executed as root."
        exit 1
    fi
}

parse_arguments() {
    for argument in "$@"; do
        case "${argument}" in
            --activate-root)
                ACTIVATE_ROOT="YES"
                ;;
            --help|-h)
                print_usage
                exit 0
                ;;
            /*)
                INSTALL_DIR="${argument}"
                ;;
            *)
                print_error "Unknown option: ${argument}"
                print_usage
                exit 1
                ;;
        esac
    done
}

print_usage() {
    cat <<USAGE
Usage:
  ./install.sh [install-dir] [--activate-root]

Examples:
  ./install.sh
  ./install.sh /opt/adxc
  ./install.sh /opt/adxc --activate-root
USAGE
}

validate_source_tree() {
    local required_paths=(
        "bin/adxc"
        "bin/adxc-admin"
        "bin/adxc-cmd"
        "bin/adxc-help"
        "bin/adxc-os"
        "admin/adxc-enable-user.sh"
        "admin/adxc-disable-user.sh"
        "lib/adxc-common.sh"
        "lib/adxc-colors.sh"
        "lib/adxc-profile-management.sh"
        "lib/adxc-command-management.sh"
        "etc/adxc.conf"
        "templates/user-home/adxc-runtime/activate.sh"
        "install.sh"
        "uninstall.sh"
        "VERSION"
        "README.md"
        "MANIFEST.md"
    )

    printf 'Validating installation source tree...\n'

    local relative_path
    for relative_path in "${required_paths[@]}"; do
        if [[ ! -e "${SOURCE_DIR}/${relative_path}" ]]; then
            print_error "Package corruption detected. Missing: ${relative_path}"
            exit 1
        fi
    done

    printf 'Source tree validation completed.\n'
}

validate_shell_syntax() {
    printf 'Validating shell syntax...\n'

    local script_file
    while IFS= read -r script_file; do
        if bash -n "${script_file}"; then
            printf '  OK %s\n' "${script_file#${SOURCE_DIR}/}"
        else
            print_error "Shell syntax validation failed: ${script_file#${SOURCE_DIR}/}"
            exit 1
        fi
    done < <(
        find "${SOURCE_DIR}" \
            -type f \
            \( -name '*.sh' -o -name '*.cmd' -o -path '*/bin/*' -o -path '*/admin/*' -o -path '*/lib/*' \) \
            ! -path '*/logs/*' \
            ! -path '*/docs/*' \
            | sort
    )

    printf 'Shell syntax validation completed.\n'
}

backup_existing_installation() {
    if [[ ! -d "${INSTALL_DIR}" ]]; then
        return 0
    fi

    local timestamp
    local backup_dir

    timestamp="$(date '+%Y%m%d_%H%M%S')"
    backup_dir="${INSTALL_DIR}.backup.${timestamp}"

    printf 'Existing installation detected: %s\n' "${INSTALL_DIR}"
    printf 'Creating backup: %s\n' "${backup_dir}"

    mv "${INSTALL_DIR}" "${backup_dir}"
}

copy_source_tree() {
    printf 'Installing files to %s\n' "${INSTALL_DIR}"
    mkdir -p "${INSTALL_DIR}"
    cp -R "${SOURCE_DIR}/." "${INSTALL_DIR}/"
}

set_ownership_and_permissions() {
    printf 'Applying ownership and permissions...\n'

    chown -R root:root "${INSTALL_DIR}"

    # Directories should be traversable and readable by users.
    find "${INSTALL_DIR}" -type d -exec chmod 0755 {} \;

    # Regular files are not executable by default.
    find "${INSTALL_DIR}" -type f -exec chmod 0644 {} \;

    # Known executable locations.
    find "${INSTALL_DIR}/bin" -type f -exec chmod 0755 {} \;
    find "${INSTALL_DIR}/admin" -type f -exec chmod 0755 {} \;

    # Script and command objects are executable by design.
    find "${INSTALL_DIR}" -type f -name '*.sh' -exec chmod 0755 {} \;
    find "${INSTALL_DIR}" -type f -name '*.cmd' -exec chmod 0755 {} \;

    # Installer and uninstaller remain executable.
    chmod 0755 "${INSTALL_DIR}/install.sh" "${INSTALL_DIR}/uninstall.sh"
}

create_command_symlinks() {
    if [[ ! -d "/usr/local/bin" ]]; then
        printf 'Directory /usr/local/bin does not exist. Skipping command symlinks.\n'
        return 0
    fi

    local command_name
    for command_name in adxc adxc-admin adxc-help adxc-cmd adxc-os; do
        ln -sf "${INSTALL_DIR}/bin/${command_name}" "/usr/local/bin/${command_name}"
    done

    printf 'Command symlinks created in /usr/local/bin.\n'
}

activate_root_runtime() {
    if [[ "${ACTIVATE_ROOT}" != "YES" ]]; then
        return 0
    fi

    mkdir -p /root/.adxc
    cp "${INSTALL_DIR}/templates/user-home/adxc-runtime/activate.sh" /root/.adxc/activate.sh
    chown -R root:root /root/.adxc
    chmod 0755 /root/.adxc
    chmod 0644 /root/.adxc/activate.sh

    printf 'Root activation script installed at /root/.adxc/activate.sh\n'
}

print_install_summary() {
    print_line
    printf 'aDXC installation completed\n'
    print_line
    printf '\nVersion:\n'
    printf '  %s\n' "${ADXC_VERSION}"
    printf '\nInstalled location:\n'
    printf '  %s\n' "${INSTALL_DIR}"
    printf '\nTemplate source:\n'
    printf '  %s/templates/user-home/adxc-runtime\n' "${INSTALL_DIR}"
    printf '\nProfile directory:\n'
    printf '  %s/profiles\n' "${INSTALL_DIR}"
    printf '\nCommand repository:\n'
    printf '  %s/commands\n' "${INSTALL_DIR}"
    printf '\nGlobal scripts:\n'
    printf '  %s/scripts\n' "${INSTALL_DIR}"
    printf '\nNext step - enable selected user:\n'
    printf '  %s/admin/adxc-enable-user.sh <user>\n' "${INSTALL_DIR}"
    printf '\nExample:\n'
    printf '  %s/admin/adxc-enable-user.sh taleff\n' "${INSTALL_DIR}"
    printf '\nForce activation on every login:\n'
    printf '  %s/admin/adxc-enable-user.sh --force mqm\n' "${INSTALL_DIR}"
    printf '\nUser activation after enablement:\n'
    printf '  source ~/.adxc/activate.sh\n'
    printf '  adxc\n'
    print_line
}

main() {
    parse_arguments "$@"
    require_root
    validate_source_tree
    validate_shell_syntax
    backup_existing_installation
    copy_source_tree
    set_ownership_and_permissions
    create_command_symlinks
    activate_root_runtime
    print_install_summary
}

main "$@"
