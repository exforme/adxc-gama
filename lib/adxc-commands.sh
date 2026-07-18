#!/usr/bin/env bash

# Purpose:
#   Command registry and execution helpers.

adxc_command_file() {
    printf '%s/profiles/%s/commands/%s.cmd' "$ADXC_HOME" "$1" "$2"
}

adxc_register_command() {
    local profile="$1"
    local command_name="$2"
    local command_type="$3"
    local command_payload="$4"
    local command_file

    profile="$(adxc_safe_name "$profile")"
    command_name="$(adxc_safe_name "$command_name")"
    command_type="$(adxc_safe_name "$command_type")"

    [ -n "$profile" ] || { adxc_error "Profile is required"; return 1; }
    [ -n "$command_name" ] || { adxc_error "Command name is required"; return 1; }
    [ -n "$command_type" ] || command_type="single-command"

    if ! adxc_profile_exists "$profile"; then
        adxc_error "Profile not found: $profile"
        return 1
    fi

    mkdir -p "$ADXC_HOME/profiles/$profile/commands"
    command_file="$(adxc_command_file "$profile" "$command_name")"

    cat > "$command_file" <<EOF
COMMAND_NAME="$command_name"
COMMAND_TYPE="$command_type"
COMMAND_PAYLOAD="$command_payload"
COMMAND_DESCRIPTION="Custom command registered to $profile"
COMMAND_ENABLED="YES"
EOF

    chmod 644 "$command_file"
    adxc_ok "Command registered: $profile/$command_name"
}

adxc_delete_command() {
    local profile="$1"
    local command_name="$2"
    local command_file

    profile="$(adxc_safe_name "$profile")"
    command_name="$(adxc_safe_name "$command_name")"
    command_file="$(adxc_command_file "$profile" "$command_name")"

    [ -f "$command_file" ] || { adxc_error "Command not found: $profile/$command_name"; return 1; }
    rm -f "$command_file"
    adxc_ok "Command deleted: $profile/$command_name"
}

adxc_list_commands_for_profile() {
    local profile="$1"
    local file command_name

    [ -d "$ADXC_HOME/profiles/$profile/commands" ] || return 0

    for file in "$ADXC_HOME/profiles/$profile/commands"/*.cmd; do
        [ -f "$file" ] || continue
        COMMAND_NAME="$(basename "$file" .cmd)"
        COMMAND_ENABLED="YES"
        # shellcheck disable=SC1090
        . "$file"
        [ "$COMMAND_ENABLED" = "YES" ] || continue
        command_name="$COMMAND_NAME"
        printf '%s\n' "$command_name"
    done | sort
}

adxc_list_command_registry() {
    local profile command file

    printf "%-16s %-20s %-18s %s\n" "PROFILE" "COMMAND" "TYPE" "PAYLOAD"
    printf "%-16s %-20s %-18s %s\n" "-------" "-------" "----" "-------"

    while read -r profile; do
        [ -n "$profile" ] || continue
        for file in "$ADXC_HOME/profiles/$profile/commands"/*.cmd; do
            [ -f "$file" ] || continue
            COMMAND_NAME="$(basename "$file" .cmd)"
            COMMAND_TYPE="single-command"
            COMMAND_PAYLOAD=""
            COMMAND_ENABLED="YES"
            # shellcheck disable=SC1090
            . "$file"
            [ "$COMMAND_ENABLED" = "YES" ] || continue
            printf "%-16s %-20s %-18s %s\n" "$profile" "$COMMAND_NAME" "$COMMAND_TYPE" "$COMMAND_PAYLOAD"
        done
    done < <(adxc_list_profile_names)
}

adxc_execute_command() {
    local request="$1"
    local profile command_name command_file

    case "$request" in
        */*)
            profile="${request%%/*}"
            command_name="${request#*/}"
            ;;
        *)
            adxc_error "Use PROFILE/COMMAND format, for example: TQM1/readiness"
            return 1
            ;;
    esac

    profile="$(adxc_safe_name "$profile")"
    command_name="$(adxc_safe_name "$command_name")"
    command_file="$(adxc_command_file "$profile" "$command_name")"

    [ -f "$command_file" ] || { adxc_error "Command not found: $profile/$command_name"; return 1; }

    COMMAND_NAME="$command_name"
    COMMAND_TYPE="single-command"
    COMMAND_PAYLOAD=""
    COMMAND_ENABLED="YES"
    # shellcheck disable=SC1090
    . "$command_file"

    [ "$COMMAND_ENABLED" = "YES" ] || { adxc_error "Command disabled: $profile/$command_name"; return 1; }

    adxc_print_section "RUN $profile/$command_name"

    case "$COMMAND_TYPE" in
        single-command|command-pipeline)
            bash -lc "$COMMAND_PAYLOAD"
            ;;
        local-script)
            if [ -x "$COMMAND_PAYLOAD" ]; then
                "$COMMAND_PAYLOAD"
            else
                adxc_error "Local script is not executable: $COMMAND_PAYLOAD"
                return 1
            fi
            ;;
        script-package)
            adxc_warn "Script package execution is registered but not automated in this release candidate"
            printf "%s\n" "$COMMAND_PAYLOAD"
            ;;
        remote-script)
            adxc_warn "Remote script execution is intentionally not implemented in this release candidate"
            printf "%s\n" "$COMMAND_PAYLOAD"
            ;;
        menu-wrapper)
            adxc_warn "Menu wrapper execution is registered but not implemented in this release candidate"
            printf "%s\n" "$COMMAND_PAYLOAD"
            ;;
        *)
            adxc_error "Unknown command type: $COMMAND_TYPE"
            return 1
            ;;
    esac
}
