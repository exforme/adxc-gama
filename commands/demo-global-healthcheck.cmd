#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# aDXC-GAMA command object
# -----------------------------------------------------------------------------
COMMAND_NAME="demo-global-healthcheck"
COMMAND_TYPE="external-script"
COMMAND_DESCRIPTION="Run reusable demo global healthcheck script"
COMMAND_ENABLED="YES"
COMMAND_STATUS="ACTIVE"
COMMAND_CREATED_BY="package"
COMMAND_CREATED_DATE="2026-07-21 13:34:00"
COMMAND_ARCHIVED_BY=""
COMMAND_ARCHIVED_DATE=""

SCRIPT_PATH="scripts/demo-global-healthcheck.sh"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ADXC_ROOT_DIR="${SCRIPT_DIR}"
source "${ADXC_ROOT_DIR}/lib/adxc-common.sh"

main() {
    local resolved_script
    resolved_script="$(adxc_relative_to_root "${SCRIPT_PATH}")"

    if [[ ! -x "${resolved_script}" ]]; then
        printf 'ERROR: Script is not executable or does not exist: %s\n' "${resolved_script}" >&2
        exit 1
    fi

    "${resolved_script}" "$@"
}

main "$@"
