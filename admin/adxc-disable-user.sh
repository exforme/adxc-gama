#!/usr/bin/env bash
set -euo pipefail
TARGET_USER="${1:-}"
if [[ -z "${TARGET_USER}" ]]; then
    printf 'Usage: %s <username>\n' "$0" >&2
    exit 1
fi
USER_HOME="$(eval echo "~${TARGET_USER}" 2>/dev/null || true)"
if [[ -n "${USER_HOME}" && -f "${USER_HOME}/.adxc/activate.sh" ]]; then
    mv "${USER_HOME}/.adxc/activate.sh" "${USER_HOME}/.adxc/activate.sh.disabled"
    printf 'aDXC-GAMA disabled for user %s\n' "${TARGET_USER}"
else
    printf 'No active aDXC-GAMA activation found for user %s\n' "${TARGET_USER}"
fi
