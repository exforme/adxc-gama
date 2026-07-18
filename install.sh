#!/usr/bin/env bash

set -e

###############################################################################
# aDXC-GAMA Installer
###############################################################################

SRC="$(cd "$(dirname "$0")" && pwd)"
DEST="${ADXC_INSTALL_DIR:-/opt/adxc}"

ACTIVATE_ROOT="no"

###############################################################################
# Parse arguments
###############################################################################

for arg in "$@"
do
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

###############################################################################
# Root check
###############################################################################

if [ "$(id -u)" -ne 0 ]
then
    echo "ERROR: install.sh must be run as root" >&2
    exit 1
fi

###############################################################################
# Load libraries
###############################################################################

. "$SRC/lib/adxc-colors.sh"

###############################################################################
# Banner
###############################################################################

adxc_title "aDXC-GAMA INSTALLER"

printf '%-24s : %s\n' "Source"      "$SRC"
printf '%-24s : %s\n' "Destination" "$DEST"
printf '%-24s : %s\n' "Version"     "$(cat "$SRC/VERSION")"

###############################################################################
# Install files
###############################################################################

rm -rf "$DEST"

mkdir -p "$DEST"

cp -a "$SRC"/. "$DEST"/

###############################################################################
# Permissions
###############################################################################

find "$DEST" -type d -exec chmod 755 {} \;
find "$DEST" -type f -exec chmod 644 {} \;

find \
    "$DEST/bin" \
    "$DEST/admin" \
    "$DEST/commands" \
    "$DEST/templates/profile-templates" \
    -type f \
    -exec chmod 755 {} \;

chmod 755 \
    "$DEST/install.sh" \
    "$DEST/uninstall.sh"

###############################################################################
# Summary
###############################################################################

adxc_section "INSTALLATION COMPLETE"

printf '%-24b : %s\n' \
    "${ADXC_GREEN}Profile inventory${ADXC_RESET}" \
    "adxc-profiles"

printf '%-24b : %s\n' \
    "${ADXC_GREEN}Create profile${ADXC_RESET}" \
    "adxc-create-profile"

printf '%-24b : %s\n' \
    "${ADXC_GREEN}Create command${ADXC_RESET}" \
    "adxc-create-command"

printf '%-24b : %s\n' \
    "${ADXC_GREEN}Custom commands${ADXC_RESET}" \
    "adxc-cmd"

###############################################################################
# Optional root activation
###############################################################################

if [ "$ACTIVATE_ROOT" = "yes" ]
then
    "$DEST/admin/adxc-enable-user.sh" \
        root \
        --role admin \
        --force \
        >/dev/null

    adxc_ok "Root runtime created: /root/.adxc"

    echo
    echo "Run:"
    echo
    echo "    source /root/.adxc/activate.sh"
    echo "    adxc"
else
    adxc_warn \
        "Root runtime not created. Use --activate-root if root should run adxc directly."
fi

###############################################################################
# End
###############################################################################

adxc_line
