#!/usr/bin/env bash
ADXC_HOME="${ADXC_HOME:-/opt/adxc}"; . "$ADXC_HOME/lib/adxc-mq-miqm-common.sh"
miqm_control_menu(){ local p="$1" c; mq_load_profile "$p" || return 1; while true; do mq_section "$ADXC_PROFILE_NAME - CONTROL"; cat <<'MENU'
Cluster Operations

[1] Cluster Status      Run MIQM healthcheck and cluster summary
[2] Readiness Check     Validate failover readiness

Node Control

[3] Start Node          Start local instance with standby permitted
[4] Stop Node           Stop only if local node is standby/passive
[5] Manual Failover     Controlled failover from active to standby

[b] Back
[q] Exit
MENU
printf '\nSelect: '; read -r c; case "$c" in 1) miqm_cluster_status "$p";; 2) miqm_readiness_check "$p";; 3) miqm_start_node "$p";; 4) miqm_stop_node "$p";; 5) miqm_manual_failover "$p";; b|B) return 0;; q|Q) exit 0;; *) mq_warn "Unknown selection: $c";; esac; printf '\nPress ENTER to continue...'; read -r _; done; }
miqm_cluster_status(){ local p="$1"; mq_load_profile "$p" || return 1; mq_section "$ADXC_PROFILE_NAME - CLUSTER STATUS"; ADXC_MQMIQM_CONF="$ADXC_MQMIQM_CONF" "$ADXC_HOME/bin/adxc-miqm-healthcheck"; }
miqm_readiness_check(){ local p="$1" out a s ready=YES; mq_load_profile "$p" || return 1; mq_section "$ADXC_PROFILE_NAME - READINESS CHECK"; out="$(mq_dspmq_x 2>&1)"; a="$(mq_count_modes "$out" Active)"; s="$(mq_count_modes "$out" Standby)"; [ "$a" -ne 1 ] && ready=NO; [ "$s" -lt 1 ] && ready=NO; printf '%-28s %s\n' "Queue manager" "$ADXC_QMGR_NAME"; printf '%-28s %s\n' "Active instances" "$a"; printf '%-28s %s\n' "Standby instances" "$s"; printf '\nFAILOVER_READY=%s\n' "$ready"; }
miqm_start_node(){ local p="$1"; mq_load_profile "$p" || return 1; mq_require_binary strmqm || return 1; mq_section "$ADXC_PROFILE_NAME - START NODE"; printf 'Command:\n  strmqm -x %s\n\n' "$ADXC_QMGR_NAME"; mq_confirm_exact START "Type START to continue: " || { mq_warn "Start cancelled"; return 0; }; mq_run_as_mqm "$ADXC_MQ_BIN/strmqm -x '$ADXC_QMGR_NAME'"; }
miqm_stop_node(){ local p="$1" out mode; mq_load_profile "$p" || return 1; mq_require_binary endmqm || return 1; mq_section "$ADXC_PROFILE_NAME - STOP NODE"; out="$(mq_dspmq_x 2>&1)"; mode="$(mq_local_mode "$out")"; printf '%s\n\nLocal role detected: %s\n\n' "$out" "$mode"; case "$mode" in STANDBY) printf 'Command:\n  endmqm -x %s\n\n' "$ADXC_QMGR_NAME"; mq_confirm_exact STOP "Type STOP to stop local standby instance: " || { mq_warn "Stop cancelled"; return 0; }; mq_run_as_mqm "$ADXC_MQ_BIN/endmqm -x '$ADXC_QMGR_NAME'";; ACTIVE) mq_warn "This node is ACTIVE. Use Manual Failover."; return 1;; *) mq_error "Cannot determine local standby role. Refusing to stop."; return 1;; esac; }
miqm_manual_failover(){ local p="$1" out mode s; mq_load_profile "$p" || return 1; mq_require_binary endmqm || return 1; mq_section "$ADXC_PROFILE_NAME - MANUAL FAILOVER"; out="$(mq_dspmq_x 2>&1)"; mode="$(mq_local_mode "$out")"; s="$(mq_count_modes "$out" Standby)"; printf '%s\n\nLocal role      : %s\nStandby count   : %s\n\n' "$out" "$mode" "$s"; [ "$mode" = ACTIVE ] || { mq_error "Manual failover must be executed from ACTIVE node."; return 1; }; [ "$s" -ge 1 ] || { mq_error "No standby instance detected."; return 1; }; printf 'Command:\n  endmqm -s %s\n\n' "$ADXC_QMGR_NAME"; mq_confirm_exact FAILOVER "Type FAILOVER to continue: " || { mq_warn "Failover cancelled"; return 0; }; mq_run_as_mqm "$ADXC_MQ_BIN/endmqm -s '$ADXC_QMGR_NAME'"; }
