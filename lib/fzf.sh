#!/bin/sh

[ -n "${FZF_REVAMPED_FZF_LOADED:-}" ] && return 0
FZF_REVAMPED_FZF_LOADED=1

# shellcheck source=SCRIPTDIR/state.sh
. "${REVAMPED_LIB:?}/state.sh"
# shellcheck source=SCRIPTDIR/platform.sh
. "${REVAMPED_LIB}/platform.sh"
# shellcheck source=SCRIPTDIR/command.sh
. "${REVAMPED_LIB}/command.sh"

fzf_revamped_format() {
  printf '%s\n' "${FZF_REVAMPED_SETTINGS}" | awk -F '\t' '{ printf "%s#{@fzf_revamped_%s}", (NR > 1 ? "\t" : ""), $1 }'
}

fzf_revamped_resolve() {
  env | FZF_REVAMPED_ROWS="${FZF_REVAMPED_SETTINGS}" FZF_REVAMPED_LIVE="$1" awk '
    BEGIN {
      count = split(ENVIRON["FZF_REVAMPED_ROWS"], rows, "\n")
      split(ENVIRON["FZF_REVAMPED_LIVE"], live, "\t")
      for (i = 1; i <= count; i++) {
        split(rows[i], field, "\t")
        name[i] = field[1]
        value[i] = (live[i] != "") ? live[i] : field[2]
        want["FZF_REVAMPED_" toupper(field[1])] = i
      }
    }
    {
      at = index($0, "=")
      key = substr($0, 1, at - 1)
      if (key in want) { value[want[key]] = substr($0, at + 1) }
    }
    END { for (i = 1; i <= count; i++) { print name[i] "\t" value[i] } }
  '
}

fzf_revamped_load() {
  fzf_revamped_load_format=$(fzf_revamped_format)
  fzf_revamped_load_live=$(tmux display-message -p "${fzf_revamped_load_format}" 2>/dev/null) || fzf_revamped_load_live=""
  fzf_revamped_load_values=$(fzf_revamped_resolve "${fzf_revamped_load_live}")
  while IFS='	' read -r fzf_revamped_load_name fzf_revamped_load_value; do
    IFS= read -r "FZF_REVAMPED_S_${fzf_revamped_load_name}" <<EOF
${fzf_revamped_load_value}
EOF
  done <<EOF
${fzf_revamped_load_values}
EOF
}

fzf_revamped_parse_version() {
  printf '%s\n' "$1" | sed -En 's/^tmux[ -]([a-z]+-)?([0-9]+\.[0-9]+).*/\2/p'
}

fzf_revamped_version_ge() {
  case "$1:$2" in
  *[!0-9.:]* | :* | *:) return 1 ;;
  *) ;;
  esac
  fzf_revamped_version_ge_have="${1%%.*}"
  fzf_revamped_version_ge_want="${2%%.*}"
  [ "${fzf_revamped_version_ge_have}" -gt "${fzf_revamped_version_ge_want}" ] && return 0
  [ "${fzf_revamped_version_ge_have}" -eq "${fzf_revamped_version_ge_want}" ] || return 1
  fzf_revamped_version_ge_have="${1#*.}"
  fzf_revamped_version_ge_want="${2#*.}"
  [ "${fzf_revamped_version_ge_have%%.*}" -ge "${fzf_revamped_version_ge_want%%.*}" ]
}

fzf_revamped_at_least() {
  [ -z "${FZF_REVAMPED_TMUX}" ] && return 0
  fzf_revamped_version_ge "${FZF_REVAMPED_TMUX}" "$1"
}

fzf_revamped_emit() {
  for fzf_revamped_emit_arg in "$@"; do
    FZF_REVAMPED_PLAN="${FZF_REVAMPED_PLAN}${fzf_revamped_emit_arg}
"
  done
  FZF_REVAMPED_PLAN="${FZF_REVAMPED_PLAN}
"
}

fzf_revamped_send() {
  set --
  fzf_revamped_send_sep=""
  while IFS= read -r fzf_revamped_send_line; do
    if [ -z "${fzf_revamped_send_line}" ]; then
      [ "$#" -eq 0 ] || fzf_revamped_send_sep=";"
      continue
    fi
    [ -z "${fzf_revamped_send_sep}" ] || set -- "$@" "${fzf_revamped_send_sep}"
    fzf_revamped_send_sep=""
    set -- "$@" "${fzf_revamped_send_line}"
  done <<PLAN
${FZF_REVAMPED_PLAN}
PLAN
  [ "$#" -gt 0 ] || return 0
  tmux "$@"
}

fzf_revamped_quote() {
  printf '%s\n' "$1" | sed -e "s/'/'\\\\''/g" -e "s/#/'\"\$(printf '%b' '\\\\0043')\"'/g" -e "1s/^/'/" -e "\$s/\$/'/"
}

fzf_revamped_carried_rows() {
  env | FZF_REVAMPED_ROWS="${FZF_REVAMPED_PICK_NAMES}" awk '
    BEGIN {
      count = split(ENVIRON["FZF_REVAMPED_ROWS"], names, " ")
      for (i = 1; i <= count; i++) { want["FZF_REVAMPED_" toupper(names[i])] = i }
    }
    {
      at = index($0, "=")
      key = substr($0, 1, at - 1)
      if (key in want) { value[want[key]] = substr($0, at + 1) }
    }
    END {
      for (i = 1; i <= count; i++) {
        if (value[i] == "") { continue }
        option = names[i]
        gsub(/_/, "-", option)
        print option "\t" value[i]
      }
    }
  '
}

fzf_revamped_carried() {
  fzf_revamped_carried_out=""
  fzf_revamped_carried_list=$(fzf_revamped_carried_rows)
  while IFS='	' read -r fzf_revamped_carried_name fzf_revamped_carried_value; do
    [ -n "${fzf_revamped_carried_name}" ] || continue
    fzf_revamped_carried_out="${fzf_revamped_carried_out} --${fzf_revamped_carried_name} $(fzf_revamped_quote "${fzf_revamped_carried_value}")"
  done <<EOF
${fzf_revamped_carried_list}
EOF
  printf '%s' "${fzf_revamped_carried_out}"
}

fzf_revamped_tool() {
  fzf_revamped_quote "${REVAMPED_LIB%/lib}/bin/fzf-revamped"
}

fzf_revamped_binding() {
  tmux list-keys -T prefix 2>/dev/null | awk -v key="$1" '{ for (i = 1; i < NF; i++) { if ($i == "-T") { if ($(i + 2) == key) { print } break } } }'
}

fzf_revamped_border() {
  case "${FZF_REVAMPED_S_popup_border}" in
  "" | none) return 0 ;;
  *) : ;;
  esac
  fzf_revamped_at_least 3.4 || return 0
  printf '%s' "${FZF_REVAMPED_S_popup_border}"
}

fzf_revamped_bound() {
  case "$1" in
  "" | off) return 1 ;;
  *) return 0 ;;
  esac
}

fzf_revamped_plan_picker() {
  fzf_revamped_bound "$1" || return 0
  if ! fzf_revamped_at_least 3.2; then
    fzf_revamped_emit bind-key "$1" new-window "${FZF_REVAMPED_TOOL}${FZF_REVAMPED_CARRIED} $2"
    return 0
  fi
  set -- "$1" "$2" bind-key "$1" display-popup -E
  [ -z "${FZF_REVAMPED_BORDER}" ] || set -- "$@" -b "${FZF_REVAMPED_BORDER}"
  set -- "$@" -w "${FZF_REVAMPED_S_popup_width}" -h "${FZF_REVAMPED_S_popup_height}" "${FZF_REVAMPED_TOOL}${FZF_REVAMPED_CARRIED} $2"
  shift 2
  fzf_revamped_emit "$@"
}

fzf_revamped_double() {
  fzf_revamped_double_text=$(printf '%s' "$1" | sed 's/[\\"$]/\\&/g')
  printf '"%s"' "${fzf_revamped_double_text}"
}

fzf_revamped_plan_broadcast() {
  fzf_revamped_bound "${FZF_REVAMPED_S_broadcast_key}" || return 0
  fzf_revamped_plan_broadcast_store="set-option -g ${FZF_REVAMPED_BROADCAST} \"%%%\""
  if ! fzf_revamped_at_least 3.2; then
    fzf_revamped_plan_broadcast_run=$(fzf_revamped_double "${FZF_REVAMPED_TOOL} broadcast")
    fzf_revamped_emit bind-key "${FZF_REVAMPED_S_broadcast_key}" command-prompt -p "broadcast:" "${fzf_revamped_plan_broadcast_store} ; new-window ${fzf_revamped_plan_broadcast_run}"
    return 0
  fi
  fzf_revamped_plan_broadcast_run=$(fzf_revamped_double "${FZF_REVAMPED_TOOL} broadcast")
  fzf_revamped_plan_broadcast_flag=""
  [ -z "${FZF_REVAMPED_BORDER}" ] || fzf_revamped_plan_broadcast_flag=" -b ${FZF_REVAMPED_BORDER}"
  fzf_revamped_emit bind-key "${FZF_REVAMPED_S_broadcast_key}" command-prompt -p "broadcast:" "${fzf_revamped_plan_broadcast_store} ; display-popup -E${fzf_revamped_plan_broadcast_flag} -w ${FZF_REVAMPED_S_popup_width} -h ${FZF_REVAMPED_S_popup_height} ${fzf_revamped_plan_broadcast_run}"
}

fzf_revamped_plan_palette() {
  FZF_REVAMPED_TAKEN=""
  fzf_revamped_bound "${FZF_REVAMPED_S_palette_key}" || return 0
  fzf_revamped_plan_palette_bound=$(fzf_revamped_binding "${FZF_REVAMPED_S_palette_key}")
  # shellcheck disable=SC2034
  case "${fzf_revamped_plan_palette_bound}" in
  "" | *fzf-revamped*) fzf_revamped_plan_picker "${FZF_REVAMPED_S_palette_key}" palette ;;
  *) FZF_REVAMPED_TAKEN="${FZF_REVAMPED_S_palette_key}" ;;
  esac
}

fzf_revamped_plan() {
  fzf_revamped_load
  fzf_revamped_plan_raw=$(tmux -V 2>/dev/null) || fzf_revamped_plan_raw=""
  FZF_REVAMPED_TMUX=$(fzf_revamped_parse_version "${fzf_revamped_plan_raw}")
  FZF_REVAMPED_PLAN=""
  FZF_REVAMPED_TOOL=$(fzf_revamped_tool)
  FZF_REVAMPED_CARRIED=$(fzf_revamped_carried)
  FZF_REVAMPED_BORDER=$(fzf_revamped_border)
  fzf_revamped_plan_picker "${FZF_REVAMPED_S_session_key}" "session switch"
  fzf_revamped_plan_picker "${FZF_REVAMPED_S_window_key}" "window switch"
  fzf_revamped_plan_picker "${FZF_REVAMPED_S_pane_key}" "pane switch"
  fzf_revamped_plan_picker "${FZF_REVAMPED_S_kill_key}" "session kill"
  fzf_revamped_plan_picker "${FZF_REVAMPED_S_tree_key}" tree
  fzf_revamped_plan_picker "${FZF_REVAMPED_S_create_key}" create
  fzf_revamped_plan_picker "${FZF_REVAMPED_S_url_key}" "urls open"
  fzf_revamped_plan_palette
  fzf_revamped_plan_picker "${FZF_REVAMPED_S_cheatsheet_key}" cheatsheet
  fzf_revamped_plan_picker "${FZF_REVAMPED_S_process_key}" process
  fzf_revamped_plan_picker "${FZF_REVAMPED_S_rename_key}" "rename window"
  fzf_revamped_plan_picker "${FZF_REVAMPED_S_multikill_key}" "multi-kill session"
  fzf_revamped_plan_picker "${FZF_REVAMPED_S_zoxide_key}" zoxide
  fzf_revamped_plan_picker "${FZF_REVAMPED_S_move_key}" "move-window move"
  ! fzf_revamped_bound "${FZF_REVAMPED_S_last_key}" || fzf_revamped_emit bind-key "${FZF_REVAMPED_S_last_key}" run-shell "${FZF_REVAMPED_TOOL} last"
  fzf_revamped_plan_broadcast
}

fzf_revamped_apply() {
  fzf_revamped_plan
  fzf_revamped_send 2>/dev/null || fzf_revamped_apply_each
}

fzf_revamped_apply_each() {
  fzf_revamped_apply_each_status=0
  set --
  while IFS= read -r fzf_revamped_apply_each_line; do
    if [ -n "${fzf_revamped_apply_each_line}" ]; then
      set -- "$@" "${fzf_revamped_apply_each_line}"
      continue
    fi
    [ "$#" -gt 0 ] || continue
    tmux "$@" || fzf_revamped_apply_each_status=1
    set --
  done <<PLAN
${FZF_REVAMPED_PLAN}
PLAN
  return "${fzf_revamped_apply_each_status}"
}

fzf_revamped_fzf() {
  fzf --no-sort --reverse --height=100% --delimiter "${FZF_REVAMPED_TAB}" "$@"
}

fzf_revamped_id_of() {
  printf '%s' "${1%%"${FZF_REVAMPED_TAB}"*}"
}

fzf_revamped_valid_mode() {
  case "$1" in
  session | window | pane) printf '%s' "$1" ;;
  *) printf 'session' ;;
  esac
}

fzf_revamped_extract_urls() {
  grep -oE '(https?|ftp|file)://[A-Za-z0-9._~:/?#@!$&'"'"'()*+,;=%-]+' | sed -E 's/[.,;:!?)]+$//' | awk '!seen[$0]++'
}

fzf_revamped_valid_signal() {
  fzf_revamped_valid_signal_name=$(printf '%s' "${1:-TERM}" | tr '[:lower:]' '[:upper:]')
  fzf_revamped_valid_signal_name="${fzf_revamped_valid_signal_name#SIG}"
  case "${fzf_revamped_valid_signal_name}" in
  TERM | KILL | INT | HUP | QUIT | STOP | CONT | USR1 | USR2) printf '%s' "${fzf_revamped_valid_signal_name}" ;;
  *) printf 'TERM' ;;
  esac
}

fzf_revamped_palette_list() {
  printf 'new-window\tnew-window  open a window\n'
  printf 'split-window -h\tsplit-window -h  split right\n'
  printf 'split-window -v\tsplit-window -v  split down\n'
  printf 'next-window\tnext-window  next window\n'
  printf 'previous-window\tprevious-window  previous window\n'
  printf 'last-window\tlast-window  last window\n'
  printf 'kill-pane\tkill-pane  close pane\n'
  printf 'kill-window\tkill-window  close window\n'
  printf 'detach-client\tdetach-client  detach\n'
  printf 'choose-tree\tchoose-tree  built-in tree\n'
}

fzf_revamped_pid_of() {
  printf '%s\n' "$1" | awk '{ print $1; exit }'
}

fzf_revamped_target_kind() {
  case "$1" in
  *.*) printf 'pane' ;;
  *:*) printf 'window' ;;
  *) printf 'session' ;;
  esac
}

fzf_revamped_session_name() {
  fzf_revamped_session_name_path="${1%/}"
  fzf_revamped_session_name_base="${fzf_revamped_session_name_path##*/}"
  [ -n "${fzf_revamped_session_name_base}" ] || fzf_revamped_session_name_base="$1"
  printf '%s\n' "${fzf_revamped_session_name_base}" | sed 's/[.: ]/_/g'
}

fzf_revamped_mru_sort() {
  sort -t "${FZF_REVAMPED_TAB}" -k1,1 -rn | cut -f2-
}

fzf_revamped_targets() {
  case "$1" in
  session) tmux list-sessions -F '#{session_name}	#{session_name}  (#{session_windows} windows)#{?session_attached, *,}' 2>/dev/null ;;
  session-mru) tmux list-sessions -F '#{session_last_attached}	#{session_name}	#{session_name}  (#{session_windows} windows)#{?session_attached, *,}' 2>/dev/null | fzf_revamped_mru_sort ;;
  window) tmux list-windows -a -F '#{session_name}:#{window_index}	#{session_name}:#{window_index}  #{window_name}#{?window_active, *,}' 2>/dev/null ;;
  *) tmux list-panes -a -F '#{session_name}:#{window_index}.#{pane_index}	#{session_name}:#{window_index}.#{pane_index}  #{pane_current_command}' 2>/dev/null ;;
  esac
}

fzf_revamped_items() {
  if [ "$1" = session ] && [ "${FZF_REVAMPED_S_mru}" = on ]; then
    fzf_revamped_targets session-mru
    return 0
  fi
  fzf_revamped_targets "$1"
}

fzf_revamped_goto() {
  case "$1" in
  session) tmux switch-client -t "$2" 2>/dev/null || : ;;
  window) fzf_revamped_goto_window "$2" ;;
  *) fzf_revamped_goto_pane "$2" ;;
  esac
}

fzf_revamped_goto_window() {
  tmux switch-client -t "${1%%:*}" 2>/dev/null || :
  tmux select-window -t "$1" 2>/dev/null || :
}

fzf_revamped_goto_pane() {
  fzf_revamped_goto_window "${1%.*}"
  tmux select-pane -t "$1" 2>/dev/null || :
}

fzf_revamped_kill() {
  case "$1" in
  session) tmux kill-session -t "$2" 2>/dev/null || : ;;
  window) tmux kill-window -t "$2" 2>/dev/null || : ;;
  *) tmux kill-pane -t "$2" 2>/dev/null || : ;;
  esac
}

fzf_revamped_confirm() {
  fzf_revamped_confirm_answer=$(printf 'no\nyes\n' | fzf_revamped_fzf) || fzf_revamped_confirm_answer=""
  [ "${fzf_revamped_confirm_answer}" = yes ]
}

fzf_revamped_preview() {
  [ -n "${1:-}" ] || return 0
  tmux capture-pane -pe -t "$1" 2>/dev/null || :
}

fzf_revamped_pick_one() {
  fzf_revamped_pick_one_items="$1"
  shift
  printf '%s\n' "${fzf_revamped_pick_one_items}" | fzf_revamped_fzf --with-nth 2 "$@" || :
}

fzf_revamped_switcher() {
  fzf_revamped_switcher_mode=$(fzf_revamped_valid_mode "$1")
  fzf_revamped_switcher_items=$(fzf_revamped_items "${fzf_revamped_switcher_mode}")
  [ -n "${fzf_revamped_switcher_items}" ] || return 0
  case "${FZF_REVAMPED_S_preview}" in
  on | 1)
    fzf_revamped_switcher_tool=$(fzf_revamped_tool)
    fzf_revamped_switcher_pick=$(fzf_revamped_pick_one "${fzf_revamped_switcher_items}" --preview "${fzf_revamped_switcher_tool} preview {1}" --preview-window=down:40%)
    ;;
  *) fzf_revamped_switcher_pick=$(fzf_revamped_pick_one "${fzf_revamped_switcher_items}") ;;
  esac
  fzf_revamped_switcher_id=$(fzf_revamped_id_of "${fzf_revamped_switcher_pick}")
  [ -n "${fzf_revamped_switcher_id}" ] || return 0
  if [ "${2:-switch}" = kill ]; then
    fzf_revamped_kill "${fzf_revamped_switcher_mode}" "${fzf_revamped_switcher_id}"
    return 0
  fi
  fzf_revamped_goto "${fzf_revamped_switcher_mode}" "${fzf_revamped_switcher_id}"
}

fzf_revamped_tree() {
  fzf_revamped_tree_items=$(fzf_revamped_targets session && fzf_revamped_targets window && fzf_revamped_targets pane)
  [ -n "${fzf_revamped_tree_items}" ] || return 0
  fzf_revamped_tree_pick=$(fzf_revamped_pick_one "${fzf_revamped_tree_items}")
  fzf_revamped_tree_id=$(fzf_revamped_id_of "${fzf_revamped_tree_pick}")
  [ -n "${fzf_revamped_tree_id}" ] || return 0
  fzf_revamped_tree_kind=$(fzf_revamped_target_kind "${fzf_revamped_tree_id}")
  fzf_revamped_goto "${fzf_revamped_tree_kind}" "${fzf_revamped_tree_id}"
}

fzf_revamped_create() {
  fzf_revamped_create_items=$(fzf_revamped_targets session)
  fzf_revamped_create_out=$(fzf_revamped_pick_one "${fzf_revamped_create_items}" --print-query)
  fzf_revamped_create_query=$(printf '%s\n' "${fzf_revamped_create_out}" | sed -n 1p)
  fzf_revamped_create_pick=$(printf '%s\n' "${fzf_revamped_create_out}" | sed -n 2p)
  if [ -n "${fzf_revamped_create_pick}" ]; then
    fzf_revamped_create_id=$(fzf_revamped_id_of "${fzf_revamped_create_pick}")
    tmux switch-client -t "${fzf_revamped_create_id}" 2>/dev/null || :
    return 0
  fi
  [ -n "${fzf_revamped_create_query}" ] || return 0
  fzf_revamped_create_name=$(fzf_revamped_session_name "${fzf_revamped_create_query}")
  tmux new-session -A -d -s "${fzf_revamped_create_name}" \; switch-client -t "${fzf_revamped_create_name}" 2>/dev/null || :
}

fzf_revamped_opener() {
  if revamped_has_command xdg-open; then
    printf 'xdg-open'
  elif revamped_has_command open; then
    printf 'open'
  fi
}

fzf_revamped_urls() {
  fzf_revamped_urls_text=$(tmux capture-pane -p 2>/dev/null) || fzf_revamped_urls_text=""
  fzf_revamped_urls_list=$(printf '%s\n' "${fzf_revamped_urls_text}" | fzf_revamped_extract_urls)
  [ -n "${fzf_revamped_urls_list}" ] || return 0
  fzf_revamped_urls_pick=$(printf '%s\n' "${fzf_revamped_urls_list}" | fzf_revamped_fzf) || fzf_revamped_urls_pick=""
  [ -n "${fzf_revamped_urls_pick}" ] || return 0
  if [ "${1:-open}" = copy ]; then
    tmux set-buffer -- "${fzf_revamped_urls_pick}"
    return 0
  fi
  fzf_revamped_urls_tool=$(fzf_revamped_opener)
  [ -z "${fzf_revamped_urls_tool}" ] || "${fzf_revamped_urls_tool}" "${fzf_revamped_urls_pick}" >/dev/null 2>&1 || :
}

fzf_revamped_palette() {
  fzf_revamped_palette_items=$(fzf_revamped_palette_list)
  fzf_revamped_palette_pick=$(fzf_revamped_pick_one "${fzf_revamped_palette_items}")
  fzf_revamped_palette_command=$(fzf_revamped_id_of "${fzf_revamped_palette_pick}")
  [ -n "${fzf_revamped_palette_command}" ] || return 0
  set -f
  # shellcheck disable=SC2086
  set -- ${fzf_revamped_palette_command}
  set +f
  tmux "$@" 2>/dev/null || :
}

fzf_revamped_cheatsheet() {
  fzf_revamped_cheatsheet_keys=$(tmux list-keys 2>/dev/null) || fzf_revamped_cheatsheet_keys=""
  [ -n "${fzf_revamped_cheatsheet_keys}" ] || return 0
  printf '%s\n' "${fzf_revamped_cheatsheet_keys}" | fzf_revamped_fzf >/dev/null || :
}

fzf_revamped_process() {
  fzf_revamped_process_signal=$(fzf_revamped_valid_signal "${1:-TERM}")
  fzf_revamped_process_list=$(ps -eo pid=,comm= 2>/dev/null) || fzf_revamped_process_list=""
  [ -n "${fzf_revamped_process_list}" ] || return 0
  fzf_revamped_process_pick=$(printf '%s\n' "${fzf_revamped_process_list}" | fzf_revamped_fzf) || fzf_revamped_process_pick=""
  fzf_revamped_process_pid=$(fzf_revamped_pid_of "${fzf_revamped_process_pick}")
  [ -n "${fzf_revamped_process_pid}" ] || return 0
  fzf_revamped_confirm || return 0
  kill -s "${fzf_revamped_process_signal}" "${fzf_revamped_process_pid}" 2>/dev/null || :
}

fzf_revamped_ask() {
  printf '%s: ' "$1" >&2
  IFS= read -r fzf_revamped_ask_reply || fzf_revamped_ask_reply=""
  printf '%s' "${fzf_revamped_ask_reply}"
}

fzf_revamped_rename() {
  fzf_revamped_rename_mode=window
  [ "${1:-window}" != session ] || fzf_revamped_rename_mode=session
  [ -t 0 ] || fzf_revamped_usage "no ${fzf_revamped_rename_mode} name given"
  fzf_revamped_rename_items=$(fzf_revamped_items "${fzf_revamped_rename_mode}")
  [ -n "${fzf_revamped_rename_items}" ] || return 0
  fzf_revamped_rename_pick=$(fzf_revamped_pick_one "${fzf_revamped_rename_items}")
  fzf_revamped_rename_id=$(fzf_revamped_id_of "${fzf_revamped_rename_pick}")
  [ -n "${fzf_revamped_rename_id}" ] || return 0
  fzf_revamped_rename_name=$(fzf_revamped_ask "New ${fzf_revamped_rename_mode} name")
  [ -n "${fzf_revamped_rename_name}" ] || return 0
  tmux "rename-${fzf_revamped_rename_mode}" -t "${fzf_revamped_rename_id}" -- "${fzf_revamped_rename_name}"
}

fzf_revamped_each() {
  while IFS= read -r fzf_revamped_each_line; do
    fzf_revamped_each_id=$(fzf_revamped_id_of "${fzf_revamped_each_line}")
    [ -z "${fzf_revamped_each_id}" ] || "$@" "${fzf_revamped_each_id}"
  done
}

fzf_revamped_multi_kill() {
  fzf_revamped_multi_kill_mode=$(fzf_revamped_valid_mode "$1")
  fzf_revamped_multi_kill_items=$(fzf_revamped_items "${fzf_revamped_multi_kill_mode}")
  [ -n "${fzf_revamped_multi_kill_items}" ] || return 0
  fzf_revamped_multi_kill_pick=$(fzf_revamped_pick_one "${fzf_revamped_multi_kill_items}" -m)
  [ -n "${fzf_revamped_multi_kill_pick}" ] || return 0
  fzf_revamped_confirm || return 0
  printf '%s\n' "${fzf_revamped_multi_kill_pick}" | fzf_revamped_each fzf_revamped_kill "${fzf_revamped_multi_kill_mode}"
}

fzf_revamped_send_to() {
  tmux send-keys -t "$2" -l -- "$1" \; send-keys -t "$2" Enter 2>/dev/null || :
}

fzf_revamped_broadcast() {
  fzf_revamped_broadcast_text="${1:-}"
  if [ -z "${fzf_revamped_broadcast_text}" ]; then
    fzf_revamped_broadcast_text=$(tmux show-option -gqv "${FZF_REVAMPED_BROADCAST}" 2>/dev/null) || fzf_revamped_broadcast_text=""
    [ -n "${fzf_revamped_broadcast_text}" ] || return 0
    tmux set-option -gu "${FZF_REVAMPED_BROADCAST}"
  fi
  fzf_revamped_broadcast_items=$(fzf_revamped_targets pane)
  [ -n "${fzf_revamped_broadcast_items}" ] || return 0
  fzf_revamped_broadcast_pick=$(fzf_revamped_pick_one "${fzf_revamped_broadcast_items}" -m)
  printf '%s\n' "${fzf_revamped_broadcast_pick}" | fzf_revamped_each fzf_revamped_send_to "${fzf_revamped_broadcast_text}"
}

fzf_revamped_zoxide() {
  fzf_revamped_zoxide_dirs=$(zoxide query -l 2>/dev/null) || fzf_revamped_zoxide_dirs=""
  [ -n "${fzf_revamped_zoxide_dirs}" ] || return 0
  fzf_revamped_zoxide_pick=$(printf '%s\n' "${fzf_revamped_zoxide_dirs}" | fzf_revamped_fzf) || fzf_revamped_zoxide_pick=""
  [ -n "${fzf_revamped_zoxide_pick}" ] || return 0
  fzf_revamped_zoxide_name=$(fzf_revamped_session_name "${fzf_revamped_zoxide_pick}")
  fzf_revamped_zoxide_start=$(printf '%s\n' "${fzf_revamped_zoxide_pick}" | sed 's/#/##/g')
  tmux new-session -A -d -s "${fzf_revamped_zoxide_name}" -c "${fzf_revamped_zoxide_start}" \; switch-client -t "${fzf_revamped_zoxide_name}" 2>/dev/null || :
}

fzf_revamped_last() {
  tmux switch-client -l 2>/dev/null || :
}

fzf_revamped_move_window() {
  [ -t 0 ] || fzf_revamped_usage "no session given"
  fzf_revamped_move_window_items=$(fzf_revamped_targets window)
  [ -n "${fzf_revamped_move_window_items}" ] || return 0
  fzf_revamped_move_window_pick=$(fzf_revamped_pick_one "${fzf_revamped_move_window_items}")
  fzf_revamped_move_window_id=$(fzf_revamped_id_of "${fzf_revamped_move_window_pick}")
  [ -n "${fzf_revamped_move_window_id}" ] || return 0
  fzf_revamped_move_window_verb=move fzf_revamped_move_window_label="Move to session"
  [ "${1:-move}" != link ] || fzf_revamped_move_window_verb=link fzf_revamped_move_window_label="Link to session"
  fzf_revamped_move_window_to=$(fzf_revamped_ask "${fzf_revamped_move_window_label}")
  [ -n "${fzf_revamped_move_window_to}" ] || return 0
  tmux "${fzf_revamped_move_window_verb}-window" -s "${fzf_revamped_move_window_id}" -t "${fzf_revamped_move_window_to}"
}

fzf_revamped_lines() {
  printf '%s' "${FZF_REVAMPED_PLAN}" | awk 'NF == 0 && line != "" { print line; line = ""; next } NF == 0 { next } { line = (line == "" ? $0 : line " " $0) } END { if (line != "") { print line } }'
}

fzf_revamped_json() {
  printf '%s' "${FZF_REVAMPED_PLAN}" | awk '
    function quote(s,    out, i, c) {
      out = ""
      for (i = 1; i <= length(s); i++) {
        c = substr(s, i, 1)
        if (c == "\\") { out = out "\\\\" } else if (c == "\"") { out = out "\\\"" } else { out = out c }
      }
      return "\"" out "\""
    }
    /^$/ { if (args != "") { rows = rows (rows == "" ? "" : ",") "[" args "]" } args = ""; next }
    { args = args (args == "" ? "" : ",") quote($0) }
    END {
      if (args != "") { rows = rows (rows == "" ? "" : ",") "[" args "]" }
      print "{\"bindings\":[" rows "]}"
    }
  '
}

fzf_revamped_bindings() {
  printf '%s' "${FZF_REVAMPED_PLAN}" | awk 'previous == "" && $0 == "bind-key" { count++ } { previous = $0 } END { print count + 0 }'
}

fzf_revamped_setting_name() {
  fzf_revamped_setting_name_raw=$(printf '%s\n' "${1#--}" | tr '-' '_')
  case " ${FZF_REVAMPED_NAMES} " in
  *" ${fzf_revamped_setting_name_raw} "*) printf '%s\n' "${fzf_revamped_setting_name_raw}" ;;
  *) printf '\n' ;;
  esac
}
