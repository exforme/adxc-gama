#!/usr/bin/env bash
ADXC_HOME="${ADXC_HOME:-/opt/adxc}"; ADXC_MQ_BIN="${ADXC_MQ_BIN:-/opt/mqm/bin}"; ADXC_MQ_USER="${ADXC_MQ_USER:-mqm}"; ADXC_MQMIQM_CONF="${ADXC_MQMIQM_CONF:-/etc/mqmiqm/cluster.conf}"
mq_section(){ printf '\n%s\n%s\n%s\n\n' '============================================================' "$1" '============================================================'; }
mq_error(){ printf 'ERROR: %s\n' "$*" >&2; }; mq_warn(){ printf 'WARNING: %s\n' "$*" >&2; }
mq_load_profile(){ local p="$1" c="$ADXC_HOME/profiles/$p/profile.conf"; [ -f "$c" ] || { mq_error "Profile configuration not found: $c"; return 1; }; . "$c"; ADXC_PROFILE_NAME="${PROFILE_NAME:-$p}"; ADXC_QMGR_NAME="${QMGR_NAME:-$ADXC_PROFILE_NAME}"; ADXC_MQMIQM_CONF="${MQMIQM_CONF:-$ADXC_MQMIQM_CONF}"; }
mq_require_binary(){ [ -x "$ADXC_MQ_BIN/$1" ] || { mq_error "Required MQ binary not found or not executable: $ADXC_MQ_BIN/$1"; return 1; }; }
mq_run_as_mqm(){ local cmd="$1" u; u="$(id -un)"; if [ "$u" = "$ADXC_MQ_USER" ]; then bash -lc "$cmd"; elif [ "$(id -u)" -eq 0 ]; then if command -v runuser >/dev/null 2>&1; then runuser -l "$ADXC_MQ_USER" -c "$cmd"; else su - "$ADXC_MQ_USER" -c "$cmd"; fi; else bash -lc "$cmd"; fi; }
mq_dspmq_x(){ mq_require_binary dspmq || return 1; mq_run_as_mqm "$ADXC_MQ_BIN/dspmq -x -m '$ADXC_QMGR_NAME'"; }
mq_local_mode(){ local t="$1" h; h="$(hostname -s 2>/dev/null || hostname 2>/dev/null || uname -n)"; if printf '%s\n' "$t" | grep -Eiq "INSTANCE\(${h}\).*MODE\(Active\)"; then echo ACTIVE; elif printf '%s\n' "$t" | grep -Eiq "INSTANCE\(${h}\).*MODE\(Standby\)"; then echo STANDBY; elif printf '%s\n' "$t" | grep -Eiq 'STATUS\(Running as standby\)'; then echo STANDBY; elif printf '%s\n' "$t" | grep -Eiq 'STATUS\(Running\)'; then echo ACTIVE; else echo UNKNOWN; fi; }
mq_count_modes(){ printf '%s\n' "$1" | grep -Eic "MODE\($2\)" || true; }
mq_confirm_exact(){ local a; printf '%s' "$2"; read -r a; [ "$a" = "$1" ]; }
