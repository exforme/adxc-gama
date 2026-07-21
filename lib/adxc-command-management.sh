#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# aDXC-GAMA Command Management library
# -----------------------------------------------------------------------------
# Command objects live in commands/*.cmd.
# Metadata and implementation are intentionally stored in the same file.
# Supported command types:
#   single-command  - one shell command including parameters
#   external-script - calls a global, profile-local, or absolute script path

# shellcheck source=adxc-common.sh
source "${ADXC_ROOT_DIR}/lib/adxc-common.sh"

adxc_command_management_menu() {
    while true; do
        clear 2>/dev/null || true
        adxc_print_header "aDXC-GAMA ADMINISTRATION - COMMAND MANAGEMENT"
        printf '[1] Create Command\n'
        printf '[2] List Commands\n'
        printf '[3] Attach Command\n'
        printf '[4] Retire Command\n'
        printf '[5] Restore Retired Command\n'
        printf '[0] Back\n'
        printf '\nSelect option: '
        read -r selected_option || return 0

        case "${selected_option}" in
            1) adxc_create_command_wizard; adxc_pause ;;
            2) adxc_list_commands_screen; adxc_pause ;;
            3) adxc_attach_command_wizard; adxc_pause ;;
            4) adxc_retire_command_wizard; adxc_pause ;;
            5) adxc_restore_command_wizard; adxc_pause ;;
            0) return 0 ;;
            *) adxc_print_warning "Invalid option selected."; adxc_pause ;;
        esac
    done
}

adxc_collect_command_files() {
    local command_dir="$1"
    find "${command_dir}" -mindepth 1 -maxdepth 1 -type f -name '*.cmd' -printf '%f\n' 2>/dev/null | sort
}

adxc_create_command_wizard() {
    local command_name_raw
    local command_name
    local command_type_selection
    local command_type
    local command_description
    local command_line
    local script_path
    local confirmation

    clear 2>/dev/null || true
    adxc_print_header "CREATE COMMAND WIZARD"

    printf 'Step 1: Command name\n'
    printf 'Enter command name, for example customer-healthcheck: '
    read -r command_name_raw || return 1
    command_name="$(adxc_sanitize_name "${command_name_raw}")"

    if [[ -z "${command_name}" ]]; then
        adxc_print_error "Command name cannot be empty."
        return 1
    fi

    if [[ -f "${ADXC_COMMANDS_DIR}/${command_name}.cmd" ]]; then
        adxc_print_error "Command ${command_name} already exists."
        return 1
    fi

    if [[ -f "${ADXC_ARCHIVE_COMMANDS_DIR}/${command_name}.cmd" ]]; then
        adxc_print_error "Archived command ${command_name} already exists. Restore it instead."
        return 1
    fi

    printf '\nStep 2: Command type\n\n'
    printf '[1] Single Command   - one shell command including parameters, for example dspmq -x\n'
    printf '[2] External Script  - existing script from scripts/, profiles/<PROFILE>/scripts/, or absolute path\n'
    printf '\nSelect command type: '
    read -r command_type_selection || return 1

    case "${command_type_selection}" in
        1) command_type="single-command" ;;
        2) command_type="external-script" ;;
        *) adxc_print_error "Invalid command type."; return 1 ;;
    esac

    printf '\nStep 3: Description\n'
    printf 'Enter command description: '
    read -r command_description || true

    if [[ "${command_type}" == "single-command" ]]; then
        printf '\nStep 4: Single command line\n'
        printf 'Enter command, parameters are allowed, for example dspmq -x: '
        read -r command_line || return 1
        [[ -n "${command_line}" ]] || { adxc_print_error "Command line cannot be empty."; return 1; }
    else
        printf '\nStep 4: External script path\n'
        printf 'Examples:\n'
        printf '  scripts/customer-healthcheck.sh\n'
        printf '  profiles/TQM1/scripts/local-check.sh\n'
        printf '  /opt/customer/scripts/customer-healthcheck.sh\n\n'
        printf 'Enter script path: '
        read -r script_path || return 1
        [[ -n "${script_path}" ]] || { adxc_print_error "Script path cannot be empty."; return 1; }
    fi

    printf '\nReview\n'
    printf '  Name        : %s\n' "${command_name}"
    printf '  Type        : %s\n' "${command_type}"
    printf '  Description : %s\n' "${command_description:-N/A}"
    if [[ "${command_type}" == "single-command" ]]; then
        printf '  Command     : %s\n' "${command_line}"
    else
        printf '  Script Path : %s\n' "${script_path}"
    fi

    printf '\nCreate this command? Type CREATE to continue: '
    read -r confirmation || return 1
    [[ "${confirmation}" == "CREATE" ]] || { adxc_print_warning "Command creation cancelled."; return 0; }

    if [[ "${command_type}" == "single-command" ]]; then
        adxc_create_single_command "${command_name}" "${command_description}" "${command_line}"
    else
        adxc_create_external_script_command "${command_name}" "${command_description}" "${script_path}"
    fi
}

adxc_create_single_command() {
    local command_name="$1"
    local command_description="$2"
    local command_line="$3"
    local command_file="${ADXC_COMMANDS_DIR}/${command_name}.cmd"

    cat > "${command_file}" <<EOF_COMMAND
#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# aDXC-GAMA command object
# -----------------------------------------------------------------------------
COMMAND_NAME="${command_name}"
COMMAND_TYPE="single-command"
COMMAND_DESCRIPTION="${command_description}"
COMMAND_ENABLED="YES"
COMMAND_STATUS="ACTIVE"
COMMAND_CREATED_BY="$(adxc_current_user)"
COMMAND_CREATED_DATE="$(adxc_current_date)"
COMMAND_ARCHIVED_BY=""
COMMAND_ARCHIVED_DATE=""

# -----------------------------------------------------------------------------
# Command implementation
# -----------------------------------------------------------------------------
COMMAND_LINE='${command_line}'

main() {
    eval "\${COMMAND_LINE}"
}

main "\$@"
EOF_COMMAND

    chmod +x "${command_file}"
    adxc_print_success "Command ${command_name} created."
}

adxc_create_external_script_command() {
    local command_name="$1"
    local command_description="$2"
    local script_path="$3"
    local command_file="${ADXC_COMMANDS_DIR}/${command_name}.cmd"

    cat > "${command_file}" <<EOF_COMMAND
#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# aDXC-GAMA command object
# -----------------------------------------------------------------------------
COMMAND_NAME="${command_name}"
COMMAND_TYPE="external-script"
COMMAND_DESCRIPTION="${command_description}"
COMMAND_ENABLED="YES"
COMMAND_STATUS="ACTIVE"
COMMAND_CREATED_BY="$(adxc_current_user)"
COMMAND_CREATED_DATE="$(adxc_current_date)"
COMMAND_ARCHIVED_BY=""
COMMAND_ARCHIVED_DATE=""

# -----------------------------------------------------------------------------
# Command implementation
# -----------------------------------------------------------------------------
SCRIPT_PATH="${script_path}"

SCRIPT_DIR="\$(cd "\$(dirname "\${BASH_SOURCE[0]}")/.." && pwd)"
ADXC_ROOT_DIR="\${SCRIPT_DIR}"
source "\${ADXC_ROOT_DIR}/lib/adxc-common.sh"

main() {
    local resolved_script
    resolved_script="\$(adxc_relative_to_root "\${SCRIPT_PATH}")"

    if [[ ! -x "\${resolved_script}" ]]; then
        printf 'ERROR: Script is not executable or does not exist: %s\n' "\${resolved_script}" >&2
        exit 1
    fi

    "\${resolved_script}" "\$@"
}

main "\$@"
EOF_COMMAND

    chmod +x "${command_file}"
    adxc_print_success "Command ${command_name} created."
}

adxc_print_command_table() {
    local command_dir="$1"
    local table_title="$2"
    local command_files=()

    printf '%s\n' "${table_title}"
    printf '%-4s %-24s %-17s %-12s %s\n' 'ID' 'COMMAND' 'TYPE' 'STATUS' 'DESCRIPTION'
    printf '%-4s %-24s %-17s %-12s %s\n' '--' '-------' '----' '------' '-----------'

    if [[ ! -d "${command_dir}" ]]; then
        printf 'No commands found.\n'
        return 0
    fi

    mapfile -t command_files < <(adxc_collect_command_files "${command_dir}")

    if [[ "${#command_files[@]}" -eq 0 ]]; then
        printf 'No commands found.\n'
        return 0
    fi

    local index=1
    local command_file_name
    local status_color

    for command_file_name in "${command_files[@]}"; do
        adxc_load_command_file "${command_dir}/${command_file_name}"
        status_color="$(adxc_status_color "${COMMAND_STATUS}")"
        printf '%-4s %-24s %-17s %b%-12s%b %s\n' \
            "${index}" "${COMMAND_NAME}" "${COMMAND_TYPE}" \
            "${status_color}" "${COMMAND_STATUS}" "${ADXC_RESET}" \
            "${COMMAND_DESCRIPTION}"
        index=$((index + 1))
    done
}

adxc_list_commands_screen() {
    clear 2>/dev/null || true
    adxc_print_header "LIST COMMANDS"
    adxc_print_command_table "${ADXC_COMMANDS_DIR}" "ACTIVE AND DISABLED COMMANDS"
    printf '\n'
    adxc_print_command_table "${ADXC_ARCHIVE_COMMANDS_DIR}" "RETIRED COMMANDS"
}

adxc_select_command_file() {
    local prompt_title="$1"
    local command_dir="$2"
    local selected_number
    local command_files=()

    mapfile -t command_files < <(adxc_collect_command_files "${command_dir}")

    if [[ "${#command_files[@]}" -eq 0 ]]; then
        adxc_print_error "No commands found in ${command_dir}."
        return 1
    fi

    printf '%s\n\n' "${prompt_title}"

    local index=1
    local command_file_name

    for command_file_name in "${command_files[@]}"; do
        adxc_load_command_file "${command_dir}/${command_file_name}"
        printf '[%d] %-24s %-17s %s\n' "${index}" "${COMMAND_NAME}" "${COMMAND_TYPE}" "${COMMAND_DESCRIPTION}"
        index=$((index + 1))
    done

    printf '\nSelect command number: '
    read -r selected_number || return 1

    if ! [[ "${selected_number}" =~ ^[0-9]+$ ]]; then
        adxc_print_error "Selection must be a number."
        return 1
    fi

    if (( selected_number < 1 || selected_number > ${#command_files[@]} )); then
        adxc_print_error "Command selection is out of range."
        return 1
    fi

    SELECTED_COMMAND_FILE="${command_dir}/${command_files[$((selected_number - 1))]}"
}

adxc_attach_command_wizard() {
    local profile_dir
    local profile_name
    local command_name
    local link_file
    local confirmation

    clear 2>/dev/null || true
    adxc_print_header "ATTACH COMMAND TO PROFILE"

    adxc_select_active_profile "Select profile" || return 1
    profile_dir="${SELECTED_PROFILE_DIR}"
    adxc_load_profile_config "${profile_dir}"
    profile_name="${PROFILE_NAME}"

    printf '\n'
    adxc_select_command_file "Select command to attach" "${ADXC_COMMANDS_DIR}" || return 1
    adxc_load_command_file "${SELECTED_COMMAND_FILE}"
    command_name="${COMMAND_NAME}"
    link_file="${profile_dir}/commands/${command_name}.link"

    if [[ -f "${link_file}" ]]; then
        adxc_print_warning "Command ${command_name} is already attached to profile ${profile_name}."
        return 0
    fi

    printf '\nAttach command %s to profile %s? Type ATTACH to continue: ' "${command_name}" "${profile_name}"
    read -r confirmation || return 1
    [[ "${confirmation}" == "ATTACH" ]] || { adxc_print_warning "Attach cancelled."; return 0; }

    mkdir -p "${profile_dir}/commands"
    cat > "${link_file}" <<EOF_LINK
# aDXC-GAMA command attachment
COMMAND_NAME="${command_name}"
COMMAND_FILE="commands/${command_name}.cmd"
ATTACHED_BY="$(adxc_current_user)"
ATTACHED_DATE="$(adxc_current_date)"
EOF_LINK

    adxc_print_success "Attached command ${command_name} to profile ${profile_name}."
}

adxc_update_command_state() {
    local command_file="$1"
    local command_enabled="$2"
    local command_status="$3"
    local archived_by="${4:-}"
    local archived_date="${5:-}"

    python3 - "$command_file" "$command_enabled" "$command_status" "$archived_by" "$archived_date" <<'PY_UPDATE'
from pathlib import Path
import sys

path = Path(sys.argv[1])
updates = {
    'COMMAND_ENABLED': sys.argv[2],
    'COMMAND_STATUS': sys.argv[3],
    'COMMAND_ARCHIVED_BY': sys.argv[4],
    'COMMAND_ARCHIVED_DATE': sys.argv[5],
}
text = path.read_text()
for key, value in updates.items():
    found = False
    new_lines = []
    for line in text.splitlines():
        if line.startswith(key + '='):
            new_lines.append(f'{key}="{value}"')
            found = True
        else:
            new_lines.append(line)
    text = '\n'.join(new_lines) + '\n'
    if not found:
        text += f'{key}="{value}"\n'
path.write_text(text)
PY_UPDATE
}

adxc_retire_command_wizard() {
    local selected_action
    local confirmation
    local command_name
    local archive_target

    clear 2>/dev/null || true
    adxc_print_header "RETIRE COMMAND"

    adxc_select_command_file "Select command to retire or delete" "${ADXC_COMMANDS_DIR}" || return 1
    adxc_load_command_file "${SELECTED_COMMAND_FILE}"
    command_name="${COMMAND_NAME}"

    printf '\nCommand selected\n'
    printf '  Name        : %s\n' "${COMMAND_NAME}"
    printf '  Type        : %s\n' "${COMMAND_TYPE}"
    printf '  Status      : %s\n' "${COMMAND_STATUS}"
    printf '  Description : %s\n' "${COMMAND_DESCRIPTION}"

    printf '\nChoose retire mode\n'
    printf '[1] Disable and Archive  - safe, reversible\n'
    printf '[2] Permanent Delete     - destructive, not reversible\n'
    printf '[0] Cancel\n'
    printf '\nSelect option: '
    read -r selected_action || return 1

    case "${selected_action}" in
        1)
            printf '\nType ARCHIVE to disable and archive command %s: ' "${command_name}"
            read -r confirmation || return 1
            [[ "${confirmation}" == "ARCHIVE" ]] || { adxc_print_warning "Archive cancelled."; return 0; }
            archive_target="${ADXC_ARCHIVE_COMMANDS_DIR}/${command_name}.cmd"
            if [[ -f "${archive_target}" ]]; then
                adxc_print_error "Archived command already exists: ${archive_target}"
                return 1
            fi
            adxc_update_command_state "${SELECTED_COMMAND_FILE}" "NO" "ARCHIVED" "$(adxc_current_user)" "$(adxc_current_date)"
            mkdir -p "${ADXC_ARCHIVE_COMMANDS_DIR}"
            mv "${SELECTED_COMMAND_FILE}" "${archive_target}"
            adxc_print_success "Command ${command_name} disabled and archived."
            ;;
        2)
            adxc_print_warning "Permanent delete removes the command file. Existing profile links will become invalid."
            printf 'Type DELETE to permanently delete command %s: ' "${command_name}"
            read -r confirmation || return 1
            [[ "${confirmation}" == "DELETE" ]] || { adxc_print_warning "Permanent delete cancelled."; return 0; }
            rm -f "${SELECTED_COMMAND_FILE}"
            adxc_print_success "Command ${command_name} permanently deleted."
            ;;
        0) adxc_print_warning "Retire cancelled." ;;
        *) adxc_print_error "Invalid option selected."; return 1 ;;
    esac
}

adxc_restore_command_wizard() {
    local command_name
    local restore_target
    local confirmation

    clear 2>/dev/null || true
    adxc_print_header "RESTORE RETIRED COMMAND"

    adxc_select_command_file "Select retired command to restore" "${ADXC_ARCHIVE_COMMANDS_DIR}" || return 1
    adxc_load_command_file "${SELECTED_COMMAND_FILE}"
    command_name="${COMMAND_NAME}"
    restore_target="${ADXC_COMMANDS_DIR}/${command_name}.cmd"

    if [[ -f "${restore_target}" ]]; then
        adxc_print_error "Active command already exists: ${command_name}"
        return 1
    fi

    printf '\nRestore command %s? Type RESTORE to continue: ' "${command_name}"
    read -r confirmation || return 1
    [[ "${confirmation}" == "RESTORE" ]] || { adxc_print_warning "Restore cancelled."; return 0; }

    adxc_update_command_state "${SELECTED_COMMAND_FILE}" "YES" "ACTIVE" "" ""
    mkdir -p "${ADXC_COMMANDS_DIR}"
    mv "${SELECTED_COMMAND_FILE}" "${restore_target}"
    adxc_print_success "Command ${command_name} restored and enabled."
}
