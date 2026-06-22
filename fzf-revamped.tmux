#!/usr/bin/env bash
#
# fzf-revamped.tmux: TPM entry point.
#
# Binds popup pickers for sessions, windows, and panes, plus a session-kill
# picker. Each popup runs the dispatcher and acts on the selection.

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FZF_CMD="${CURRENT_DIR}/src/fzf.sh"

chmod +x "${FZF_CMD}" 2>/dev/null || true

get_opt() {
  local v
  v=$(tmux show-option -gqv "${1}")
  echo "${v:-${2}}"
}

width="$(get_opt "@fzf_revamped_popup_width" "60%")"
height="$(get_opt "@fzf_revamped_popup_height" "50%")"

bind_popup() {
  tmux bind-key "${1}" display-popup -E -w "${width}" -h "${height}" "${FZF_CMD} ${2}"
}

bind_popup "$(get_opt "@fzf_revamped_session_key" "s")" "session switch"
bind_popup "$(get_opt "@fzf_revamped_window_key" "w")" "window switch"
bind_popup "$(get_opt "@fzf_revamped_pane_key" "e")" "pane switch"
bind_popup "$(get_opt "@fzf_revamped_kill_key" "X")" "session kill"
