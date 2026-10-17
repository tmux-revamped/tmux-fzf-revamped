#!/usr/bin/env bash

[[ -n "${_FZF_REVAMPED_LOADED:-}" ]] && return 0
_FZF_REVAMPED_LOADED=1

fzf_id_of() {
  printf '%s' "${1%%$'\t'*}"
}

fzf_valid_mode() {
  case "${1}" in
    session|window|pane) printf '%s' "${1}" ;;
    *) printf '%s' "session" ;;
  esac
}

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

fzf_supports_popup() {
  fzf_version_ge "${1}" 3.2
}

fzf_border_flag() {
  local version="${1}" border="${2}"
  [[ -n "${border}" && "${border}" != "none" ]] || return 0
  fzf_version_ge "${version}" 3.4 || return 0
  printf '%s' "-b ${border}"
}

fzf_extract_urls() {
  grep -oE '(https?|ftp|file)://[A-Za-z0-9._~:/?#@!$&'\''()*+,;=%-]+' \
    | sed -E 's/[.,;:!?)]+$//' \
    | awk '!seen[$0]++'
}

fzf_valid_signal() {
  local s
  s="$(printf '%s' "${1:-TERM}" | tr 'a-z' 'A-Z')"
  s="${s#SIG}"
  case "${s}" in
    TERM|KILL|INT|HUP|QUIT|STOP|CONT|USR1|USR2) printf '%s' "${s}" ;;
    *) printf '%s' "TERM" ;;
  esac
}

fzf_signal_list() {
  printf 'TERM\tTERM  graceful stop\n'
  printf 'KILL\tKILL  force kill\n'
  printf 'INT\tINT  interrupt\n'
  printf 'HUP\tHUP  hangup or reload\n'
  printf 'QUIT\tQUIT  quit with core\n'
}

fzf_palette_list() {
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

fzf_pid_of() {
  local s="${1}"
  s="${s#"${s%%[![:space:]]*}"}"
  printf '%s' "${s%%[[:space:]]*}"
}

fzf_target_kind() {
  case "${1}" in
    *.*) printf '%s' "pane" ;;
    *:*) printf '%s' "window" ;;
    *)   printf '%s' "session" ;;
  esac
}

fzf_session_name() {
  local p base
  p="${1%/}"
  base="${p##*/}"
  [[ -z "${base}" ]] && base="${1}"
  base="${base//[.: ]/_}"
  printf '%s' "${base}"
}

fzf_mru_sort() {
  sort -t "$(printf '\t')" -k1,1 -rn | cut -f2-
}

export -f fzf_id_of
export -f fzf_valid_mode
export -f fzf_version_ge
export -f fzf_supports_popup
export -f fzf_border_flag
export -f fzf_extract_urls
export -f fzf_valid_signal
export -f fzf_signal_list
export -f fzf_palette_list
export -f fzf_pid_of
export -f fzf_target_kind
export -f fzf_session_name
export -f fzf_mru_sort
