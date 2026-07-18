#!/usr/bin/env bash
adxc_profile_dir() { printf '%s/profiles/%s' "$ADXC_HOME" "$1"; }
adxc_profile_conf() { printf '%s/profile.conf' "$(adxc_profile_dir "$1")"; }
adxc_profile_exists() { [ -f "$(adxc_profile_conf "$1")" ]; }

adxc_load_profile_conf() {
    local profile="$1"
    PROFILE_NAME="$profile"
    PROFILE_TEMPLATE="custom_empty"
    PROFILE_DESCRIPTION="Custom operational profile"
    PROFILE_ENABLED="YES"
    [ -f "$(adxc_profile_conf "$profile")" ] && . "$(adxc_profile_conf "$profile")"
}

adxc_profile_allowed() {
    local profile="$1"
    local list="${ADXC_ACTIVE_PROFILES:-}"
    local item

    [ -z "$list" ] && return 0

    IFS=',' read -r -a items <<< "$list"
    for item in "${items[@]}"; do
        item="$(echo "$item" | xargs)"
        [ "$item" = "$profile" ] && return 0
    done

    return 1
}

adxc_list_profile_names() {
    local path profile
    [ -d "$ADXC_HOME/profiles" ] || return 0

    for path in "$ADXC_HOME/profiles"/*; do
        [ -d "$path" ] || continue
        profile="$(basename "$path")"
        adxc_load_profile_conf "$profile"
        [ "${PROFILE_ENABLED:-YES}" = "YES" ] || continue
        adxc_profile_allowed "$profile" || continue
        printf '%s\n' "$profile"
    done | sort
}

adxc_list_profiles_table() {
    local profile
    printf "%-24s %-20s %s\n" "PROFILE" "TEMPLATE" "DESCRIPTION"
    printf "%-24s %-20s %s\n" "-------" "--------" "-----------"

    while read -r profile; do
        [ -n "$profile" ] || continue
        adxc_load_profile_conf "$profile"
        printf "%-24s %-20s %s\n" "$PROFILE_NAME" "$PROFILE_TEMPLATE" "$PROFILE_DESCRIPTION"
    done < <(adxc_list_profile_names)
}

adxc_profile_menu() {
    local profile="$1"
    local command
    local index=1

    adxc_load_profile_conf "$profile"
    adxc_print_section "PROFILE : $PROFILE_NAME"

    printf "Template : %s\n" "$PROFILE_TEMPLATE"
    printf "Purpose  : %s\n\n" "$PROFILE_DESCRIPTION"

    if [ "$PROFILE_TEMPLATE" = "mq_miqm" ]; then
        cat <<MENU
[1] Control             Operations affecting MQ availability
[2] Troubleshooting     Diagnostics, logs and health checks
[3] Checks              MQ object inspection and runtime data
[4] Maintenance         Backup, export and housekeeping
[5] Custom Commands     Profile-specific extensions

Run Control Menu:
  adxc-cmd $profile/control
MENU
    else
        printf "Available Commands:\n\n"
        while read -r command; do
            [ -n "$command" ] || continue
            printf "[%d] %s\n" "$index" "$command"
            index=$((index + 1))
        done < <(adxc_list_commands_for_profile "$profile")
    fi
}
