#!/usr/bin/env bash

# Purpose:
#   Render the aDXC-GAMA dashboard consistently.

adxc_render_header() {
    local version host_name user_name profile_indicator

    version="$(adxc_version)"
    host_name="$(adxc_hostname)"
    user_name="${USER:-$(id -un)}"
    profile_indicator="${ADXC_ACTIVE_PROFILES:-all-profiles}"

    printf "%s\n" "============================================================"
    printf "                 %bDXC OPERATIONS CONSOLE%b\n" "$ADXC_GREEN$ADXC_BOLD" "$ADXC_RESET"
    printf "%s\n\n" "============================================================"

    printf "%b[%s]%b %s@%s v%s | %s\n" \
        "$ADXC_CYAN" "${ADXC_ROLE:-SUPPORT}" "$ADXC_RESET" \
        "$user_name" "$host_name" "$version" "$profile_indicator"
}

adxc_render_profiles() {
    local index=1
    local profile

    adxc_print_section "PROFILES"

    while read -r profile; do
        [ -n "$profile" ] || continue
        adxc_load_profile_conf "$profile"
        printf "[%d] %-10s %s\n" "$index" "$PROFILE_NAME" "$PROFILE_DESCRIPTION"
        index=$((index + 1))
    done < <(adxc_list_profile_names)

    if [ "$index" -eq 1 ]; then
        printf "No profiles available. Use adxc-admin -> Profile Management.\n"
    fi
}

adxc_render_dashboard() {
    adxc_load_user_config
    adxc_render_header
    adxc_render_message_board
    adxc_render_profiles

    adxc_print_section "TOOLS"
    printf "%b%-20s%b %s\n" "$ADXC_GREEN" "adxc-help" "$ADXC_RESET" "Quick help"
    printf "%b%-20s%b %s\n" "$ADXC_GREEN" "adxc-help --list-all" "$ADXC_RESET" "List all commands available for this user"
    printf "%b%-20s%b %s\n" "$ADXC_GREEN" "adxc-cmd --list" "$ADXC_RESET" "Command registry"
    printf "%b%-20s%b %s\n" "$ADXC_GREEN" "adxc <profile>" "$ADXC_RESET" "Open profile navigation prototype"

    adxc_print_section "ADMINISTRATION"
    printf "%b%-20s%b %s\n" "$ADXC_GREEN" "adxc-admin" "$ADXC_RESET" "Framework administration console"
}

adxc_interactive_profile_menu() {
    local choice profile index selected

    while true; do
        adxc_render_dashboard
        printf "\nSelect profile number or q to quit: "
        read -r choice
        case "$choice" in
            q|Q) return 0 ;;
            ''|*[!0-9]*) adxc_warn "Invalid selection" ;;
            *)
                index=1
                selected=""
                while read -r profile; do
                    [ -n "$profile" ] || continue
                    if [ "$index" -eq "$choice" ]; then
                        selected="$profile"
                        break
                    fi
                    index=$((index + 1))
                done < <(adxc_list_profile_names)

                if [ -n "$selected" ]; then
                    adxc_profile_menu "$selected"
                    printf "\nPress ENTER to return..."
                    read -r _
                else
                    adxc_warn "Profile number not found"
                fi
                ;;
        esac
    done
}
