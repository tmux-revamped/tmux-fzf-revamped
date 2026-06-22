#!/usr/bin/env bash
#
# fzf.sh: command dispatcher for tmux-fzf-revamped.
#
# Usage: fzf.sh MODE ACTION
#   MODE   = session | window | pane   (default session)
#   ACTION = switch | kill             (default switch)
#
# Lists the chosen objects in fzf and either jumps to or kills the selection.
# Designed to run inside a tmux popup. Every tmux call goes through one _tmux
# seam and the picker through _fzf, so the routing logic is fully testable.

PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# shellcheck source=/dev/null
source "${PLUGIN_DIR}/src/lib/tmux/tmux-ops.sh"
# shellcheck source=/dev/null
source "${PLUGIN_DIR}/src/lib/fzf/fzf.sh"

# Host-probe seams. Tests override these.
_tmux() { tmux "$@" 2>/dev/null; }
_fzf() { fzf --no-sort --reverse --height=100% --delimiter '	' --with-nth 2; }

_list_sessions() { _tmux list-sessions -F "#{session_name}	#{session_name}  (#{session_windows} windows)#{?session_attached, *,}"; }
_list_windows() { _tmux list-windows -a -F "#{session_name}:#{window_index}	#{session_name}:#{window_index}  #{window_name}#{?window_active, *,}"; }
_list_panes() { _tmux list-panes -a -F "#{session_name}:#{window_index}.#{pane_index}	#{session_name}:#{window_index}.#{pane_index}  #{pane_current_command}"; }

_switch_client() { _tmux switch-client -t "${1}"; }
_select_window() { _tmux switch-client -t "${1%%:*}"; _tmux select-window -t "${1}"; }
_select_pane() { _tmux switch-client -t "${1%%:*}"; _tmux select-window -t "${1%.*}"; _tmux select-pane -t "${1}"; }
_kill_session() { _tmux kill-session -t "${1}"; }
_kill_window() { _tmux kill-window -t "${1}"; }
_kill_pane() { _tmux kill-pane -t "${1}"; }

fzf_items() {
  case "${1}" in
    session) _list_sessions ;;
    window)  _list_windows ;;
    pane)    _list_panes ;;
  esac
}

fzf_goto() {
  case "${1}" in
    session) _switch_client "${2}" ;;
    window)  _select_window "${2}" ;;
    pane)    _select_pane "${2}" ;;
  esac
}

fzf_kill() {
  case "${1}" in
    session) _kill_session "${2}" ;;
    window)  _kill_window "${2}" ;;
    pane)    _kill_pane "${2}" ;;
  esac
}

fzf_run() {
  local mode action items selection id
  mode="$(fzf_valid_mode "${1}")"
  action="${2:-switch}"
  items="$(fzf_items "${mode}")"
  [[ -z "${items}" ]] && return 0
  selection="$(printf '%s\n' "${items}" | _fzf)"
  [[ -z "${selection}" ]] && return 0
  id="$(fzf_id_of "${selection}")"
  [[ -z "${id}" ]] && return 0
  if [[ "${action}" == "kill" ]]; then
    fzf_kill "${mode}" "${id}"
  else
    fzf_goto "${mode}" "${id}"
  fi
}

main() {
  fzf_run "${1:-session}" "${2:-switch}"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi
