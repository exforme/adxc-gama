#!/usr/bin/env bash
# ==============================================================================
# install.sh - install aDXC-GAMA framework
# ============================================================================== 
# Usage:
#   ./install.sh
#   ./install.sh --activate-root
#
# Default install location:
#   /opt/adxc
#
# Override install location:
#   ADXC_INSTALL_DIR=/custom/path ./install.sh
# ============================================================================== 

set -e

SOURCE_DIR=$(cd "$(dirname "$0")" && pwd)
DEST_DIR=${ADXC_INSTALL_DIR:-/opt/adxc}
ACTIVATE_ROOT="no"

for arg in "$@"; do
    case "$arg" in
        --activate-root)
            ACTIVATE_ROOT="yes"
            ;;
        *)
            echo "Unknown option: $arg"
            exit 1
            ;;
    esac
done

if [ "$(id -u)" -ne 0 ]; then
    echo "ERROR: install.sh must be run as root" >&2
    exit 1
fi

# shellcheck source=/dev/null
. "$SOURCE_DIR/lib/adxc-colors.sh"

adxc_title "aDXC-GAMA INSTALLER"
printf '%-24s : %s\n' "Source" "$SOURCE_DIR"
printf '%-24s : %s\n' "Destination" "$DEST_DIR"
printf '%-24s : %s\n' "Version" "$(cat "$SOURCE_DIR/VERSION")"

rm -rf "$DEST_DIR"
mkdir -p "$DEST_DIR"
cp -a "$SOURCE_DIR"/. "$DEST_DIR"/

find "$DEST_DIR" -type d -exec chmod 755 {} \;
find "$DEST_DIR" -type f -exec chmod 644 {} \;
find "$DEST_DIR/bin" "$DEST_DIR/admin" "$DEST_DIR/commands" "$DEST_DIR/templates/profile-templates" -type f -exec chmod 755 {} \;
chmod 755 "$DEST_DIR/install.sh" "$DEST_DIR/uninstall.sh"

adxc_section "INSTALLATION COMPLETE"
printf '%-24b : %s\n' "${ADXC_GREEN}Dashboard${ADXC_RESET}" "adxc"
printf '%-24b : %s\n' "${ADXC_GREEN}Help${ADXC_RESET}" "adxc-help"
printf '%-24b : %s\n' "${ADXC_GREEN}All commands${ADXC_RESET}" "adxc-help --list-all"
printf '%-24b : %s\n' "${ADXC_GREEN}Profile inventory${ADXC_RESET}" "adxc-profiles"
printf '%-24b : %s\n' "${ADXC_GREEN}Message admin${ADXC_RESET}" "adxc-admin messages"
printf '%-24b : %s\n' "${ADXC_GREEN}Create message${ADXC_RESET}" "adxc-msg-create"
printf '%-24b : %s\n' "${ADXC_GREEN}Create profile${ADXC_RESET}" "adxc-create-profile"
printf '%-24b : %s\n' "${ADXC_GREEN}Create command${ADXC_RESET}" "adxc-create-command"
printf '%-24b : %s\n' "${ADXC_GREEN}Custom commands${ADXC_RESET}" "adxc-cmd"

if [ "$ACTIVATE_ROOT" = "yes" ]; then
    "$DEST_DIR/admin/adxc-enable-user.sh" root --role admin --force >/dev/null
    adxc_ok "Root runtime created: /root/.adxc"
    echo "Run: source /root/.adxc/activate.sh && adxc"
else
    adxc_warn "Root runtime not created. Use --activate-root if root should run adxc directly."
fi

adxc_line
