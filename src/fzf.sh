#!/usr/bin/env bash
#
# fzf.sh: command dispatcher for tmux-fzf-revamped.
#
# Usage: fzf.sh SUBCOMMAND [ARGS]
#   <mode> [switch|kill]  pick a session/window/pane and jump to or kill it
#   tree                  one picker across sessions > windows > panes
#   create                pick a session or type a new name to create one
#   urls [open|copy]      pick a URL from the current pane's scrollback
#   palette               run a common tmux command
#   cheatsheet            search the keybinding list
#   process [SIGNAL]      pick a process and send it a signal (confirmed)
#   rename [window|session] pick a target and rename it
#   multi-kill [mode]     mark several objects and kill them (confirmed)
#   broadcast CMD         send CMD to several marked panes
#   zoxide                open or attach a session at a zoxide directory
#   last                  toggle to the last session
#   move-window [move|link] move or link a window into another session
#   preview ID            print a target's pane contents (fzf --preview helper)
#   border-flag / supports-popup  entry-point capability probes
#
# Designed to run inside a tmux popup. Every tmux call goes through one _tmux
# seam, the picker through _fzf, the browser through _open, the directory source
# through _zoxide, the process list through _ps, and the signal send through
# _signal, so all routing is testable without a tmux server, fzf, or side effects.

PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FZF_SELF="${BASH_SOURCE[0]}"

# shellcheck source=/dev/null
source "${PLUGIN_DIR}/src/lib/tmux/tmux-ops.sh"
# shellcheck source=/dev/null
source "${PLUGIN_DIR}/src/lib/fzf/fzf.sh"

# Host-probe seams. Tests override or stub the underlying binary.
_tmux() { tmux "$@" 2>/dev/null; }
_fzf() { fzf --no-sort --reverse --height=100% --delimiter "$(printf '\t')" "$@"; }
_open() { open "$1" 2>/dev/null || xdg-open "$1" 2>/dev/null; }
_zoxide() { zoxide query -l 2>/dev/null; }
_ps() { ps -eo pid=,comm= 2>/dev/null; }
_signal() { kill -s "$1" "$2" 2>/dev/null; }

_list_sessions() { _tmux list-sessions -F "#{session_name}	#{session_name}  (#{session_windows} windows)#{?session_attached, *,}"; }
_list_sessions_mru() { _tmux list-sessions -F "#{session_last_attached}	#{session_name}	#{session_name}  (#{session_windows} windows)#{?session_attached, *,}"; }
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
    session)
      if [[ "$(get_tmux_option @fzf_revamped_mru "")" == "on" ]]; then
        _list_sessions_mru | fzf_mru_sort
      else
        _list_sessions
      fi
      ;;
    window) _list_windows ;;
    pane)   _list_panes ;;
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

# fzf_confirm -> success only when the user picks "yes" in the confirm picker.
fzf_confirm() {
  local ans
  ans="$(printf 'no\nyes\n' | _fzf)"
  [[ "${ans}" == "yes" ]]
}

# fzf_preview ID -> the captured contents of the target's pane, for fzf --preview.
fzf_preview() {
  local id="${1}"
  [[ -z "${id}" ]] && return 0
  _tmux capture-pane -pe -t "${id}"
}

fzf_run() {
  local mode action items selection id preview
  mode="$(fzf_valid_mode "${1}")"
  action="${2:-switch}"
  items="$(fzf_items "${mode}")"
  [[ -z "${items}" ]] && return 0
  preview="$(get_tmux_option @fzf_revamped_preview "")"
  if [[ "${preview}" == "on" || "${preview}" == "1" ]]; then
    selection="$(printf '%s\n' "${items}" | _fzf --with-nth 2 --preview "${FZF_SELF} preview {1}" --preview-window=down:40%)"
  else
    selection="$(printf '%s\n' "${items}" | _fzf --with-nth 2)"
  fi
  [[ -z "${selection}" ]] && return 0
  id="$(fzf_id_of "${selection}")"
  [[ -z "${id}" ]] && return 0
  if [[ "${action}" == "kill" ]]; then
    fzf_kill "${mode}" "${id}"
  else
    fzf_goto "${mode}" "${id}"
  fi
}

# fzf_tree -> one picker spanning sessions, windows, and panes; the id shape
# decides how to jump.
fzf_tree() {
  local items selection id kind
  items="$(_list_sessions; _list_windows; _list_panes)"
  [[ -z "${items}" ]] && return 0
  selection="$(printf '%s\n' "${items}" | _fzf --with-nth 2)"
  [[ -z "${selection}" ]] && return 0
  id="$(fzf_id_of "${selection}")"
  [[ -z "${id}" ]] && return 0
  kind="$(fzf_target_kind "${id}")"
  fzf_goto "${kind}" "${id}"
}

# fzf_create_or_switch -> jump to a picked session, or create and attach a new
# one named after the typed query when nothing matched.
fzf_create_or_switch() {
  local items out query sel id name
  items="$(_list_sessions)"
  out="$(printf '%s\n' "${items}" | _fzf --with-nth 2 --print-query)"
  query="$(printf '%s\n' "${out}" | sed -n '1p')"
  sel="$(printf '%s\n' "${out}" | sed -n '2p')"
  if [[ -n "${sel}" ]]; then
    id="$(fzf_id_of "${sel}")"
    _switch_client "${id}"
  else
    [[ -z "${query}" ]] && return 0
    name="$(fzf_session_name "${query}")"
    _tmux new-session -A -d -s "${name}"
    _switch_client "${name}"
  fi
}

# fzf_urls [open|copy] -> pick a URL from the current pane and open it in the
# browser or copy it to the tmux buffer.
fzf_urls() {
  local action text urls selection
  action="${1:-open}"
  text="$(_tmux capture-pane -p)"
  urls="$(printf '%s\n' "${text}" | fzf_extract_urls)"
  [[ -z "${urls}" ]] && return 0
  selection="$(printf '%s\n' "${urls}" | _fzf)"
  [[ -z "${selection}" ]] && return 0
  if [[ "${action}" == "copy" ]]; then
    _tmux set-buffer "${selection}"
  else
    _open "${selection}"
  fi
}

# fzf_palette -> run a common tmux command picked from a searchable list.
fzf_palette() {
  local selection cmd
  selection="$(fzf_palette_list | _fzf --with-nth 2)"
  [[ -z "${selection}" ]] && return 0
  cmd="$(fzf_id_of "${selection}")"
  # shellcheck disable=SC2086
  _tmux ${cmd}
}

# fzf_cheatsheet -> search the keybinding list as a reference.
fzf_cheatsheet() {
  local keys
  keys="$(_tmux list-keys)"
  [[ -z "${keys}" ]] && return 0
  printf '%s\n' "${keys}" | _fzf
  return 0
}

# fzf_processes [SIGNAL] -> pick a process and, after confirmation, send it a
# signal.
fzf_processes() {
  local sig procs selection pid
  sig="$(fzf_valid_signal "${1:-TERM}")"
  procs="$(_ps)"
  [[ -z "${procs}" ]] && return 0
  selection="$(printf '%s\n' "${procs}" | _fzf)"
  [[ -z "${selection}" ]] && return 0
  pid="$(fzf_pid_of "${selection}")"
  [[ -z "${pid}" ]] && return 0
  fzf_confirm || return 0
  _signal "${sig}" "${pid}"
}

# fzf_rename [window|session] -> pick a target and rename it through a tmux
# command prompt. Panes have no name, so a pane request renames its window.
fzf_rename() {
  local mode items selection id
  mode="$(fzf_valid_mode "${1}")"
  [[ "${mode}" == "pane" ]] && mode="window"
  items="$(fzf_items "${mode}")"
  [[ -z "${items}" ]] && return 0
  selection="$(printf '%s\n' "${items}" | _fzf --with-nth 2)"
  [[ -z "${selection}" ]] && return 0
  id="$(fzf_id_of "${selection}")"
  [[ -z "${id}" ]] && return 0
  if [[ "${mode}" == "session" ]]; then
    _tmux command-prompt -p "New session name:" "rename-session -t '${id}' '%%'"
  else
    _tmux command-prompt -p "New window name:" "rename-window -t '${id}' '%%'"
  fi
}

# fzf_multi_kill [mode] -> mark several objects and, after confirmation, kill
# each.
fzf_multi_kill() {
  local mode items selection line id
  mode="$(fzf_valid_mode "${1}")"
  items="$(fzf_items "${mode}")"
  [[ -z "${items}" ]] && return 0
  selection="$(printf '%s\n' "${items}" | _fzf -m)"
  [[ -z "${selection}" ]] && return 0
  fzf_confirm || return 0
  while IFS= read -r line; do
    [[ -z "${line}" ]] && continue
    id="$(fzf_id_of "${line}")"
    [[ -z "${id}" ]] && continue
    fzf_kill "${mode}" "${id}"
  done <<INNER
${selection}
INNER
}

# fzf_broadcast CMD -> send CMD followed by Enter to several marked panes.
fzf_broadcast() {
  local cmd panes selection line id
  cmd="${1:-}"
  [[ -z "${cmd}" ]] && return 0
  panes="$(_list_panes)"
  [[ -z "${panes}" ]] && return 0
  selection="$(printf '%s\n' "${panes}" | _fzf --with-nth 2 -m)"
  [[ -z "${selection}" ]] && return 0
  while IFS= read -r line; do
    [[ -z "${line}" ]] && continue
    id="$(fzf_id_of "${line}")"
    [[ -z "${id}" ]] && continue
    _tmux send-keys -t "${id}" "${cmd}" Enter
  done <<INNER
${selection}
INNER
}

# fzf_zoxide -> pick a zoxide directory and open or attach a session there.
fzf_zoxide() {
  local dirs selection name
  dirs="$(_zoxide)"
  [[ -z "${dirs}" ]] && return 0
  selection="$(printf '%s\n' "${dirs}" | _fzf)"
  [[ -z "${selection}" ]] && return 0
  name="$(fzf_session_name "${selection}")"
  _tmux new-session -A -d -s "${name}" -c "${selection}"
  _switch_client "${name}"
}

# fzf_last -> toggle to the last session.
fzf_last() { _tmux switch-client -l; }

# fzf_move_window [move|link] -> pick a window and move or link it into another
# session chosen through a tmux command prompt.
fzf_move_window() {
  local action items selection id
  action="${1:-move}"
  items="$(_list_windows)"
  [[ -z "${items}" ]] && return 0
  selection="$(printf '%s\n' "${items}" | _fzf --with-nth 2)"
  [[ -z "${selection}" ]] && return 0
  id="$(fzf_id_of "${selection}")"
  [[ -z "${id}" ]] && return 0
  if [[ "${action}" == "link" ]]; then
    _tmux command-prompt -p "Link to session:" "link-window -s '${id}' -t '%%'"
  else
    _tmux command-prompt -p "Move to session:" "move-window -s '${id}' -t '%%'"
  fi
}

main() {
  case "${1:-}" in
    border-flag)    fzf_border_flag "${2:-}" "${3:-}" ;;
    supports-popup) fzf_supports_popup "${2:-}" ;;
    preview)        fzf_preview "${2:-}" ;;
    tree)           fzf_tree ;;
    create)         fzf_create_or_switch ;;
    urls)           fzf_urls "${2:-open}" ;;
    palette)        fzf_palette ;;
    cheatsheet)     fzf_cheatsheet ;;
    process)        fzf_processes "${2:-TERM}" ;;
    rename)         fzf_rename "${2:-window}" ;;
    multi-kill)     fzf_multi_kill "${2:-session}" ;;
    broadcast)      fzf_broadcast "${2:-}" ;;
    zoxide)         fzf_zoxide ;;
    last)           fzf_last ;;
    move-window)    fzf_move_window "${2:-move}" ;;
    *)              fzf_run "${1:-session}" "${2:-switch}" ;;
  esac
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi
