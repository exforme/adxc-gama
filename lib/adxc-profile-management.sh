#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# aDXC-GAMA Profile Management library
# -----------------------------------------------------------------------------
# Profile structure is locked as:
#   profiles/<PROFILE>/profile.conf
#   profiles/<PROFILE>/commands/
#   profiles/<PROFILE>/scripts/
#   profiles/<PROFILE>/logs/

# shellcheck source=adxc-common.sh
source "${ADXC_ROOT_DIR}/lib/adxc-common.sh"

adxc_profile_management_menu() {
    while true; do
        clear 2>/dev/null || true
        adxc_print_header "aDXC-GAMA ADMINISTRATION - PROFILE MANAGEMENT"
        printf '[1] Create Profile\n'
        printf '[2] List Profiles\n'
        printf '[3] Delete Profile\n'
        printf '[4] Restore Archived Profile\n'
        printf '[0] Back\n'
        printf '\nSelect option: '
        read -r selected_option || return 0

        case "${selected_option}" in
            1) adxc_create_profile_wizard; adxc_pause ;;
            2) adxc_list_profiles_screen; adxc_pause ;;
            3) adxc_delete_profile_wizard; adxc_pause ;;
            4) adxc_restore_profile_wizard; adxc_pause ;;
            0) return 0 ;;
            *) adxc_print_warning "Invalid option selected."; adxc_pause ;;
        esac
    done
}

adxc_collect_templates() {
    find "${ADXC_TEMPLATES_DIR}" -mindepth 1 -maxdepth 1 -type d \
        ! -name 'user-home' \
        ! -name 'profile-templates' \
        ! -name 'command-templates' \
        -printf '%f\n' | sort
}

adxc_create_profile_wizard() {
    local templates=()
    local selected_number
    local selected_template
    local profile_name_raw
    local profile_name
    local profile_description
    local confirmation

    clear 2>/dev/null || true
    adxc_print_header "CREATE PROFILE WIZARD"

    mapfile -t templates < <(adxc_collect_templates)

    if [[ "${#templates[@]}" -eq 0 ]]; then
        adxc_print_error "No templates found in ${ADXC_TEMPLATES_DIR}."
        return 1
    fi

    printf 'Step 1: Choose a template\n\n'

    local index=1
    local template_name

    for template_name in "${templates[@]}"; do
        adxc_load_template_config "${template_name}"
        printf '[%d] %-20s %-14s %s\n' \
            "${index}" \
            "${TEMPLATE_NAME}" \
            "${TEMPLATE_CLASS}" \
            "${TEMPLATE_DESCRIPTION}"
        index=$((index + 1))
    done

    printf '\nSelect template number: '
    read -r selected_number || return 1

    if ! [[ "${selected_number}" =~ ^[0-9]+$ ]]; then
        adxc_print_error "Selection must be a number."
        return 1
    fi

    if (( selected_number < 1 || selected_number > ${#templates[@]} )); then
        adxc_print_error "Template selection is out of range."
        return 1
    fi

    selected_template="${templates[$((selected_number - 1))]}"
    adxc_load_template_config "${selected_template}"

    printf '\nTemplate Selected\n'
    printf '  Template    : %s\n' "${TEMPLATE_NAME}"
    printf '  Class       : %s\n' "${TEMPLATE_CLASS}"
    printf '  Description : %s\n' "${TEMPLATE_DESCRIPTION}"

    printf '\nStep 2: Profile name\n'
    printf 'Enter profile name, for example TQM1: '
    read -r profile_name_raw || return 1
    profile_name="$(adxc_sanitize_profile_name "${profile_name_raw}")"

    if [[ -z "${profile_name}" ]]; then
        adxc_print_error "Profile name cannot be empty."
        return 1
    fi

    if [[ -d "${ADXC_PROFILES_DIR}/${profile_name}" ]]; then
        adxc_print_error "Profile ${profile_name} already exists."
        return 1
    fi

    if [[ -d "${ADXC_ARCHIVE_PROFILES_DIR}/${profile_name}" ]]; then
        adxc_print_error "Archived profile ${profile_name} already exists. Restore it instead."
        return 1
    fi

    printf '\nStep 3: Profile description\n'
    printf 'Enter description, or leave empty: '
    read -r profile_description || true

    printf '\nReview\n'
    printf '  Class       : %s\n' "${TEMPLATE_CLASS}"
    printf '  Template    : %s\n' "${TEMPLATE_NAME}"
    printf '  Name        : %s\n' "${profile_name}"
    printf '  Description : %s\n' "${profile_description:-N/A}"

    printf '\nCreate this profile? Type CREATE to continue: '
    read -r confirmation || return 1

    if [[ "${confirmation}" != "CREATE" ]]; then
        adxc_print_warning "Profile creation cancelled."
        return 0
    fi

    adxc_create_profile_from_template \
        "${TEMPLATE_NAME}" \
        "${TEMPLATE_CLASS}" \
        "${profile_name}" \
        "${profile_description}"
}

adxc_create_profile_from_template() {
    local template_name="$1"
    local profile_class="$2"
    local profile_name="$3"
    local profile_description="$4"
    local profile_dir="${ADXC_PROFILES_DIR}/${profile_name}"

    mkdir -p "${profile_dir}"/{commands,scripts,logs}

    cat > "${profile_dir}/profile.conf" <<EOF_PROFILE
# -----------------------------------------------------------------------------
# aDXC-GAMA profile configuration
# -----------------------------------------------------------------------------
PROFILE_NAME="${profile_name}"
PROFILE_CLASS="${profile_class}"
PROFILE_TEMPLATE="${template_name}"
PROFILE_DESCRIPTION="${profile_description}"
PROFILE_ENABLED="YES"
PROFILE_STATUS="ACTIVE"
PROFILE_CREATED_BY="$(adxc_current_user)"
PROFILE_CREATED_DATE="$(adxc_current_date)"
PROFILE_ARCHIVED_BY=""
PROFILE_ARCHIVED_DATE=""
EOF_PROFILE

    printf '# %s attached commands\n' "${profile_name}" > "${profile_dir}/commands/README.md"
    printf '# %s profile-local scripts\n' "${profile_name}" > "${profile_dir}/scripts/README.md"
    printf '# %s runtime logs\n' "${profile_name}" > "${profile_dir}/logs/README.md"

    adxc_print_success "Profile ${profile_name} created as ${profile_class} from template ${template_name}."
}

adxc_print_profile_table() {
    local source_dir="$1"
    local table_title="$2"
    local profile_dirs=()
    local total_profiles=0

    printf '%s\n' "${table_title}"
    printf '%-4s %-14s %-24s %-12s %-18s %s\n' \
        'ID' 'CLASS' 'PROFILE' 'STATUS' 'TEMPLATE' 'DESCRIPTION'
    printf '%-4s %-14s %-24s %-12s %-18s %s\n' \
        '--' '-----' '-------' '------' '--------' '-----------'

    if [[ ! -d "${source_dir}" ]]; then
        printf 'No profiles found.\n'
        return 0
    fi

    mapfile -t profile_dirs < <(find "${source_dir}" -mindepth 1 -maxdepth 1 -type d | sort)

    if [[ "${#profile_dirs[@]}" -eq 0 ]]; then
        printf 'No profiles found.\n'
        return 0
    fi

    local index=1
    local profile_dir
    local status_color

    for profile_dir in "${profile_dirs[@]}"; do
        adxc_load_profile_config "${profile_dir}"
        status_color="$(adxc_status_color "${PROFILE_STATUS}")"
        printf '%-4s %-14s %-24s %b%-12s%b %-18s %s\n' \
            "${index}" "${PROFILE_CLASS}" "${PROFILE_NAME}" \
            "${status_color}" "${PROFILE_STATUS}" "${ADXC_RESET}" \
            "${PROFILE_TEMPLATE}" "${PROFILE_DESCRIPTION}"
        index=$((index + 1))
        total_profiles=$((total_profiles + 1))
    done

    printf '\nTotal Profiles : %d\n' "${total_profiles}"
}

adxc_list_profiles_screen() {
    clear 2>/dev/null || true
    adxc_print_header "LIST PROFILES"
    adxc_print_profile_table "${ADXC_PROFILES_DIR}" "ACTIVE AND DISABLED PROFILES"
    printf '\n'
    adxc_print_profile_table "${ADXC_ARCHIVE_PROFILES_DIR}" "ARCHIVED PROFILES"
}

adxc_select_active_profile() {
    local prompt_title="$1"
    local selected_number
    local profile_dirs=()

    mapfile -t profile_dirs < <(find "${ADXC_PROFILES_DIR}" -mindepth 1 -maxdepth 1 -type d | sort)

    if [[ "${#profile_dirs[@]}" -eq 0 ]]; then
        adxc_print_error "No active profiles found."
        return 1
    fi

    printf '%s\n\n' "${prompt_title}"

    local index=1
    local profile_dir

    for profile_dir in "${profile_dirs[@]}"; do
        adxc_load_profile_config "${profile_dir}"
        printf '[%d] %-14s %s\n' "${index}" "${PROFILE_CLASS}" "${PROFILE_NAME}"
        index=$((index + 1))
    done

    printf '\nSelect profile number: '
    read -r selected_number || return 1

    if ! [[ "${selected_number}" =~ ^[0-9]+$ ]]; then
        adxc_print_error "Selection must be a number."
        return 1
    fi

    if (( selected_number < 1 || selected_number > ${#profile_dirs[@]} )); then
        adxc_print_error "Profile selection is out of range."
        return 1
    fi

    SELECTED_PROFILE_DIR="${profile_dirs[$((selected_number - 1))]}"
}

adxc_update_profile_state() {
    local profile_dir="$1"
    local profile_enabled="$2"
    local profile_status="$3"
    local archived_by="${4:-}"
    local archived_date="${5:-}"
    local profile_config

    adxc_load_profile_config "${profile_dir}"
    profile_config="$(adxc_profile_config_path "${profile_dir}")"

    cat > "${profile_config}.tmp" <<EOF_STATE
# -----------------------------------------------------------------------------
# aDXC-GAMA profile configuration
# -----------------------------------------------------------------------------
PROFILE_NAME="${PROFILE_NAME}"
PROFILE_CLASS="${PROFILE_CLASS}"
PROFILE_TEMPLATE="${PROFILE_TEMPLATE}"
PROFILE_DESCRIPTION="${PROFILE_DESCRIPTION}"
PROFILE_ENABLED="${profile_enabled}"
PROFILE_STATUS="${profile_status}"
PROFILE_CREATED_BY="${PROFILE_CREATED_BY}"
PROFILE_CREATED_DATE="${PROFILE_CREATED_DATE}"
PROFILE_ARCHIVED_BY="${archived_by}"
PROFILE_ARCHIVED_DATE="${archived_date}"
EOF_STATE
    mv "${profile_config}.tmp" "${profile_config}"
}

adxc_archive_profile() {
    local profile_dir="$1"
    local profile_name
    local archive_target

    adxc_load_profile_config "${profile_dir}"
    profile_name="${PROFILE_NAME}"
    archive_target="${ADXC_ARCHIVE_PROFILES_DIR}/${profile_name}"

    if [[ -d "${archive_target}" ]]; then
        adxc_print_error "Archived profile already exists: ${archive_target}"
        return 1
    fi

    adxc_update_profile_state "${profile_dir}" "NO" "ARCHIVED" "$(adxc_current_user)" "$(adxc_current_date)"
    mkdir -p "${ADXC_ARCHIVE_PROFILES_DIR}"
    mv "${profile_dir}" "${archive_target}"
    adxc_print_success "Profile ${profile_name} disabled and archived."
}

adxc_delete_profile_wizard() {
    local selected_action
    local confirmation
    local profile_dir
    local profile_name

    clear 2>/dev/null || true
    adxc_print_header "DELETE PROFILE"
    adxc_select_active_profile "Select profile to delete or archive" || return 1

    profile_dir="${SELECTED_PROFILE_DIR}"
    adxc_load_profile_config "${profile_dir}"
    profile_name="${PROFILE_NAME}"

    printf '\nProfile selected\n'
    printf '  Class       : %s\n' "${PROFILE_CLASS}"
    printf '  Name        : %s\n' "${PROFILE_NAME}"
    printf '  Template    : %s\n' "${PROFILE_TEMPLATE}"
    printf '  Status      : %s\n' "${PROFILE_STATUS}"
    printf '  Description : %s\n' "${PROFILE_DESCRIPTION}"

    printf '\nChoose delete mode\n'
    printf '[1] Disable and Archive  - safe, reversible\n'
    printf '[2] Permanent Delete     - destructive, not reversible\n'
    printf '[0] Cancel\n'
    printf '\nSelect option: '
    read -r selected_action || return 1

    case "${selected_action}" in
        1)
            printf '\nType ARCHIVE to disable and archive profile %s: ' "${profile_name}"
            read -r confirmation || return 1
            [[ "${confirmation}" == "ARCHIVE" ]] || { adxc_print_warning "Archive cancelled."; return 0; }
            adxc_archive_profile "${profile_dir}"
            ;;
        2)
            adxc_print_warning "Permanent delete removes profile configuration, attached command links, scripts and logs."
            printf 'Type DELETE to permanently delete profile %s: ' "${profile_name}"
            read -r confirmation || return 1
            [[ "${confirmation}" == "DELETE" ]] || { adxc_print_warning "Permanent delete cancelled."; return 0; }
            rm -rf "${profile_dir}"
            adxc_print_success "Profile ${profile_name} permanently deleted."
            ;;
        0) adxc_print_warning "Delete cancelled." ;;
        *) adxc_print_error "Invalid option selected."; return 1 ;;
    esac
}

adxc_restore_profile_wizard() {
    local archived_profiles=()
    local selected_number
    local archived_profile_dir
    local profile_name
    local restore_target
    local confirmation

    clear 2>/dev/null || true
    adxc_print_header "RESTORE ARCHIVED PROFILE"

    mapfile -t archived_profiles < <(find "${ADXC_ARCHIVE_PROFILES_DIR}" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | sort)

    if [[ "${#archived_profiles[@]}" -eq 0 ]]; then
        adxc_print_warning "No archived profiles found."
        return 0
    fi

    local index=1
    local profile_dir

    for profile_dir in "${archived_profiles[@]}"; do
        adxc_load_profile_config "${profile_dir}"
        printf '[%d] %-14s %s\n' "${index}" "${PROFILE_CLASS}" "${PROFILE_NAME}"
        index=$((index + 1))
    done

    printf '\nSelect archived profile number: '
    read -r selected_number || return 1

    if ! [[ "${selected_number}" =~ ^[0-9]+$ ]]; then
        adxc_print_error "Selection must be a number."
        return 1
    fi

    if (( selected_number < 1 || selected_number > ${#archived_profiles[@]} )); then
        adxc_print_error "Profile selection is out of range."
        return 1
    fi

    archived_profile_dir="${archived_profiles[$((selected_number - 1))]}"
    adxc_load_profile_config "${archived_profile_dir}"
    profile_name="${PROFILE_NAME}"
    restore_target="${ADXC_PROFILES_DIR}/${profile_name}"

    if [[ -d "${restore_target}" ]]; then
        adxc_print_error "Active profile already exists: ${profile_name}"
        return 1
    fi

    printf '\nRestore profile %s? Type RESTORE to continue: ' "${profile_name}"
    read -r confirmation || return 1
    [[ "${confirmation}" == "RESTORE" ]] || { adxc_print_warning "Restore cancelled."; return 0; }

    adxc_update_profile_state "${archived_profile_dir}" "YES" "ACTIVE" "" ""
    mkdir -p "${ADXC_PROFILES_DIR}"
    mv "${archived_profile_dir}" "${restore_target}"
    adxc_print_success "Profile ${profile_name} restored and enabled."
}
