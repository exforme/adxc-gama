#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# aDXC-GAMA installer
# -----------------------------------------------------------------------------
set -euo pipefail
SOURCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_DIR="/opt/adxc-gama"
ACTIVATE_ROOT="NO"
for argument in "$@"; do
    case "${argument}" in
        --activate-root) ACTIVATE_ROOT="YES" ;;
        /*) INSTALL_DIR="${argument}" ;;
        *) printf 'Unknown option: %s\n' "${argument}" >&2; exit 1 ;;
    esac
done
printf 'Installing aDXC-GAMA to %s\n' "${INSTALL_DIR}"
mkdir -p "${INSTALL_DIR}"
cp -R "${SOURCE_DIR}/." "${INSTALL_DIR}/"
if [[ -w "/usr/local/bin" ]]; then
    for command_name in adxc adxc-admin adxc-help adxc-cmd adxc-os; do
        ln -sf "${INSTALL_DIR}/bin/${command_name}" "/usr/local/bin/${command_name}"
    done
    printf 'Command symlinks created in /usr/local/bin.\n'
else
    printf 'No write access to /usr/local/bin. Add this to PATH manually:\n'
    printf '  export PATH="%s/bin:$PATH"\n' "${INSTALL_DIR}"
fi
if [[ "${ACTIVATE_ROOT}" == "YES" ]]; then
    mkdir -p /root/.adxc
    cp "${INSTALL_DIR}/templates/user-home/adxc-runtime/activate.sh" /root/.adxc/activate.sh
    printf 'Root activation script installed at /root/.adxc/activate.sh\n'
fi
printf 'Installation completed.\n'
