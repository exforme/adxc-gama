# ==============================================================================
# aDXC-GAMA runtime activation
# ==============================================================================
# Usage:
#   source ~/.adxc/activate.sh
#
# Result:
#   - ADXC_HOME points to the installed framework
#   - ADXC_RUNTIME points to the current user's runtime directory
#   - aDXC commands are added to PATH
# ==============================================================================

export ADXC_HOME=${ADXC_HOME:-/opt/adxc}
export ADXC_RUNTIME="$HOME/.adxc"
export PATH="$ADXC_HOME/bin:$ADXC_HOME/admin:$PATH"

if [ -r "$ADXC_HOME/lib/adxc-colors.sh" ]; then
    # shellcheck source=/dev/null
    . "$ADXC_HOME/lib/adxc-colors.sh"
fi
