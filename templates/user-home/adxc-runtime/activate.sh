#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# Per-user aDXC-GAMA runtime activation
# -----------------------------------------------------------------------------
ADXC_HOME="${ADXC_HOME:-/opt/adxc-gama}"
export ADXC_HOME
export PATH="${ADXC_HOME}/bin:${PATH}"
printf 'aDXC-GAMA runtime activated from %s\n' "${ADXC_HOME}"
