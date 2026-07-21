#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# Disable aDXC-GAMA user activation
# -----------------------------------------------------------------------------
# This disables the activation script and removes the force activation block from
# .bashrc when present. It keeps a backup copy of .bashrc.

set -euo pipefail

TARGET_USER="${1:-}"

if [[ -z "${TARGET_USER}" ]]; then
    printf 'Usage: %s <user>\n' "$0" >&2
    exit 1
fi

if [[ "$(id -u)" -ne 0 ]]; then
    printf 'ERROR: User disablement must be executed as root.\n' >&2
    exit 1
fi

USER_HOME="$(getent passwd "${TARGET_USER}" | awk -F: '{print $6}')"

if [[ -z "${USER_HOME}" || ! -d "${USER_HOME}" ]]; then
    printf 'ERROR: Home directory not found for user %s.\n' "${TARGET_USER}" >&2
    exit 1
fi

if [[ -f "${USER_HOME}/.adxc/activate.sh" ]]; then
    mv "${USER_HOME}/.adxc/activate.sh" "${USER_HOME}/.adxc/activate.sh.disabled"
    printf 'Disabled activation script for user %s.\n' "${TARGET_USER}"
fi

BASHRC_FILE="${USER_HOME}/.bashrc"

if [[ -f "${BASHRC_FILE}" ]] && grep -qF '# >>> aDXC-GAMA auto activation >>>' "${BASHRC_FILE}"; then
    cp "${BASHRC_FILE}" "${BASHRC_FILE}.adxc-backup.$(date '+%Y%m%d_%H%M%S')"
    sed -i '/# >>> aDXC-GAMA auto activation >>>/,/# <<< aDXC-GAMA auto activation <<</d' "${BASHRC_FILE}"
    printf 'Removed aDXC force activation block from %s.\n' "${BASHRC_FILE}"
fi

printf 'aDXC-GAMA disabled for user %s.\n' "${TARGET_USER}"
