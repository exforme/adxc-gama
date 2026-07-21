#!/usr/bin/env bash
set -euo pipefail
TARGET_USER="${1:-}"
if [[ -z "${TARGET_USER}" ]]; then
    printf 'Usage: %s <username>\n' "$0" >&2
    exit 1
fi
USER_HOME="$(eval echo "~${TARGET_USER}" 2>/dev/null || true)"
if [[ -z "${USER_HOME}" || ! -d "${USER_HOME}" ]]; then
    printf 'User home not found for %s\n' "${TARGET_USER}" >&2
    exit 1
fi
mkdir -p "${USER_HOME}/.adxc"
cp "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/templates/user-home/adxc-runtime/activate.sh" "${USER_HOME}/.adxc/activate.sh"
chown -R "${TARGET_USER}" "${USER_HOME}/.adxc" 2>/dev/null || true
printf 'aDXC-GAMA enabled for user %s\n' "${TARGET_USER}"
printf 'Ask the user to run: source ~/.adxc/activate.sh\n'
