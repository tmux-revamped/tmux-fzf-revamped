#!/usr/bin/env bats
# shellcheck disable=SC2016,SC2030,SC2031,SC2034

# shellcheck source=test/helpers.bash
source "${BATS_TEST_DIRNAME:-.}/helpers.bash"

setup() {
  harness_setup
  for name in $(compgen -v FZF_REVAMPED_); do
    unset "${name}"
  done
}

option() {
  printf '%s' "$2" >"${REVAMPED_TEST_TMUX_DIR}/$(printf '%s' "g.-.@fzf_revamped_$1" | tr -c 'A-Za-z0-9_.-' '_')"
}

plan_at() {
  export REVAMPED_TEST_TMUX_VERSION="$1"
  lib_run fzf 'fzf_revamped_plan; fzf_revamped_lines'
}

refuse() {
  mkdir -p "${BATS_TEST_TMPDIR}/stubs"
  printf '#!/bin/sh\nfor a in "$@"; do [ "$a" != ";" ] || exit 1; [ "$a" != BAD ] || { printf "unknown key: BAD\\n" >&2; exit 1; }; done\nexec "%s/bin/tmux" "$@"\n' "${REVAMPED_TESTS_DIR}" >"${BATS_TEST_TMPDIR}/stubs/tmux"
  chmod +x "${BATS_TEST_TMPDIR}/stubs/tmux"
}

@test "fzf - the id is the text before the tab, or the whole line" {
  # Arrange
  local script='printf "[%s]" "$(fzf_revamped_id_of "$(printf "work:1\twork:1  vim")")" "$(fzf_revamped_id_of plain)"'

  # Act
  lib_run fzf "${script}"

  # Assert
  [[ "${output}" == "[work:1][plain]" ]]
}

@test "fzf - a mode is session, window or pane, and anything else is session" {
  # Arrange
  local script='for m in session window pane tree ""; do printf "%s " "$(fzf_revamped_valid_mode "$m")"; done'

  # Act
  lib_run fzf "${script}"

  # Assert
  [[ "${output}" == "session window pane session session " ]]
}

@test "fzf - version_ge compares major and minor numbers" {
  # Arrange
  local script='for p in "3.2 3.2" "3.10 3.4" "4.0 3.9" "3.1 3.2" "x 3.2"; do set -- ${p}; if fzf_revamped_version_ge "$1" "$2"; then printf y; else printf n; fi; done'

  # Act
  lib_run fzf "${script}"

  # Assert
  [[ "${output}" == "yyynn" ]]
}

@test "fzf - URLs are found, trimmed and kept once in first-seen order" {
  # Arrange
  local script='printf "%s\n" "go https://github.com/tmux-revamped/tmux-fzf-revamped, then ftp://ftp.gnu.org/gnu/ and file:///tmp/z." "again https://github.com/tmux-revamped/tmux-fzf-revamped" "none here" | fzf_revamped_extract_urls | tr "\n" " "'

  # Act
  lib_run fzf "${script}"

  # Assert
  [[ "${output}" == "https://github.com/tmux-revamped/tmux-fzf-revamped ftp://ftp.gnu.org/gnu/ file:///tmp/z " ]]
}

@test "fzf - a signal is normalised, and anything unknown is TERM" {
  # Arrange
  local script='for s in kill sigint Hup usr2 bogus ""; do printf "%s " "$(fzf_revamped_valid_signal "$s")"; done'

  # Act
  lib_run fzf "${script}"

  # Assert
  [[ "${output}" == "KILL INT HUP USR2 TERM TERM " ]]
}

@test "fzf - the palette offers common commands with the command as the id" {
  # Arrange
  local script='fzf_revamped_palette_list | cut -f1 | tr "\n" "|"'

  # Act
  lib_run fzf "${script}"

  # Assert
  [[ "${output}" == "new-window|split-window -h|split-window -v|next-window|previous-window|last-window|kill-pane|kill-window|detach-client|choose-tree|" ]]
}

@test "fzf - the pid is the first field of a process line" {
  # Arrange
  local script='printf "[%s]" "$(fzf_revamped_pid_of "  4321 vim")" "$(fzf_revamped_pid_of "")"'

  # Act
  lib_run fzf "${script}"

  # Assert
  [[ "${output}" == "[4321][]" ]]
}

@test "fzf - a target is classified by its shape" {
  # Arrange
  local script='for t in work work:2 work:2.1; do printf "%s " "$(fzf_revamped_target_kind "$t")"; done'

  # Act
  lib_run fzf "${script}"

  # Assert
  [[ "${output}" == "session window pane " ]]
}

@test "fzf - a session name is the folder's base with dots, colons and spaces replaced" {
  # Arrange
  local script='for p in "/home/user/my.project/" "a b:c" "/"; do printf "[%s]" "$(fzf_revamped_session_name "$p")"; done'

  # Act
  lib_run fzf "${script}"

  # Assert
  [[ "${output}" == "[my_project][a_b_c][/]" ]]
}

@test "fzf - recent sessions sort by attach time and lose the key" {
  # Arrange
  local script='printf "100\ta\ta  (1 windows)\n300\tc\tc  (2 windows)\n200\tb\tb  (1 windows)\n" | fzf_revamped_mru_sort | cut -f1 | tr "\n" " "'

  # Act
  lib_run fzf "${script}"

  # Assert
  [[ "${output}" == "c b a " ]]
}

@test "fzf - the default plan binds only the palette, in a bordered popup on 3.4" {
  # Arrange
  local version=3.4

  # Act
  plan_at "${version}"

  # Assert
  [[ "${output}" == "bind-key M-f display-popup -E -b rounded -w 60% -h 50% '"*"/bin/fzf-revamped' palette" ]]
}

@test "fzf - the border is dropped before 3.4 and when set to none" {
  # Arrange
  option popup_border none

  # Act
  lib_run fzf 'export REVAMPED_TEST_TMUX_VERSION=3.3; fzf_revamped_plan; fzf_revamped_lines; printf "\n"; rm -f "${REVAMPED_TEST_TMUX_DIR}"/*border*; export REVAMPED_TEST_TMUX_VERSION=3.3; fzf_revamped_plan; fzf_revamped_lines'

  # Assert
  [[ "${lines[0]}" == "bind-key M-f display-popup -E -w 60% -h 50% '"*"' palette" ]]
  [[ "${lines[1]}" == "bind-key M-f display-popup -E -w 60% -h 50% '"*"' palette" ]]
}

@test "fzf - tmux before 3.2 opens each picker in a window" {
  # Arrange
  option session_key s

  # Act
  plan_at 3.1

  # Assert
  [[ "${lines[0]}" == "bind-key s new-window '"*"/bin/fzf-revamped' session switch" ]]
  [[ "${lines[1]}" == "bind-key M-f new-window '"*"' palette" ]]
}

@test "fzf - every key binds its command, and off binds nothing" {
  # Arrange
  option session_key s
  option window_key w
  option pane_key e
  option kill_key X
  option tree_key t
  option create_key C
  option url_key u
  option cheatsheet_key '?'
  option process_key P
  option rename_key r
  option multikill_key K
  option zoxide_key z
  option move_key m
  option palette_key off

  # Act
  plan_at 3.4

  # Assert
  [[ "${#lines[@]}" -eq 13 ]]
  [[ "${output}" == *"' session switch"*"' window switch"*"' pane switch"*"' session kill"*"' tree"*"' create"*"' urls open"*"' cheatsheet"*"' process"*"' rename window"*"' multi-kill session"*"' zoxide"*"' move-window move" ]]
}

@test "fzf - the last key runs the command without a popup" {
  # Arrange
  option last_key L

  # Act
  plan_at 3.4

  # Assert
  [[ "${lines[1]}" == "bind-key L run-shell '"*"/bin/fzf-revamped' last" ]]
}

@test "fzf - the broadcast key stores the typed text, then opens the pane picker" {
  # Arrange
  option broadcast_key B

  # Act
  lib_run fzf 'export REVAMPED_TEST_TMUX_VERSION=3.4; fzf_revamped_plan; fzf_revamped_lines; export REVAMPED_TEST_TMUX_VERSION=3.1; fzf_revamped_plan; fzf_revamped_lines'

  # Assert
  [[ "${lines[1]}" == "bind-key B command-prompt -p broadcast: set-option -g @fzf_revamped_broadcast_text \"%%%\" ; display-popup -E -b rounded -w 60% -h 50% \"'"*"/bin/fzf-revamped' broadcast\"" ]]
  [[ "${lines[3]}" == "bind-key B command-prompt -p broadcast: set-option -g @fzf_revamped_broadcast_text \"%%%\" ; new-window \"'"*"/bin/fzf-revamped' broadcast\"" ]]
}

@test "fzf - no binding carries a hash, whatever the tool path holds" {
  # Arrange
  option last_key L
  option broadcast_key B
  export PROBE_LIB="/tmp/it's #1/lib"

  # Act
  lib_run fzf 'REVAMPED_LIB="${PROBE_LIB}"; export REVAMPED_TEST_TMUX_VERSION=3.4; fzf_revamped_plan; fzf_revamped_lines'

  # Assert
  [[ "${lines[0]}" == "bind-key M-f display-popup -E -b rounded -w 60% -h 50% '/tmp/it'\\''s '\"\$(printf '%b' '\\0043')\"'1/bin/fzf-revamped' palette" ]]
  [[ "${lines[1]}" == "bind-key L run-shell '/tmp/it'\\''s '\"\$(printf '%b' '\\0043')\"'1/bin/fzf-revamped' last" ]]
  [[ "${output}" != *"#"* ]]
}

@test "fzf - a quoted value survives the shell with its hash, quote and spaces" {
  # Arrange
  export PROBE_TEXT="a#b it's #1  two"

  # Act
  lib_run fzf 'quoted=$(fzf_revamped_quote "${PROBE_TEXT}"); eval "printf \"%s\\n\" ${quoted}"'

  # Assert
  [[ "${output}" == "a#b it's #1  two" ]]
}

@test "fzf - preview and mru ride on the picker keys when they came from the command line or environment" {
  # Arrange
  option session_key s
  option last_key L
  export FZF_REVAMPED_MRU=on FZF_REVAMPED_PREVIEW=on FZF_REVAMPED_POPUP_WIDTH=70%

  # Act
  lib_run fzf 'export REVAMPED_TEST_TMUX_VERSION=3.4; fzf_revamped_plan; fzf_revamped_lines; export REVAMPED_TEST_TMUX_VERSION=3.1; fzf_revamped_plan; fzf_revamped_lines'

  # Assert
  [[ "${lines[0]}" == "bind-key s display-popup -E -b rounded -w 70% -h 50% '"*"/bin/fzf-revamped' --preview 'on' --mru 'on' session switch" ]]
  [[ "${lines[2]}" == "bind-key L run-shell '"*"/bin/fzf-revamped' last" ]]
  [[ "${lines[3]}" == "bind-key s new-window '"*"/bin/fzf-revamped' --preview 'on' --mru 'on' session switch" ]]
}

@test "fzf - a setting from a tmux option stays off the keys" {
  # Arrange
  option session_key s
  option preview on

  # Act
  plan_at 3.4

  # Assert
  [[ "${lines[0]}" == "bind-key s display-popup -E -b rounded -w 60% -h 50% '"*"/bin/fzf-revamped' session switch" ]]
}

@test "fzf - a palette key the person bound is left alone and reported" {
  # Arrange
  mkdir -p "${BATS_TEST_TMPDIR}/stubs"
  printf '#!/bin/sh\nif [ "$1" = list-keys ]; then printf "%%s\\n" "bind-key -T prefix M-f display-message mine"; exit 0; fi\nexec "%s/bin/tmux" "$@"\n' "${REVAMPED_TESTS_DIR}" >"${BATS_TEST_TMPDIR}/stubs/tmux"
  chmod +x "${BATS_TEST_TMPDIR}/stubs/tmux"

  # Act
  lib_run fzf 'fzf_revamped_plan; printf "[%s][%s]" "$(fzf_revamped_lines)" "${FZF_REVAMPED_TAKEN}"'

  # Assert
  [[ "${output}" == "[][M-f]" ]]
}

@test "fzf - apply sends every binding to tmux in one call" {
  # Arrange
  option session_key s
  export REVAMPED_TEST_TMUX_ARGV="${BATS_TEST_TMPDIR}/argv"

  # Act
  lib_run fzf fzf_revamped_apply

  # Assert
  run grep -c '^bind-key|s|display-popup|.*|;|bind-key|M-f|' "${REVAMPED_TEST_TMUX_ARGV}"
  [[ "${output}" == "1" ]]
}

@test "fzf - the keys around a bad one are still bound" {
  # Arrange
  refuse
  option session_key BAD
  option window_key w
  export REVAMPED_TEST_TMUX_ARGV="${BATS_TEST_TMPDIR}/argv"

  # Act
  lib_run fzf fzf_revamped_apply

  # Assert
  [[ "${status}" -eq 1 ]]
  [[ "${output}" == *"unknown key: BAD"* ]]
  run grep -c '^bind-key' "${REVAMPED_TEST_TMUX_ARGV}"
  [[ "${output}" == "2" ]]
}

@test "fzf - json lists every command as its arguments" {
  # Arrange
  local script='FZF_REVAMPED_PLAN="$(printf "a\\\\b\nsay \"hi\"\n\nnext\n")"; fzf_revamped_json'

  # Act
  lib_run fzf "${script}"

  # Assert
  [[ "${output}" == '{"bindings":[["a\\b","say \"hi\""],["next"]]}' ]]
}

@test "fzf - a setting name comes from its long option" {
  # Arrange
  local script='for o in --mru --session-key --colour; do printf "[%s]" "$(fzf_revamped_setting_name "$o")"; done'

  # Act
  lib_run fzf "${script}"

  # Assert
  [[ "${output}" == "[mru][session_key][]" ]]
}

@test "opener - open serves when xdg-open is absent" {
  # Arrange
  harness_hide xdg-open
  stub_command open

  # Act
  lib_run fzf 'fzf_revamped_opener'

  # Assert
  [[ "${output}" == "open" ]]
}
