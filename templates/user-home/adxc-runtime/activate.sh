export ADXC_HOME=${ADXC_HOME:-/opt/adxc}
export ADXC_RUNTIME="$HOME/.adxc"
export PATH="$ADXC_HOME/bin:$ADXC_HOME/admin:$PATH"
[ -r "$ADXC_HOME/lib/adxc-colors.sh" ] && . "$ADXC_HOME/lib/adxc-colors.sh"
