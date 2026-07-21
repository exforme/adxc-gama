#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# aDXC-GAMA uninstaller
# -----------------------------------------------------------------------------
set -euo pipefail
INSTALL_DIR="${ADXC_HOME:-/opt/adxc-gama}"
REMOVE_INSTALL_DIR="NO"
for argument in "$@"; do
    case "${argument}" in
        --remove-install-dir) REMOVE_INSTALL_DIR="YES" ;;
        --install-dir=*) INSTALL_DIR="${argument#--install-dir=}" ;;
        *) printf 'Unknown option: %s\n' "${argument}" >&2; exit 1 ;;
    esac
done
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
