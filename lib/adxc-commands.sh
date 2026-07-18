#!/usr/bin/env bash
adxc_command_file() { printf '%s/profiles/%s/commands/%s.cmd' "$ADXC_HOME" "$1" "$2"; }

adxc_list_commands_for_profile() {
    local profile="$1"
    local file

    [ -d "$ADXC_HOME/profiles/$profile/commands" ] || return 0

    for file in "$ADXC_HOME/profiles/$profile/commands"/*.cmd; do
        [ -f "$file" ] || continue
        COMMAND_NAME="$(basename "$file" .cmd)"
        COMMAND_ENABLED="YES"
        . "$file"
        [ "$COMMAND_ENABLED" = "YES" ] && printf '%s\n' "$COMMAND_NAME"
    done | sort
}

adxc_list_command_registry() {
    local profile file

    printf "%-24s %-22s %-16s %s\n" "PROFILE" "COMMAND" "TYPE" "PAYLOAD"
    printf "%-24s %-22s %-16s %s\n" "-------" "-------" "----" "-------"

    while read -r profile; do
        [ -n "$profile" ] || continue
        for file in "$ADXC_HOME/profiles/$profile/commands"/*.cmd; do
            [ -f "$file" ] || continue
            COMMAND_NAME="$(basename "$file" .cmd)"
            COMMAND_TYPE="single-command"
            COMMAND_PAYLOAD=""
            COMMAND_ENABLED="YES"
            . "$file"
            [ "$COMMAND_ENABLED" = "YES" ] && printf "%-24s %-22s %-16s %s\n" "$profile" "$COMMAND_NAME" "$COMMAND_TYPE" "$COMMAND_PAYLOAD"
        done
    done < <(adxc_list_profile_names)
}

adxc_execute_command() {
    local request="$1"
    local profile command_name file script_path

    case "$request" in
        */*) profile="${request%%/*}"; command_name="${request#*/}" ;;
        *) adxc_error "Use PROFILE/COMMAND format"; return 1 ;;
    esac

    file="$(adxc_command_file "$profile" "$command_name")"
    [ -f "$file" ] || { adxc_error "Command not found: $profile/$command_name"; return 1; }

    COMMAND_TYPE="single-command"
    COMMAND_PAYLOAD=""
    COMMAND_ENABLED="YES"
    . "$file"

    [ "$COMMAND_ENABLED" = "YES" ] || { adxc_error "Command disabled: $profile/$command_name"; return 1; }

    adxc_print_section "RUN $profile/$command_name"

    case "$COMMAND_TYPE" in
        single-command|command-pipeline)
            bash -lc "$COMMAND_PAYLOAD"
            ;;
        local-script)
            script_path="${COMMAND_PAYLOAD%% *}"
            [ -x "$script_path" ] || { adxc_error "Local script is not executable: $script_path"; return 1; }
            bash -lc "$COMMAND_PAYLOAD"
            ;;
        *)
            adxc_warn "Command type registered but not executed in this release: $COMMAND_TYPE"
            printf '%s\n' "$COMMAND_PAYLOAD"
            ;;
    esac
}
