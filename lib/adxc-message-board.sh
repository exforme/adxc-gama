#!/usr/bin/env bash

# Purpose:
#   Render active operational notices from /opt/adxc/messages.

adxc_message_is_active() {
    local expires="$1"
    local today

    [ -z "$expires" ] && return 0
    today="$(date +%F)"
    [ "$expires" \> "$today" ] || [ "$expires" = "$today" ]
}

adxc_render_message_board() {
    local message_dir="$ADXC_HOME/messages"
    local active_count=0
    local file local_type local_title local_text local_expires

    [ -d "$message_dir" ] || return 0

    for file in "$message_dir"/*.msg; do
        [ -f "$file" ] || continue
        TYPE="INFO"
        TITLE="Untitled message"
        TEXT=""
        EXPIRES=""
        # shellcheck disable=SC1090
        . "$file"
        if adxc_message_is_active "$EXPIRES"; then
            active_count=$((active_count + 1))
        fi
    done

    adxc_print_section "MESSAGE BOARD ($active_count ACTIVE)"

    if [ "$active_count" -eq 0 ]; then
        printf "No active operational notices.\n"
        return 0
    fi

    for file in "$message_dir"/*.msg; do
        [ -f "$file" ] || continue
        local_type="INFO"
        local_title="Untitled message"
        local_text=""
        local_expires=""
        TYPE="INFO"
        TITLE="Untitled message"
        TEXT=""
        EXPIRES=""
        # shellcheck disable=SC1090
        . "$file"
        local_type="$TYPE"
        local_title="$TITLE"
        local_text="$TEXT"
        local_expires="$EXPIRES"

        if adxc_message_is_active "$local_expires"; then
            case "$local_type" in
                CRITICAL) printf "%b[CRITICAL]%b %s\n" "$ADXC_RED" "$ADXC_RESET" "$local_title" ;;
                WARNING)  printf "%b[WARNING ]%b %s\n" "$ADXC_YELLOW" "$ADXC_RESET" "$local_title" ;;
                *)        printf "%b[INFO    ]%b %s\n" "$ADXC_CYAN" "$ADXC_RESET" "$local_title" ;;
            esac
            [ -n "$local_text" ] && printf "           %s\n" "$local_text"
            [ -n "$local_expires" ] && printf "           Expires: %s\n" "$local_expires"
            printf "\n"
        fi
    done
}
