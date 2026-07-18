#!/usr/bin/env bash
adxc_render_message_board() {
    local message_dir="$ADXC_HOME/messages"
    local active_count=0
    local file

    [ -d "$message_dir" ] || return 0

    for file in "$message_dir"/*.msg; do
        [ -f "$file" ] || continue
        active_count=$((active_count + 1))
    done

    adxc_print_section "MESSAGE BOARD ($active_count ACTIVE)"

    if [ "$active_count" -eq 0 ]; then
        echo "No active operational notices."
        return 0
    fi

    for file in "$message_dir"/*.msg; do
        [ -f "$file" ] || continue
        cat "$file"
        echo
    done
}
