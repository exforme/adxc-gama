#!/usr/bin/env bash
if [ -t 1 ] && [ -z "${NO_COLOR:-}" ]; then
    ADXC_RESET='\033[0m'
    ADXC_BOLD='\033[1m'
    ADXC_GREEN='\033[38;5;46m'
    ADXC_CYAN='\033[38;5;51m'
    ADXC_YELLOW='\033[38;5;226m'
    ADXC_RED='\033[38;5;196m'
else
    ADXC_RESET=''
    ADXC_BOLD=''
    ADXC_GREEN=''
    ADXC_CYAN=''
    ADXC_YELLOW=''
    ADXC_RED=''
fi
adxc_ok() { printf "%bOK%b %s\n" "$ADXC_GREEN" "$ADXC_RESET" "$*"; }
adxc_warn() { printf "%bWARNING%b %s\n" "$ADXC_YELLOW" "$ADXC_RESET" "$*"; }
adxc_error() { printf "%bERROR%b %s\n" "$ADXC_RED" "$ADXC_RESET" "$*" >&2; }
