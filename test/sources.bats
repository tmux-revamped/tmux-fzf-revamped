#!/usr/bin/env bats
# shellcheck disable=SC2016,SC2030,SC2031,SC2034,SC2154

# shellcheck source=test/pickers_helpers.bash
source "${BATS_TEST_DIRNAME:-.}/pickers_helpers.bash"

bats_require_minimum_version 1.5.0

buffer_names() {
  local names
  names=$(tmux list-buffers -F '#{buffer_name}')
  paste -sd ' ' - <<<"${names}"
}

projects_file() {
  PROJECTS="${BATS_TEST_TMPDIR}/projects"
  printf '%s\n' "$@" >"${PROJECTS}"
  tmux set-option -g @fzf_revamped_projects "${PROJECTS}"
}

offered() {
  cut -f2 "${BATS_TEST_TMPDIR}/fzf.input"
}

@test "buffers - the picked buffer is pasted into this pane" {
  # Arrange
  local pick
  reader
  tmux set-buffer -b note "hello there"
  pick=$(line note "note  hello there")
  answers "${pick}"

  # Act
  tool buffers

  # Assert
  [[ "${status}" -eq 0 ]]
  wait_for tmux_shows test:0.0 "hello there"
  run buffer_names
  [[ "${output}" == "note" ]]
}

@test "buffers - delete removes the picked buffer and pastes nothing" {
  # Arrange
  local pick
  reader
  tmux set-buffer -b keep "stays"
  tmux set-buffer -b note "goes away"
  pick=$(line note "note  goes away")
  answers "${pick}"

  # Act
  tool buffers delete

  # Assert
  [[ "${status}" -eq 0 ]]
  run buffer_names
  [[ "${output}" == "keep" ]]
  run tmux capture-pane -p -t test:0.0
  [[ "${output}" != *"goes away"* ]]
}

@test "buffers - every buffer is offered by name with the start of its text" {
  # Arrange
  local expected
  expected=$(two_lines first "first  alpha text" second "second  beta text")
  tmux set-buffer -b first "alpha text"
  tmux set-buffer -b second "beta text"
  answers ""

  # Act
  tool buffers

  # Assert
  run sort "${BATS_TEST_TMPDIR}/fzf.input"
  [[ "${output}" == "${expected}" ]]
}

@test "buffers - leaving the list without a pick pastes nothing" {
  # Arrange
  reader
  tmux set-buffer -b note "hello there"
  answers ""

  # Act
  tool buffers

  # Assert
  [[ "${status}" -eq 0 ]]
  run tmux capture-pane -p -t test:0.0
  [[ "${output}" != *"hello there"* ]]
}

@test "buffers - with no buffer nothing is asked, and a message says so" {
  # Arrange
  answers ""

  # Act
  tool buffers

  # Assert
  [[ "${status}" -eq 0 ]]
  [[ ! -e "${BATS_TEST_TMPDIR}/fzf.args" ]]
  wait_for said "fzf-revamped: no paste buffer yet"
}

@test "buffers - pressing the buffer key pastes into the pane under the popup" {
  # Arrange
  local pick
  reader
  tmux set-buffer -b note "from the key"
  pick=$(line note "note  from the key")
  bound_on buffer_key B
  answers "${pick}"

  # Act
  command tmux -S "${HOST}" send-keys -t host C-b B

  # Assert
  wait_for tmux_shows test:0.0 "from the key"
}

@test "projects - the picked folder opens as a session named after it" {
  # Arrange
  local folder="${BATS_TEST_TMPDIR}/work/my.app" real pick
  mkdir -p "${folder}"
  real=$(cd "${folder}" && pwd -P)
  projects_file "${folder}"
  pick=$(printf '%s\t%s\t%s' "${folder}" "my_app  ${folder}" my_app)
  answers "${pick}"

  # Act
  tool projects

  # Assert
  [[ "${status}" -eq 0 ]]
  wait_for session_at my_app "${real}" "${folder}"
  client_on '#{session_name}' my_app
}

@test "projects - a line with a star lists every folder it matches, once, and skips comments, blanks and files" {
  # Arrange
  local base="${BATS_TEST_TMPDIR}/work"
  mkdir -p "${base}/api" "${base}/web site"
  : >"${base}/notes.txt"
  projects_file "# my projects" "" "${base}/*" "${base}/api" "${base}/missing"
  answers ""

  # Act
  tool projects

  # Assert
  run offered
  [[ "${output}" == "api  ${base}/api"$'\n'"web_site  ${base}/web site" ]]
}

@test "projects - a folder whose session is running is marked" {
  # Arrange
  local base="${BATS_TEST_TMPDIR}/work"
  mkdir -p "${base}/other" "${base}/idle"
  projects_file "${base}/other" "${base}/idle"
  answers ""

  # Act
  tool projects

  # Assert
  run offered
  [[ "${output}" == "other  ${base}/other  *"$'\n'"idle  ${base}/idle" ]]
}

@test "projects - a tilde means the home folder, alone or before a path, and the last line needs no newline" {
  # Arrange
  export HOME="${BATS_TEST_TMPDIR}/home"
  mkdir -p "${HOME}/code/tool"
  PROJECTS="${BATS_TEST_TMPDIR}/projects"
  printf '\176/code/tool\n\176' >"${PROJECTS}"
  tmux set-option -g @fzf_revamped_projects "${PROJECTS}"
  answers ""

  # Act
  tool projects

  # Assert
  run offered
  [[ "${output}" == "tool  ${HOME}/code/tool"$'\n'"home  ${HOME}" ]]
}

@test "projects - with no option the file is read from the config folder" {
  # Arrange
  export XDG_CONFIG_HOME="${BATS_TEST_TMPDIR}/config"
  mkdir -p "${XDG_CONFIG_HOME}/fzf-revamped" "${BATS_TEST_TMPDIR}/work/api"
  printf '%s\n' "${BATS_TEST_TMPDIR}/work/api" >"${XDG_CONFIG_HOME}/fzf-revamped/projects"
  answers ""

  # Act
  tool projects

  # Assert
  run offered
  [[ "${output}" == "api  ${BATS_TEST_TMPDIR}/work/api" ]]
}

@test "projects - without the file nothing opens, and a message names the file it looked for" {
  # Arrange
  export XDG_CONFIG_HOME="${BATS_TEST_TMPDIR}/config #1"
  answers ""

  # Act
  tool projects

  # Assert
  [[ "${status}" -eq 0 ]]
  [[ ! -e "${BATS_TEST_TMPDIR}/fzf.args" ]]
  wait_for said "fzf-revamped: no project listed in ${BATS_TEST_TMPDIR}/config #1/fzf-revamped/projects"
  run tmux list-sessions -F '#{session_name}'
  [[ "${output}" == $'other\ntest' ]]
}

@test "projects - leaving the list without a pick opens nothing" {
  # Arrange
  mkdir -p "${BATS_TEST_TMPDIR}/work/api"
  projects_file "${BATS_TEST_TMPDIR}/work/api"
  answers ""

  # Act
  tool projects

  # Assert
  [[ "${status}" -eq 0 ]]
  run tmux list-sessions -F '#{session_name}'
  [[ "${output}" == $'other\ntest' ]]
}

@test "projects - a file given to apply on the command line reaches the picker its key opens" {
  # Arrange
  local folder="${BATS_TEST_TMPDIR}/work/api" file="${BATS_TEST_TMPDIR}/my projects" real pick
  mkdir -p "${folder}"
  real=$(cd "${folder}" && pwd -P)
  printf '%s\n' "${folder}" >"${file}"
  pick=$(printf '%s\t%s\t%s' "${folder}" "api  ${folder}" api)
  tmux set-environment -g PATH "${BATS_TEST_TMPDIR}/stubs:${PATH}"
  answers "${pick}"
  tool --projects "${file}" --projects-key P apply

  # Act
  command tmux -S "${HOST}" send-keys -t host C-b P

  # Assert
  wait_for session_at api "${real}" "${folder}"
}
