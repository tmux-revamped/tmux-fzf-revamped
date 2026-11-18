#!/bin/sh

[ -n "${FZF_REVAMPED_ARRANGE_LOADED:-}" ] && return 0
FZF_REVAMPED_ARRANGE_LOADED=1

# shellcheck source=SCRIPTDIR/fzf.sh
. "${REVAMPED_LIB:?}/fzf.sh"

fzf_revamped_arrange_actions() {
  printf 'join\tjoin  bring a pane into this window\n'
  printf 'break\tbreak  move a pane into its own window\n'
  printf 'swap\tswap  swap a pane with this one\n'
  printf 'layout\tlayout  lay this window out\n'
  printf 'resize\tresize  move an edge of this pane\n'
}

fzf_revamped_arrange_valid() {
  case "$1" in
  join | break | swap | layout | resize) printf '%s' "$1" ;;
  *) : ;;
  esac
}

fzf_revamped_arrange_filter() {
  awk -F '\t' -v action="$1" -v pane="$2" -v window="$3" '
    action == "join" && $2 == window { next }
    action == "swap" && $1 == pane { next }
    action == "break" && $3 < 2 { next }
    { print $1 "\t" $4 }
  '
}

fzf_revamped_arrange_panes() {
  tmux list-panes -a -F '#{pane_id}	#{window_id}	#{window_panes}	#{session_name}:#{window_index}.#{pane_index}  #{pane_current_command}' 2>/dev/null | fzf_revamped_arrange_filter "$@"
}

fzf_revamped_arrange_layouts() {
  printf 'even-horizontal\teven-horizontal  side by side\n'
  printf 'even-vertical\teven-vertical  stacked\n'
  printf 'main-horizontal\tmain-horizontal  one large pane on top\n'
  printf 'main-vertical\tmain-vertical  one large pane on the left\n'
  printf 'tiled\ttiled  a grid\n'
  fzf_revamped_at_least "${FZF_REVAMPED_MIRRORED_SINCE}" || return 0
  printf 'main-horizontal-mirrored\tmain-horizontal-mirrored  one large pane at the bottom\n'
  printf 'main-vertical-mirrored\tmain-vertical-mirrored  one large pane on the right\n'
}

fzf_revamped_arrange_sizes() {
  for fzf_revamped_arrange_sizes_side in L:left R:right U:up D:down; do
    for fzf_revamped_arrange_sizes_cells in ${FZF_REVAMPED_RESIZE_STEPS}; do
      printf '%s %s\t%s %s\n' "${fzf_revamped_arrange_sizes_side%%:*}" "${fzf_revamped_arrange_sizes_cells}" "${fzf_revamped_arrange_sizes_side#*:}" "${fzf_revamped_arrange_sizes_cells}"
    done
  done
}

fzf_revamped_arrange_items() {
  case "$1" in
  layout) fzf_revamped_arrange_layouts ;;
  resize) fzf_revamped_arrange_sizes ;;
  *) fzf_revamped_arrange_panes "$@" ;;
  esac
}

fzf_revamped_arrange_pick() {
  [ -n "$1" ] || return 0
  fzf_revamped_arrange_pick_line=$(fzf_revamped_pick_one "$1")
  fzf_revamped_id_of "${fzf_revamped_arrange_pick_line}"
}

fzf_revamped_arrange_break() {
  fzf_revamped_arrange_break_at=$(tmux break-pane -d -P -F '#{session_name}:#{window_index}' -s "$1" 2>/dev/null) || fzf_revamped_arrange_break_at=""
  [ -z "${fzf_revamped_arrange_break_at}" ] || fzf_revamped_goto_window "${fzf_revamped_arrange_break_at}"
}

fzf_revamped_arrange_run() {
  case "$1" in
  join) tmux join-pane -s "$2" -t "$3" 2>/dev/null || : ;;
  swap) tmux swap-pane -s "$2" -t "$3" 2>/dev/null || : ;;
  break) fzf_revamped_arrange_break "$2" ;;
  layout) tmux select-layout -t "$3" "$2" 2>/dev/null || : ;;
  *) tmux resize-pane -t "$3" "-${2%% *}" "${2#* }" 2>/dev/null || : ;;
  esac
}

fzf_revamped_arrange() {
  fzf_revamped_arrange_action=$(fzf_revamped_arrange_valid "${1:-}")
  if [ -z "${fzf_revamped_arrange_action}" ]; then
    fzf_revamped_arrange_list=$(fzf_revamped_arrange_actions)
    fzf_revamped_arrange_action=$(fzf_revamped_arrange_pick "${fzf_revamped_arrange_list}")
  fi
  [ -n "${fzf_revamped_arrange_action}" ] || return 0
  fzf_revamped_arrange_raw=$(tmux -V 2>/dev/null) || fzf_revamped_arrange_raw=""
  FZF_REVAMPED_TMUX=$(fzf_revamped_parse_version "${fzf_revamped_arrange_raw}")
  fzf_revamped_arrange_here=$(tmux display-message -p '#{pane_id}	#{window_id}' 2>/dev/null) || fzf_revamped_arrange_here=""
  fzf_revamped_arrange_pane="${fzf_revamped_arrange_here%%"${FZF_REVAMPED_TAB}"*}"
  [ -n "${fzf_revamped_arrange_pane}" ] || return 0
  fzf_revamped_arrange_list=$(fzf_revamped_arrange_items "${fzf_revamped_arrange_action}" "${fzf_revamped_arrange_pane}" "${fzf_revamped_arrange_here#*"${FZF_REVAMPED_TAB}"}")
  fzf_revamped_arrange_picked=$(fzf_revamped_arrange_pick "${fzf_revamped_arrange_list}")
  [ -n "${fzf_revamped_arrange_picked}" ] || return 0
  fzf_revamped_arrange_run "${fzf_revamped_arrange_action}" "${fzf_revamped_arrange_picked}" "${fzf_revamped_arrange_pane}"
}
