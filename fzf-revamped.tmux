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
ver="$(tmux -V | sed -E 's/^tmux ([0-9]+\.[0-9]+).*/\1/')"
border_flag="$("${FZF_CMD}" border-flag "${ver}" "$(get_opt "@fzf_revamped_popup_border" "rounded")")"

session_key="$(get_opt "@fzf_revamped_session_key" "s")"
window_key="$(get_opt "@fzf_revamped_window_key" "w")"
pane_key="$(get_opt "@fzf_revamped_pane_key" "e")"
kill_key="$(get_opt "@fzf_revamped_kill_key" "X")"

if "${FZF_CMD}" supports-popup "${ver}"; then
  bind_picker() {
    # shellcheck disable=SC2086
    tmux bind-key "${1}" display-popup -E ${border_flag} -w "${width}" -h "${height}" "${FZF_CMD} ${2}"
  }
else
  # display-popup needs tmux 3.2; older tmux runs the picker in a new window.
  bind_picker() {
    tmux bind-key "${1}" new-window "${FZF_CMD} ${2}"
  }
fi

bind_picker "${session_key}" "session switch"
bind_picker "${window_key}" "window switch"
bind_picker "${pane_key}" "pane switch"
bind_picker "${kill_key}" "session kill"
