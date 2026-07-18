#!/usr/bin/env bash

# Purpose:
#   Manage and discover operational profiles.

adxc_profile_dir() {
    printf '%s/profiles/%s' "$ADXC_HOME" "$1"
}

adxc_profile_conf() {
    printf '%s/profile.conf' "$(adxc_profile_dir "$1")"
}

adxc_profile_exists() {
    [ -f "$(adxc_profile_conf "$1")" ]
}

adxc_load_profile_conf() {
    local profile="$1"
    PROFILE_NAME="$profile"
    PROFILE_TEMPLATE="custom_empty"
    PROFILE_DESCRIPTION="Custom operational profile"
    PROFILE_ENABLED="YES"

    if [ -f "$(adxc_profile_conf "$profile")" ]; then
        # shellcheck disable=SC1090
        . "$(adxc_profile_conf "$profile")"
    fi
}

adxc_profile_allowed() {
    local profile="$1"
    local allowed_list="${ADXC_ACTIVE_PROFILES:-}"
    local item

    [ -z "$allowed_list" ] && return 0

    IFS=',' read -r -a allowed_items <<< "$allowed_list"
    for item in "${allowed_items[@]}"; do
        item="$(echo "$item" | xargs)"
        [ "$item" = "$profile" ] && return 0
    done

    return 1
}

adxc_list_profile_names() {
    local profile_dir="$ADXC_HOME/profiles"
    local profile_path profile

    [ -d "$profile_dir" ] || return 0

    for profile_path in "$profile_dir"/*; do
        [ -d "$profile_path" ] || continue
        profile="$(basename "$profile_path")"
        adxc_load_profile_conf "$profile"
        [ "${PROFILE_ENABLED:-YES}" = "YES" ] || continue
        adxc_profile_allowed "$profile" || continue
        printf '%s\n' "$profile"
    done | sort
}

adxc_list_profiles_table() {
    local profile

    printf "%-16s %-18s %s\n" "PROFILE" "TEMPLATE" "DESCRIPTION"
    printf "%-16s %-18s %s\n" "-------" "--------" "-----------"

    while read -r profile; do
        [ -n "$profile" ] || continue
        adxc_load_profile_conf "$profile"
        printf "%-16s %-18s %s\n" "$PROFILE_NAME" "$PROFILE_TEMPLATE" "$PROFILE_DESCRIPTION"
    done < <(adxc_list_profile_names)
}

adxc_create_profile() {
    local profile="$1"
    local template="$2"
    local description="$3"
    local profile_dir

    profile="$(adxc_safe_name "$profile")"
    template="$(adxc_safe_name "$template")"
    [ -n "$profile" ] || { adxc_error "Profile name is required"; return 1; }
    [ -n "$template" ] || template="custom_empty"
    [ -n "$description" ] || description="Operational profile created from $template"

    profile_dir="$(adxc_profile_dir "$profile")"

    if [ -e "$profile_dir" ]; then
        adxc_error "Profile already exists: $profile"
        return 1
    fi

    mkdir -p "$profile_dir/commands"

    cat > "$profile_dir/profile.conf" <<EOF
PROFILE_NAME="$profile"
PROFILE_TEMPLATE="$template"
PROFILE_DESCRIPTION="$description"
PROFILE_ENABLED="YES"
EOF

    case "$template" in
        linux)
            adxc_register_command "$profile" "summary" "single-command" "uname -a"
            adxc_register_command "$profile" "filesystem" "single-command" "df -h"
            adxc_register_command "$profile" "memory" "single-command" "free -m"
            ;;
        mq_miqm)
            adxc_register_command "$profile" "summary" "single-command" "dspmq -x"
            adxc_register_command "$profile" "readiness" "single-command" "dspmq -x"
            adxc_register_command "$profile" "health" "single-command" "dspmq"
            ;;
        mq_standalone)
            adxc_register_command "$profile" "summary" "single-command" "dspmq"
            adxc_register_command "$profile" "health" "single-command" "dspmq"
            ;;
        other_middleware|dynatrace)
            adxc_register_command "$profile" "summary" "single-command" "echo Profile summary placeholder for $profile"
            adxc_register_command "$profile" "health" "single-command" "echo Health placeholder for $profile"
            ;;
        custom_empty)
            :
            ;;
    esac

    adxc_ok "Profile created: $profile"
}

adxc_delete_profile() {
    local profile="$1"
    local profile_dir

    profile="$(adxc_safe_name "$profile")"
    profile_dir="$(adxc_profile_dir "$profile")"

    [ -d "$profile_dir" ] || { adxc_error "Profile not found: $profile"; return 1; }

    if find "$profile_dir/commands" -type f -name '*.cmd' 2>/dev/null | grep -q .; then
        adxc_error "Profile has commands. Delete commands first: $profile"
        return 1
    fi

    rm -rf "$profile_dir"
    adxc_ok "Profile deleted: $profile"
}

adxc_profile_menu() {
    local profile="$1"
    local command
    local index=1

    adxc_load_profile_conf "$profile"
    adxc_print_section "PROFILE : $PROFILE_NAME"
    printf "Template : %s\n" "$PROFILE_TEMPLATE"
    printf "Purpose  : %s\n\n" "$PROFILE_DESCRIPTION"
    printf "Available Commands:\n\n"

    while read -r command; do
        [ -n "$command" ] || continue
        printf "[%d] %s\n" "$index" "$command"
        index=$((index + 1))
    done < <(adxc_list_commands_for_profile "$profile")

    printf "\nRun with:\n"
    printf "  adxc-cmd %s/<command>\n" "$profile"
}
