#!/usr/bin/env bash
# ==============================================================================
# aDXC-GAMA color library
# ==============================================================================
# Purpose:
#   Centralized color definitions and simple rendering helpers.
#
# Color standard:
#   GREEN  - commands / executable actions
#   CYAN   - sections / menus / operational objects / profiles
#   YELLOW - variables / warnings / inventory notes
#   RED    - errors / dashboard title / critical messages
#
# Tip:
#   Set NO_COLOR=1 before running adxc to disable terminal colors.
# ==============================================================================

if [ -t 1 ] && [ "${NO_COLOR:-}" = "" ]; then
    ADXC_GREEN='\033[1;32m'
    ADXC_CYAN='\033[1;36m'
    ADXC_YELLOW='\033[1;33m'
    ADXC_RED='\033[1;31m'
    ADXC_WHITE='\033[1;37m'
    ADXC_DIM='\033[2m'
    ADXC_RESET='\033[0m'
else
    ADXC_GREEN=''
    ADXC_CYAN=''
    ADXC_YELLOW=''
    ADXC_RED=''
    ADXC_WHITE=''
    ADXC_DIM=''
    ADXC_RESET=''
fi

adxc_line() {
    printf '%b\n' "${ADXC_CYAN}============================================================${ADXC_RESET}"
}

adxc_sep() {
    printf '%b\n' "${ADXC_CYAN}------------------------------------------------------------${ADXC_RESET}"
}

adxc_title() {
    adxc_line
    printf '%b\n' "${ADXC_RED}                     $*${ADXC_RESET}"
    adxc_line
}

adxc_section() {
    adxc_line
    printf '%b\n' "${ADXC_CYAN} $*${ADXC_RESET}"
    adxc_line
}

adxc_error() {
    printf '%b\n' "${ADXC_RED}ERROR: $*${ADXC_RESET}" >&2
}

adxc_warn() {
    printf '%b\n' "${ADXC_YELLOW}WARNING: $*${ADXC_RESET}"
}

adxc_ok() {
    printf '%b\n' "${ADXC_GREEN}$*${ADXC_RESET}"
}

adxc_label_color() {
    case "$1" in
        CRITICAL) printf '%b' "$ADXC_RED" ;;
        WARNING)  printf '%b' "$ADXC_YELLOW" ;;
        INFO)     printf '%b' "$ADXC_CYAN" ;;
        *)        printf '%b' "$ADXC_WHITE" ;;
    esac
}
