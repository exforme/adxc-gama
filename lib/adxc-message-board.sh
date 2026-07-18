#!/usr/bin/env bash
adxc_render_message_board(){
    local dir="$ADXC_HOME/messages" count=0 file
    [ -d "$dir" ] || return 0
    for file in "$dir"/*.msg; do [ -f "$file" ] || continue; count=$((count+1)); done
    adxc_print_section "MESSAGE BOARD ($count ACTIVE)"
    [ "$count" -eq 0 ] && echo "No active operational notices." && return 0
    for file in "$dir"/*.msg; do [ -f "$file" ] && cat "$file" && echo; done
}
