#!/usr/bin/env bash
#
# fzf.sh: pure helpers for tmux-fzf-revamped.
#
# The fzf list is built as "<target-id><TAB><display>", so the id survives a
# display column that contains spaces. Extracting the id and validating the mode
# are pure and fixture-tested; the tmux listing, the picker, and the navigation
# are seams in the dispatcher.

[[ -n "${_FZF_REVAMPED_LOADED:-}" ]] && return 0
_FZF_REVAMPED_LOADED=1

# fzf_id_of LINE -> the target id, the text before the first tab.
fzf_id_of() {
  printf '%s' "${1%%$'\t'*}"
}

# fzf_valid_mode MODE -> MODE when it is session, window, or pane; else session.
fzf_valid_mode() {
  case "${1}" in
    session|window|pane) printf '%s' "${1}" ;;
    *) printf '%s' "session" ;;
  esac
}

export -f fzf_id_of
export -f fzf_valid_mode
