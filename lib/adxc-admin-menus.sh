#!/usr/bin/env bash

# Purpose:
#   Administration menus and wizards for aDXC-GAMA.

adxc_list_templates() {
    local kind="$1"
    local template_dir="$ADXC_HOME/templates/$kind"
    local template_path template

    [ -d "$template_dir" ] || return 0

    for template_path in "$template_dir"/*; do
        [ -d "$template_path" ] || continue
        template="$(basename "$template_path")"
        printf '%s\n' "$template"
    done | sort
}

adxc_choose_from_list() {
    local prompt="$1"
    local item index choice selected
    shift
    local items=("$@")

    index=1
    for item in "${items[@]}"; do
        printf "[%d] %s\n" "$index" "$item"
        index=$((index + 1))
    done

    printf "%s" "$prompt"
    read -r choice

    case "$choice" in
        ''|*[!0-9]*) return 1 ;;
    esac

    selected="${items[$((choice - 1))]:-}"
    [ -n "$selected" ] || return 1
    printf '%s\n' "$selected"
}

adxc_admin_show_main_menu() {
    adxc_print_section "GAMA ADMINISTRATION"

    cat <<'EOF'
[1] Profile Management
[2] Command Management
[3] Message Board Management
[4] User Runtime Management
[q] Quit
EOF
}

adxc_admin_profile_management() {
    local choice

    while true; do
        adxc_print_section "PROFILE MANAGEMENT"
        cat <<'EOF'
Profile = Operational entity created from template.

[1] List Available Profile Templates
[2] List Profiles
[3] Create Profile Wizard
[4] Delete Profile
[b] Back
EOF
        printf "Select: "
        read -r choice
        case "$choice" in
            1) adxc_admin_list_profile_templates ;;
            2) adxc_print_section "CONFIGURED PROFILES"; adxc_list_profiles_table ;;
            3) adxc_admin_create_profile_wizard ;;
            4) adxc_admin_delete_profile_wizard ;;
            b|B) return 0 ;;
            *) adxc_warn "Unknown selection: $choice" ;;
        esac
        printf "\nPress ENTER to continue..."
        read -r _
    done
}

adxc_admin_list_profile_templates() {
    local t conf name desc

    adxc_print_section "AVAILABLE PROFILE TEMPLATES"
    printf "%-20s %-24s %s\n" "TEMPLATE" "NAME" "DESCRIPTION"
    printf "%-20s %-24s %s\n" "--------" "----" "-----------"

    while read -r t; do
        [ -n "$t" ] || continue
        TEMPLATE_ID="$t"
        TEMPLATE_NAME="$t"
        TEMPLATE_DESCRIPTION=""
        conf="$ADXC_HOME/templates/profiles/$t/template.conf"
        [ -f "$conf" ] && . "$conf"
        name="$TEMPLATE_NAME"
        desc="$TEMPLATE_DESCRIPTION"
        printf "%-20s %-24s %s\n" "$t" "$name" "$desc"
    done < <(adxc_list_templates profiles)
}

adxc_admin_create_profile_wizard() {
    local templates selected template profile description
    mapfile -t templates < <(adxc_list_templates profiles)

    adxc_print_section "CREATE PROFILE WIZARD"
    selected="$(adxc_choose_from_list "Select template: " "${templates[@]}")" || { adxc_warn "Invalid template selection"; return 1; }
    template="$selected"

    printf "Profile name: "
    read -r profile
    profile="$(adxc_safe_name "$profile")"
    [ -n "$profile" ] || { adxc_error "Profile name is required"; return 1; }

    printf "Description [optional]: "
    read -r description
    [ -n "$description" ] || description="Operational profile created from $template"

    printf "\nPreview:\n"
    printf "  Template   : %s\n" "$template"
    printf "  Profile    : %s\n" "$profile"
    printf "  Description: %s\n" "$description"
    printf "\nCreate profile? [y/N]: "
    read -r confirm

    case "$confirm" in
        y|Y|yes|YES) adxc_create_profile "$profile" "$template" "$description" ;;
        *) adxc_warn "Profile creation cancelled" ;;
    esac
}

adxc_admin_delete_profile_wizard() {
    local profile

    adxc_print_section "DELETE PROFILE"
    adxc_list_profiles_table
    printf "\nProfile to delete: "
    read -r profile
    profile="$(adxc_safe_name "$profile")"
    [ -n "$profile" ] || { adxc_error "Profile name is required"; return 1; }
    printf "Type DELETE to confirm removal of %s: " "$profile"
    read -r confirm
    [ "$confirm" = "DELETE" ] || { adxc_warn "Delete cancelled"; return 0; }
    adxc_delete_profile "$profile"
}

adxc_admin_command_management() {
    local choice

    while true; do
        adxc_print_section "COMMAND MANAGEMENT"
        cat <<'EOF'
Command = Action available inside profile.
Custom Command = Additional action registered to profile.

[1] List Command Templates
[2] List Commands
[3] Create Command Wizard
[4] Attach Command To Profile
[5] Delete Command
[b] Back
EOF
        printf "Select: "
        read -r choice
        case "$choice" in
            1) adxc_admin_list_command_templates ;;
            2) adxc_print_section "COMMAND REGISTRY"; adxc_list_command_registry ;;
            3) adxc_admin_create_command_wizard ;;
            4) adxc_admin_attach_command_wizard ;;
            5) adxc_admin_delete_command_wizard ;;
            b|B) return 0 ;;
            *) adxc_warn "Unknown selection: $choice" ;;
        esac
        printf "\nPress ENTER to continue..."
        read -r _
    done
}

adxc_admin_list_command_templates() {
    adxc_print_section "AVAILABLE COMMAND TEMPLATES"
    adxc_list_templates commands
}

adxc_admin_create_command_wizard() {
    local templates selected command_type profile command_name payload profiles selected_profile
    mapfile -t templates < <(adxc_list_templates commands)
    mapfile -t profiles < <(adxc_list_profile_names)

    adxc_print_section "CREATE COMMAND WIZARD"

    selected="$(adxc_choose_from_list "Select command template: " "${templates[@]}")" || { adxc_warn "Invalid command template"; return 1; }
    command_type="$selected"

    selected_profile="$(adxc_choose_from_list "Attach to profile: " "${profiles[@]}")" || { adxc_warn "Invalid profile selection"; return 1; }
    profile="$selected_profile"

    printf "Command name: "
    read -r command_name
    command_name="$(adxc_safe_name "$command_name")"
    [ -n "$command_name" ] || { adxc_error "Command name is required"; return 1; }

    case "$command_type" in
        single-command) printf "Command line: " ;;
        command-pipeline) printf "Pipeline: " ;;
        local-script) printf "Executable script path: " ;;
        script-package) printf "Package entry point or path: " ;;
        remote-script) printf "Remote execution descriptor: " ;;
        menu-wrapper) printf "Menu descriptor: " ;;
        *) printf "Payload: " ;;
    esac
    read -r payload
    [ -n "$payload" ] || { adxc_error "Command payload is required"; return 1; }

    printf "\nPreview:\n"
    printf "  Profile : %s\n" "$profile"
    printf "  Command : %s\n" "$command_name"
    printf "  Type    : %s\n" "$command_type"
    printf "  Payload : %s\n" "$payload"
    printf "\nCreate command? [y/N]: "
    read -r confirm

    case "$confirm" in
        y|Y|yes|YES) adxc_register_command "$profile" "$command_name" "$command_type" "$payload" ;;
        *) adxc_warn "Command creation cancelled" ;;
    esac
}

adxc_admin_attach_command_wizard() {
    local source_profile command_name target_profile command_file command_type payload profiles commands

    adxc_print_section "ATTACH COMMAND TO PROFILE"
    mapfile -t profiles < <(adxc_list_profile_names)

    source_profile="$(adxc_choose_from_list "Source profile: " "${profiles[@]}")" || { adxc_warn "Invalid source profile"; return 1; }
    mapfile -t commands < <(adxc_list_commands_for_profile "$source_profile")
    command_name="$(adxc_choose_from_list "Command to attach: " "${commands[@]}")" || { adxc_warn "Invalid command"; return 1; }
    target_profile="$(adxc_choose_from_list "Target profile: " "${profiles[@]}")" || { adxc_warn "Invalid target profile"; return 1; }

    command_file="$(adxc_command_file "$source_profile" "$command_name")"
    COMMAND_TYPE="single-command"
    COMMAND_PAYLOAD=""
    # shellcheck disable=SC1090
    . "$command_file"

    adxc_register_command "$target_profile" "$command_name" "$COMMAND_TYPE" "$COMMAND_PAYLOAD"
}

adxc_admin_delete_command_wizard() {
    local profiles profile commands command_name

    adxc_print_section "DELETE COMMAND"
    mapfile -t profiles < <(adxc_list_profile_names)
    profile="$(adxc_choose_from_list "Profile: " "${profiles[@]}")" || { adxc_warn "Invalid profile"; return 1; }
    mapfile -t commands < <(adxc_list_commands_for_profile "$profile")
    command_name="$(adxc_choose_from_list "Command: " "${commands[@]}")" || { adxc_warn "Invalid command"; return 1; }

    printf "Type DELETE to remove %s/%s: " "$profile" "$command_name"
    read -r confirm
    [ "$confirm" = "DELETE" ] || { adxc_warn "Delete cancelled"; return 0; }
    adxc_delete_command "$profile" "$command_name"
}
