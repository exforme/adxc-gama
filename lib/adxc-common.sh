#!/usr/bin/env bash

###############################################################################
# aDXC-GAMA Common Library
###############################################################################

ADXC_HOME="${ADXC_HOME:-/opt/adxc}"

###############################################################################
# Load Color Library
###############################################################################

if [ -r "$ADXC_HOME/lib/adxc-colors.sh" ]
then
    . "$ADXC_HOME/lib/adxc-colors.sh"
fi

###############################################################################
# General Utilities
###############################################################################

adxc_version()
{
    if [ -r "$ADXC_HOME/VERSION" ]
    then
        cat "$ADXC_HOME/VERSION"
    else
        echo "unknown"
    fi
}

adxc_today()
{
    date +%F
}

###############################################################################
# Runtime Validation
###############################################################################

adxc_require_runtime()
{
    if [ -n "${ADXC_RUNTIME:-}" ] &&
       [ -d "$ADXC_RUNTIME" ]
    then
        return 0
    fi

    adxc_error \
        "aDXC runtime is not active. Run: source ~/.adxc/activate.sh"

    exit 1
}

###############################################################################
# User Configuration
###############################################################################

adxc_load_user_config()
{
    adxc_require_runtime

    if [ -r "$ADXC_RUNTIME/config/user.conf" ]
    then
        . "$ADXC_RUNTIME/config/user.conf"
    fi

    ADXC_ROLE="${ADXC_ROLE:-support}"
    ADXC_ACTIVE_PROFILES="${ADXC_ACTIVE_PROFILES:-}"
}

###############################################################################
# Profile Authorization
###############################################################################

adxc_profile_allowed()
{
    local profile="$1"

    case "${ADXC_ROLE:-support}" in

        admin|ADMIN|root)
            return 0
            ;;

    esac

    case " ${ADXC_ACTIVE_PROFILES:-} " in

        *" $profile "*)
            return 0
            ;;

        *)
            return 1
            ;;

    esac
}

###############################################################################
# Profile Configuration Reader
###############################################################################

adxc_profile_field()
{
    local file="$1"
    local key="$2"
    local default_value="$3"

    if [ ! -r "$file" ]
    then
        echo "$default_value"
        return
    fi

    awk \
        -F= \
        -v k="$key" \
        -v d="$default_value" \
        '
        $1 == k
        {
            gsub(/^"|"$/, "", $2)

            print $2

            found = 1

            exit
        }

        END
        {
            if (!found)
                print d
        }
        ' "$file"
}

###############################################################################
# Message Configuration Reader
###############################################################################

adxc_message_field()
{
    local file="$1"
    local key="$2"
    local default_value="$3"

    if [ ! -r "$file" ]
    then
        echo "$default_value"
        return
    fi

    awk \
        -F= \
        -v k="$key" \
        -v d="$default_value" \
        '
        $1 == k
        {
            value = $0

            sub(/^[^=]*=/, "", value)

            gsub(/^"|"$/, "", value)

            print value

            found = 1

            exit
        }

        END
        {
            if (!found)
                print d
        }
        ' "$file"
}

###############################################################################
# Message Text Reader
###############################################################################

adxc_message_text()
{
    local file="$1"

    awk '
        BEGIN
        {
            in_text = 0
        }

        /^TEXT<<ADXC_EOF$/
        {
            in_text = 1
            next
        }

        /^ADXC_EOF$/
        {
            in_text = 0
            next
        }

        in_text
        {
            print
        }
    ' "$file"
}

###############################################################################
# Message Status
###############################################################################

adxc_message_active()
{
    local file="$1"

    local expires
    local today

    expires="$(adxc_message_field "$file" EXPIRES "9999-12-31")"
    today="$(adxc_today)"

    [ "$expires" \> "$today" ] ||
    [ "$expires" = "$today" ]
}

###############################################################################
# Active Message Count
###############################################################################

adxc_active_message_count()
{
    local count=0

    local file

    for file in "$ADXC_HOME/messages"/*.msg
    do
        [ -f "$file" ] || continue

        if adxc_message_active "$file"
        then
            count=$((count + 1))
        fi
    done

    echo "$count"
}

###############################################################################
# Next Message ID
###############################################################################

adxc_next_message_id()
{
    local max=0

    local file
    local id

    for file in "$ADXC_HOME/messages"/*.msg
    do
        [ -f "$file" ] || continue

        id="$(basename "$file" .msg)"

        case "$id" in
            *[!0-9]*|'')
                continue
                ;;
        esac

        if [ "$id" -gt "$max" ]
        then
            max="$id"
        fi
    done

    printf '%03d\n' $((max + 1))
}

###############################################################################
# Message Board
###############################################################################

adxc_render_message_board()
{
    local count
    local first=1

    count="$(adxc_active_message_count)"

    adxc_section "MESSAGE BOARD ($count)"

    if [ "$count" -eq 0 ]
    then
        printf '%b\n' \
            "${ADXC_DIM} No active announcements.${ADXC_RESET}"
        return
    fi

    local file
    local type
    local title
    local expires
    local color

    for file in $(ls "$ADXC_HOME/messages"/*.msg 2>/dev/null | sort)
    do
        [ -f "$file" ] || continue

        adxc_message_active "$file" || continue

        if [ "$first" -ne 1 ]
        then
            adxc_sep
        fi

        first=0

        type="$(adxc_message_field "$file" TYPE INFO)"
        title="$(adxc_message_field "$file" TITLE "Untitled Message")"
        expires="$(adxc_message_field "$file" EXPIRES "9999-12-31")"

        color="$(adxc_label_color "$type")"

        printf '%b[%s]%b\n' \
            "$color" \
            "$type" \
            "$ADXC_RESET"

        printf '%b\n\n' "$title"

        adxc_message_text "$file"

        printf '\nExpires : %s\n' "$expires"
    done
}

###############################################################################
# Compact Profile Inventory
###############################################################################

adxc_list_profiles_compact()
{
    local found=0
    local id=1

    printf ' ID   Object      Description                         Access\n'
    printf ' ---  ----------  ----------------------------------  --------\n'

    printf \
        ' [%s]  %-10s %-34s %s\n\n' \
        "1" \
        "OS" \
        "Linux health checks and diagnostics" \
        "system"

    id=2

    local profile_dir
    local profile_name
    local profile_conf
    local profile_type
    local profile_desc
    local access

    for profile_dir in "$ADXC_HOME/profiles"/*
    do
        [ -d "$profile_dir" ] || continue

        found=1

        profile_name="$(basename "$profile_dir")"
        profile_conf="$profile_dir/profile.conf"

        profile_desc="$(
            adxc_profile_field \
                "$profile_conf" \
                PROFILE_DESCRIPTION \
                "Operational profile"
        )"

        profile_type="$(
            adxc_profile_field \
                "$profile_conf" \
                PROFILE_TYPE \
                custom
        )"

        if adxc_profile_allowed "$profile_name"
        then
            access="allowed"
        else
            access="inventory"
        fi

        printf \
            ' [%s]  %-10s %-34s %s/%s\n\n' \
            "$id" \
            "$profile_name" \
            "$profile_desc" \
            "$profile_type" \
            "$access"

        id=$((id + 1))
    done

    if [ "$found" -eq 0 ]
    then
        printf '%b\n' \
            "${ADXC_YELLOW} No operational profiles configured yet.${ADXC_RESET}"
    fi
}
