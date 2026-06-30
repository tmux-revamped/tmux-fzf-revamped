#!/usr/bin/env bash
#
# fzf-revamped.tmux: TPM entry point.
#
# Binds popup pickers for sessions, windows, and panes, plus pickers for the
# tree view, create-on-miss, URLs, the command palette, the keybinding
# cheatsheet, the process killer, rename, multi-kill, broadcast, zoxide
# directories, last-session toggle, and move-window. Each popup runs the
# dispatcher and acts on the selection.

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
tree_key="$(get_opt "@fzf_revamped_tree_key" "T")"
create_key="$(get_opt "@fzf_revamped_create_key" "C")"
url_key="$(get_opt "@fzf_revamped_url_key" "u")"
palette_key="$(get_opt "@fzf_revamped_palette_key" "O")"
cheatsheet_key="$(get_opt "@fzf_revamped_cheatsheet_key" "/")"
process_key="$(get_opt "@fzf_revamped_process_key" "k")"
rename_key="$(get_opt "@fzf_revamped_rename_key" "R")"
multikill_key="$(get_opt "@fzf_revamped_multikill_key" "K")"
broadcast_key="$(get_opt "@fzf_revamped_broadcast_key" "b")"
zoxide_key="$(get_opt "@fzf_revamped_zoxide_key" "G")"
last_key="$(get_opt "@fzf_revamped_last_key" "L")"
move_key="$(get_opt "@fzf_revamped_move_key" "M")"

if "${FZF_CMD}" supports-popup "${ver}"; then
  bind_picker() {
    # shellcheck disable=SC2086
    tmux bind-key "${1}" display-popup -E ${border_flag} -w "${width}" -h "${height}" "${FZF_CMD} ${2}"
  }
  popup_capable=1
else
  # display-popup needs tmux 3.2; older tmux runs the picker in a new window.
  bind_picker() {
    tmux bind-key "${1}" new-window "${FZF_CMD} ${2}"
  }
  popup_capable=0
fi

bind_picker "${session_key}" "session switch"
bind_picker "${window_key}" "window switch"
bind_picker "${pane_key}" "pane switch"
bind_picker "${kill_key}" "session kill"
bind_picker "${tree_key}" "tree"
bind_picker "${create_key}" "create"
bind_picker "${url_key}" "urls open"
bind_picker "${palette_key}" "palette"
bind_picker "${cheatsheet_key}" "cheatsheet"
bind_picker "${process_key}" "process"
bind_picker "${rename_key}" "rename window"
bind_picker "${multikill_key}" "multi-kill session"
bind_picker "${zoxide_key}" "zoxide"
bind_picker "${move_key}" "move-window move"

# Last-session toggle needs no picker, so it runs without a popup.
tmux bind-key "${last_key}" run-shell "${FZF_CMD} last"

# Broadcast gathers the command first, then opens a multi-select pane picker.
if [[ "${popup_capable}" -eq 1 ]]; then
  # shellcheck disable=SC2086
  tmux bind-key "${broadcast_key}" command-prompt -p "broadcast:" \
    "display-popup -E ${border_flag} -w ${width} -h ${height} '${FZF_CMD} broadcast \"%%\"'"
else
  tmux bind-key "${broadcast_key}" command-prompt -p "broadcast:" \
    "new-window '${FZF_CMD} broadcast \"%%\"'"
fi
