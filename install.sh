#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# aDXC-GAMA installer
# -----------------------------------------------------------------------------
# Usage:
#   ./install.sh /opt/adxc-gama
#   ./install.sh --activate-root

set -euo pipefail

SOURCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_DIR="/opt/adxc-gama"
ACTIVATE_ROOT="NO"

for argument in "$@"; do
    case "${argument}" in
        --activate-root)
            ACTIVATE_ROOT="YES"
            ;;
        /*)
            INSTALL_DIR="${argument}"
            ;;
        *)
            printf 'Unknown option: %s\n' "${argument}" >&2
            exit 1
            ;;
    esac
done

printf 'Installing aDXC-GAMA to %s\n' "${INSTALL_DIR}"
mkdir -p "${INSTALL_DIR}"
cp -R "${SOURCE_DIR}/." "${INSTALL_DIR}/"

if [[ -w "/usr/local/bin" ]]; then
    ln -sf "${INSTALL_DIR}/bin/adxc" "/usr/local/bin/adxc"
    ln -sf "${INSTALL_DIR}/bin/adxc-admin" "/usr/local/bin/adxc-admin"
    ln -sf "${INSTALL_DIR}/bin/adxc-help" "/usr/local/bin/adxc-help"
    ln -sf "${INSTALL_DIR}/bin/adxc-cmd" "/usr/local/bin/adxc-cmd"
    ln -sf "${INSTALL_DIR}/bin/adxc-os" "/usr/local/bin/adxc-os"
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
