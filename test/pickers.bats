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

@test "pickers - the arrange, buffer and projects keys open their pickers" {
  # Arrange
  option arrange_key A
  option buffer_key B
  option projects_key J
  option palette_key off
  export REVAMPED_TEST_TMUX_VERSION=3.4

  # Act
  lib_run fzf 'fzf_revamped_plan; fzf_revamped_lines'

  # Assert
  [[ "${#lines[@]}" -eq 3 ]]
  [[ "${lines[0]}" == "bind-key A display-popup -E -b rounded -w 60% -h 50% "*"' arrange" ]]
  [[ "${lines[1]}" == "bind-key B display-popup -E -b rounded -w 60% -h 50% "*"' buffers paste" ]]
  [[ "${lines[2]}" == "bind-key J display-popup -E -b rounded -w 60% -h 50% "*"' projects" ]]
}

@test "pickers - a projects file given in the environment rides on every picker key" {
  # Arrange
  option projects_key J
  option palette_key off
  export FZF_REVAMPED_PROJECTS="/srv/my list"

  # Act
  lib_run fzf 'fzf_revamped_plan; fzf_revamped_lines'

  # Assert
  [[ "${lines[0]}" == *"' --projects '/srv/my list' projects" ]]
}

@test "pickers - a tmux before 3.5 is offered no mirrored layout" {
  # Arrange
  local script='FZF_REVAMPED_TMUX=3.4; fzf_revamped_arrange_layouts | cut -f1 | paste -sd " " -'

  # Act
  lib_run arrange "${script}"

  # Assert
  [[ "${output}" == "even-horizontal even-vertical main-horizontal main-vertical tiled" ]]
}

@test "pickers - arrange does nothing when tmux names no pane" {
  # Arrange
  export REVAMPED_TEST_TMUX_FAIL=1 REVAMPED_TEST_TMUX_LOG="${BATS_TEST_TMPDIR}/tmux.log"

  # Act
  lib_run arrange 'fzf_revamped_arrange join; printf "%s\n" done'

  # Assert
  [[ "${output}" == "done" ]]
  run grep -c -e join-pane -e list-panes "${REVAMPED_TEST_TMUX_LOG}"
  [[ "${output}" == "0" ]]
}

@test "pickers - a buffer is not pasted when tmux names no pane" {
  # Arrange
  export REVAMPED_TEST_TMUX_FAIL=1 REVAMPED_TEST_TMUX_LOG="${BATS_TEST_TMPDIR}/tmux.log"

  # Act
  lib_run pickers 'fzf_revamped_buffers_act paste note; printf "%s\n" done'

  # Assert
  [[ "${output}" == "done" ]]
  run grep -c paste-buffer "${REVAMPED_TEST_TMUX_LOG}"
  [[ "${output}" == "0" ]]
}

@test "pickers - a session is named after the last part of its folder, with dots, colons and spaces replaced" {
  # Arrange
  local script='printf "%s\n" "/home/user/my.project/" "a b:c" "/" "/srv/api//" | fzf_revamped_session_names | tr "\t\n" "|,"'

  # Act
  lib_run fzf "${script}"

  # Assert
  [[ "${output}" == "my_project|/home/user/my.project/,a_b_c|a b:c,/|/,api|/srv/api//," ]]
}
