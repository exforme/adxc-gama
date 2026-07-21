#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# aDXC-GAMA per-user runtime activation
# -----------------------------------------------------------------------------
# This file is sourced by the user or by a forced shell startup hook.
# It should not exit the parent shell.

ADXC_USER_ENV="${HOME}/.adxc/env"

if [[ -f "${ADXC_USER_ENV}" ]]; then
    # shellcheck source=/dev/null
    source "${ADXC_USER_ENV}"
fi

ADXC_HOME="${ADXC_HOME:-/opt/adxc}"
ADXC_VERSION="unknown"

if [[ -f "${ADXC_HOME}/VERSION" ]]; then
    ADXC_VERSION="$(cat "${ADXC_HOME}/VERSION" 2>/dev/null)"
fi

export ADXC_HOME
export PATH="${ADXC_HOME}/bin:${PATH}"

printf '============================================================\n'
printf 'aDXC ACTIVE\n'
printf '============================================================\n'
printf '\nVersion:\n'
printf '  %s\n' "${ADXC_VERSION}"
printf '\nInstallation:\n'
printf '  %s\n' "${ADXC_HOME}"
printf '\nCommands:\n'
printf '  adxc\n'
printf '  adxc-admin\n'
printf '  adxc-cmd --list\n'
printf '============================================================\n'
