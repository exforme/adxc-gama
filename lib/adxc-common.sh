#!/usr/bin/env bash
# ==============================================================================
# aDXC-GAMA common library
# ==============================================================================
# Purpose:
#   Shared functions used by all runtime and admin commands.
#
# Main responsibilities:
#   - load user runtime configuration
#   - check profile access
#   - read profile metadata
#   - read and render message-board files
#   - render compact profile tables
#
# Message format:
#   TYPE=INFO|WARNING|CRITICAL
#   TITLE=message title
#   EXPIRES=YYYY-MM-DD
#   TEXT<<ADXC_EOF
#   message body
#   ADXC_EOF
# ==============================================================================

ADXC_HOME=${ADXC_HOME:-/opt/adxc}

if [ -r "$ADXC_HOME/lib/adxc-colors.sh" ]; then
    # shellcheck source=/dev/null
    . "$ADXC_HOME/lib/adxc-colors.sh"
fi

adxc_version() {
    if [ -r "$ADXC_HOME/VERSION" ]; then
        cat "$ADXC_HOME/VERSION"
    else
        echo "unknown"
    fi
}

adxc_hostname() {
    hostname 2>/dev/null \
        || uname -n 2>/dev/null \
        || cat /proc/sys/kernel/hostname 2>/dev/null \
        || echo "unknown"
}

adxc_today() {
    date +%F
}

adxc_require_runtime() {
    if [ -z "${ADXC_RUNTIME:-}" ] || [ ! -d "$ADXC_RUNTIME" ]; then
        adxc_error "aDXC runtime is not active. Run: source ~/.adxc/activate.sh"
        exit 1
    fi
}

adxc_load_user_config() {
    adxc_require_runtime

    if [ -r "$ADXC_RUNTIME/config/user.conf" ]; then
        # shellcheck source=/dev/null
        . "$ADXC_RUNTIME/config/user.conf"
    fi

    ADXC_ROLE=${ADXC_ROLE:-support}
    ADXC_ACTIVE_PROFILES=${ADXC_ACTIVE_PROFILES:-}
}

adxc_profile_allowed() {
    local profile_name="$1"

    case "${ADXC_ROLE:-support}" in
        admin|ADMIN|root)
            return 0
            ;;
    esac

    case " ${ADXC_ACTIVE_PROFILES:-} " in
        *" $profile_name "*) return 0 ;;
        *) return 1 ;;
    esac
}

adxc_profile_field() {
    local file="$1"
    local key="$2"
    local default_value="$3"

    if [ ! -r "$file" ]; then
        echo "$default_value"
        return
    fi

    awk -F= -v k="$key" -v d="$default_value" '
        $1 == k {
            gsub(/^"|"$/, "", $2)
            print $2
            found = 1
            exit
        }
        END {
            if (!found) print d
        }
    ' "$file"
}

adxc_message_field() {
    local file="$1"
    local key="$2"
    local default_value="$3"

    if [ ! -r "$file" ]; then
        echo "$default_value"
        return
    fi

    awk -F= -v k="$key" -v d="$default_value" '
        $1 == k {
            v = $0
            sub(/^[^=]*=/, "", v)
            gsub(/^"|"$/, "", v)
            print v
            found = 1
            exit
        }
        END {
            if (!found) print d
        }
    ' "$file"
}

adxc_message_text() {
    local file="$1"

    awk '
        BEGIN { in_text = 0 }
        /^TEXT<<ADXC_EOF$/ { in_text = 1; next }
        /^ADXC_EOF$/       { in_text = 0; next }
        in_text            { print }
    ' "$file"
}

adxc_message_active() {
    local file="$1"
    local expires
    local today

    expires=$(adxc_message_field "$file" EXPIRES "9999-12-31")
    today=$(adxc_today)

    [ "$expires" \> "$today" ] || [ "$expires" = "$today" ]
}

adxc_active_message_count() {
    local count=0
    local file

    for file in "$ADXC_HOME/messages"/*.msg; do
        [ -f "$file" ] || continue
        if adxc_message_active "$file"; then
            count=$((count + 1))
        fi
    done

    echo "$count"
}

adxc_next_message_id() {
    local max_id=0
    local file
    local base_name

    for file in "$ADXC_HOME/messages"/*.msg; do
        [ -f "$file" ] || continue
        base_name=$(basename "$file" .msg)

        case "$base_name" in
            *[!0-9]*|'') continue ;;
        esac

        if [ "$base_name" -gt "$max_id" ]; then
            max_id="$base_name"
        fi
    done

    printf '%03d\n' $((max_id + 1))
}

adxc_render_message_board() {
    local count
    local file
    local first=1
    local type
    local title
    local expires
    local color

    count=$(adxc_active_message_count)
    adxc_section "MESSAGE BOARD ($count)"

    if [ "$count" -eq 0 ]; then
        printf '%b\n' "${ADXC_DIM} No active announcements.${ADXC_RESET}"
        return
    fi

    for file in $(ls "$ADXC_HOME/messages"/*.msg 2>/dev/null | sort); do
        [ -f "$file" ] || continue
        adxc_message_active "$file" || continue

        if [ "$first" -ne 1 ]; then
            adxc_sep
        fi
        first=0

        type=$(adxc_message_field "$file" TYPE INFO)
        title=$(adxc_message_field "$file" TITLE "Untitled message")
        expires=$(adxc_message_field "$file" EXPIRES "9999-12-31")
        color=$(adxc_label_color "$type")

        printf '%b[%s]%b\n' "$color" "$type" "$ADXC_RESET"
        printf '%b\n\n' "$title"
        adxc_message_text "$file"
        printf '\nExpires : %s\n' "$expires"
    done
}

adxc_list_profiles_compact() {
    local found=0
    local id=1
    local profile_dir
    local profile_name
    local profile_conf
    local profile_desc
    local profile_type
    local access

    printf ' ID   Object      Description                         Access\n'
    printf ' ---  ----------  ----------------------------------  --------\n'
    printf ' [%s]  %-10s %-34s %s\n\n' \
        1 \
        OS \
        "Linux health checks and diagnostics" \
        system

    id=2

    for profile_dir in "$ADXC_HOME/profiles"/*; do
        [ -d "$profile_dir" ] || continue
        found=1

        profile_name=$(basename "$profile_dir")
        profile_conf="$profile_dir/profile.conf"
        profile_desc=$(adxc_profile_field "$profile_conf" PROFILE_DESCRIPTION "Operational profile")
        profile_type=$(adxc_profile_field "$profile_conf" PROFILE_TYPE custom)

        if adxc_profile_allowed "$profile_name"; then
            access="allowed"
        else
            access="inventory"
        fi

        printf ' [%s]  %-10s %-34s %s/%s\n\n' \
            "$id" \
            "$profile_name" \
            "$profile_desc" \
            "$profile_type" \
            "$access"

        id=$((id + 1))
    done

    if [ "$found" -ne 1 ]; then
        printf '%b\n' "${ADXC_YELLOW} No operational profiles configured yet.${ADXC_RESET}"
    fi
}
