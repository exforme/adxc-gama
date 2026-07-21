#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# aDXC-GAMA uninstaller
# -----------------------------------------------------------------------------
# Default behavior removes command symlinks and keeps the installed directory.
# Use --remove-install-dir to remove the installed framework directory.

set -euo pipefail

INSTALL_DIR="${ADXC_HOME:-/opt/adxc}"
REMOVE_INSTALL_DIR="NO"

for argument in "$@"; do
    case "${argument}" in
        --remove-install-dir)
            REMOVE_INSTALL_DIR="YES"
            ;;
        --install-dir=*)
            INSTALL_DIR="${argument#--install-dir=}"
            ;;
        --help|-h)
            printf 'Usage: ./uninstall.sh [--install-dir=/opt/adxc] [--remove-install-dir]\n'
            exit 0
            ;;
        *)
            printf 'ERROR: Unknown option: %s\n' "${argument}" >&2
            exit 1
            ;;
    esac
done

if [[ "$(id -u)" -ne 0 ]]; then
    printf 'ERROR: aDXC uninstall must be executed as root.\n' >&2
    exit 1
fi

for command_name in adxc adxc-admin adxc-help adxc-cmd adxc-os; do
    if [[ -L "/usr/local/bin/${command_name}" ]]; then
        rm -f "/usr/local/bin/${command_name}"
        printf 'Removed /usr/local/bin/%s\n' "${command_name}"
    fi
done

if [[ "${REMOVE_INSTALL_DIR}" == "YES" ]]; then
    if [[ -d "${INSTALL_DIR}" ]]; then
        rm -rf "${INSTALL_DIR}"
        printf 'Removed install directory %s\n' "${INSTALL_DIR}"
    fi
else
    printf 'Install directory preserved: %s\n' "${INSTALL_DIR}"
    printf 'Use --remove-install-dir to remove it.\n'
fi

printf 'Uninstall completed.\n'
