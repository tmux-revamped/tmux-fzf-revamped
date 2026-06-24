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

# fzf_version_ge A B -> success when the tmux version A is at least B. Compares
# the major and minor numbers, so "3.10" is greater than "3.4". A trailing letter
# such as the "a" in "3.4a" is ignored.
fzf_version_ge() {
  local amaj="${1%%.*}" bmaj="${2%%.*}" amin bmin
  amin="${1#*.}"; amin="${amin%%[!0-9]*}"
  bmin="${2#*.}"; bmin="${bmin%%[!0-9]*}"
  [[ "${amaj}" =~ ^[0-9]+$ ]] || amaj=0
  [[ "${bmaj}" =~ ^[0-9]+$ ]] || bmaj=0
  [[ "${amin}" =~ ^[0-9]+$ ]] || amin=0
  [[ "${bmin}" =~ ^[0-9]+$ ]] || bmin=0
  (( amaj > bmaj )) && return 0
  (( amaj < bmaj )) && return 1
  (( amin >= bmin ))
}

# fzf_supports_popup VERSION -> success when tmux VERSION has display-popup, which
# arrived in tmux 3.2.
fzf_supports_popup() {
  fzf_version_ge "${1}" 3.2
}

# fzf_border_flag VERSION BORDER -> "-b <BORDER>" when tmux VERSION supports the
# display-popup border style (3.4+) and BORDER is a non-empty, non-"none" value;
# empty otherwise so older tmux never receives an unknown flag.
fzf_border_flag() {
  local version="${1}" border="${2}"
  [[ -n "${border}" && "${border}" != "none" ]] || return 0
  fzf_version_ge "${version}" 3.4 || return 0
  printf '%s' "-b ${border}"
}

export -f fzf_id_of
export -f fzf_valid_mode
export -f fzf_version_ge
export -f fzf_supports_popup
export -f fzf_border_flag
