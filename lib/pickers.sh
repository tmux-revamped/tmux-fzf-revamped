#!/bin/sh

[ -n "${FZF_REVAMPED_PICKERS_LOADED:-}" ] && return 0
FZF_REVAMPED_PICKERS_LOADED=1

# shellcheck source=SCRIPTDIR/fzf.sh
. "${REVAMPED_LIB:?}/fzf.sh"

fzf_revamped_buffers_act() {
  if [ "$1" = delete ]; then
    tmux delete-buffer -b "$2" 2>/dev/null || :
    return 0
  fi
  fzf_revamped_buffers_act_pane=$(tmux display-message -p '#{pane_id}' 2>/dev/null) || fzf_revamped_buffers_act_pane=""
  [ -n "${fzf_revamped_buffers_act_pane}" ] || return 0
  tmux paste-buffer -p -b "$2" -t "${fzf_revamped_buffers_act_pane}" 2>/dev/null || :
}

fzf_revamped_buffers() {
  fzf_revamped_buffers_mode="paste"
  [ "${1:-paste}" != delete ] || fzf_revamped_buffers_mode=delete
  fzf_revamped_buffers_items=$(tmux list-buffers -F '#{buffer_name}	#{buffer_name}  #{buffer_sample}' 2>/dev/null) || fzf_revamped_buffers_items=""
  if [ -z "${fzf_revamped_buffers_items}" ]; then
    fzf_revamped_nothing "no paste buffer yet"
    return 0
  fi
  fzf_revamped_buffers_pick=$(fzf_revamped_pick_one "${fzf_revamped_buffers_items}")
  fzf_revamped_buffers_name=$(fzf_revamped_id_of "${fzf_revamped_buffers_pick}")
  [ -n "${fzf_revamped_buffers_name}" ] || return 0
  fzf_revamped_buffers_act "${fzf_revamped_buffers_mode}" "${fzf_revamped_buffers_name}"
}

fzf_revamped_projects_home() {
  case "$1" in
  \~) printf '%s\n' "${HOME}" ;;
  \~/*) printf '%s/%s\n' "${HOME}" "${1#\~/}" ;;
  *) printf '%s\n' "$1" ;;
  esac
}

fzf_revamped_projects_file() {
  fzf_revamped_projects_file_path="${FZF_REVAMPED_S_projects}"
  [ -n "${fzf_revamped_projects_file_path}" ] || fzf_revamped_projects_file_path="${XDG_CONFIG_HOME:-${HOME}/.config}/fzf-revamped/projects"
  fzf_revamped_projects_home "${fzf_revamped_projects_file_path}"
}

fzf_revamped_projects_expand() {
  fzf_revamped_projects_expand_ifs="${IFS}"
  IFS='
'
  # shellcheck disable=SC2086
  set -- $1
  IFS="${fzf_revamped_projects_expand_ifs}"
  for fzf_revamped_projects_expand_dir in "$@"; do
    [ ! -d "${fzf_revamped_projects_expand_dir}" ] || printf '%s\n' "${fzf_revamped_projects_expand_dir%/}"
  done
}

fzf_revamped_projects_dirs() {
  while IFS= read -r fzf_revamped_projects_dirs_line || [ -n "${fzf_revamped_projects_dirs_line}" ]; do
    case "${fzf_revamped_projects_dirs_line}" in
    "" | "#"*) continue ;;
    *) : ;;
    esac
    fzf_revamped_projects_dirs_line=$(fzf_revamped_projects_home "${fzf_revamped_projects_dirs_line}")
    fzf_revamped_projects_expand "${fzf_revamped_projects_dirs_line}"
  done
}

fzf_revamped_projects_rows() {
  FZF_REVAMPED_RUNNING="$1" awk -F '\t' '
    BEGIN {
      count = split(ENVIRON["FZF_REVAMPED_RUNNING"], names, "\n")
      for (i = 1; i <= count; i++) { running[names[i]] = 1 }
    }
    !seen[$2]++ { print $2 "\t" $1 "  " $2 (($1 in running) ? "  *" : "") "\t" $1 }
  '
}

fzf_revamped_projects_items() {
  [ -r "$1" ] || return 0
  fzf_revamped_projects_items_running=$(tmux list-sessions -F '#{session_name}' 2>/dev/null) || fzf_revamped_projects_items_running=""
  fzf_revamped_projects_dirs <"$1" | fzf_revamped_session_names | fzf_revamped_projects_rows "${fzf_revamped_projects_items_running}"
}

fzf_revamped_projects() {
  fzf_revamped_projects_path=$(fzf_revamped_projects_file)
  fzf_revamped_projects_list=$(fzf_revamped_projects_items "${fzf_revamped_projects_path}")
  if [ -z "${fzf_revamped_projects_list}" ]; then
    fzf_revamped_nothing "no project listed in ${fzf_revamped_projects_path}"
    return 0
  fi
  fzf_revamped_projects_pick=$(fzf_revamped_pick_one "${fzf_revamped_projects_list}")
  fzf_revamped_projects_dir=$(fzf_revamped_id_of "${fzf_revamped_projects_pick}")
  [ -n "${fzf_revamped_projects_dir}" ] || return 0
  fzf_revamped_open_session "${fzf_revamped_projects_pick##*"${FZF_REVAMPED_TAB}"}" "${fzf_revamped_projects_dir}"
}
