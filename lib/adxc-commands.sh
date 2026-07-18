#!/usr/bin/env bash
adxc_command_file(){ printf '%s/profiles/%s/commands/%s.cmd' "$ADXC_HOME" "$1" "$2"; }
adxc_register_command(){
    local profile command_name command_type command_payload command_file
    profile="$(adxc_safe_name "$1")"; command_name="$(adxc_safe_name "$2")"; command_type="$(adxc_safe_name "${3:-single-command}")"; command_payload="$4"
    adxc_profile_exists "$profile" || { adxc_error "Profile not found: $profile"; return 1; }
    mkdir -p "$ADXC_HOME/profiles/$profile/commands"; command_file="$(adxc_command_file "$profile" "$command_name")"
    cat > "$command_file" <<EOF
COMMAND_NAME="$command_name"
COMMAND_TYPE="$command_type"
COMMAND_PAYLOAD="$command_payload"
COMMAND_DESCRIPTION="Custom command registered to $profile"
COMMAND_ENABLED="YES"
EOF
    chmod 644 "$command_file"; adxc_ok "Command registered: $profile/$command_name"
}
adxc_delete_command(){ local f; f="$(adxc_command_file "$1" "$2")"; [ -f "$f" ] || { adxc_error "Command not found: $1/$2"; return 1; }; rm -f "$f"; adxc_ok "Command deleted: $1/$2"; }
adxc_list_commands_for_profile(){
    local profile="$1" file
    [ -d "$ADXC_HOME/profiles/$profile/commands" ] || return 0
    for file in "$ADXC_HOME/profiles/$profile/commands"/*.cmd; do [ -f "$file" ] || continue; COMMAND_NAME="$(basename "$file" .cmd)"; COMMAND_ENABLED="YES"; . "$file"; [ "$COMMAND_ENABLED" = "YES" ] && printf '%s\n' "$COMMAND_NAME"; done | sort
}
adxc_list_command_registry(){
    local profile file
    printf "%-16s %-22s %-16s %s\n" "PROFILE" "COMMAND" "TYPE" "PAYLOAD"
    printf "%-16s %-22s %-16s %s\n" "-------" "-------" "----" "-------"
    while read -r profile; do
        [ -n "$profile" ] || continue
        for file in "$ADXC_HOME/profiles/$profile/commands"/*.cmd; do
            [ -f "$file" ] || continue
            COMMAND_NAME="$(basename "$file" .cmd)"; COMMAND_TYPE="single-command"; COMMAND_PAYLOAD=""; COMMAND_ENABLED="YES"; . "$file"
            [ "$COMMAND_ENABLED" = "YES" ] && printf "%-16s %-22s %-16s %s\n" "$profile" "$COMMAND_NAME" "$COMMAND_TYPE" "$COMMAND_PAYLOAD"
        done
    done < <(adxc_list_profile_names)
}
adxc_execute_command(){
    local request="$1" profile command_name file script_path
    case "$request" in */*) profile="${request%%/*}"; command_name="${request#*/}";; *) adxc_error "Use PROFILE/COMMAND format"; return 1;; esac
    file="$(adxc_command_file "$profile" "$command_name")"; [ -f "$file" ] || { adxc_error "Command not found: $profile/$command_name"; return 1; }
    COMMAND_TYPE="single-command"; COMMAND_PAYLOAD=""; COMMAND_ENABLED="YES"; . "$file"
    [ "$COMMAND_ENABLED" = "YES" ] || { adxc_error "Command disabled: $profile/$command_name"; return 1; }
    adxc_print_section "RUN $profile/$command_name"
    case "$COMMAND_TYPE" in
        single-command|command-pipeline) bash -lc "$COMMAND_PAYLOAD" ;;
        local-script) script_path="${COMMAND_PAYLOAD%% *}"; [ -x "$script_path" ] || { adxc_error "Local script is not executable: $script_path"; return 1; }; bash -lc "$COMMAND_PAYLOAD" ;;
        *) adxc_warn "Command type registered but not executed in this release: $COMMAND_TYPE"; printf '%s\n' "$COMMAND_PAYLOAD" ;;
    esac
}
