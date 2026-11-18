#!/usr/bin/env bats
# shellcheck disable=SC2016,SC2030,SC2031,SC2034,SC2154

# shellcheck source=test/pickers_helpers.bash
source "${BATS_TEST_DIRNAME:-.}/pickers_helpers.bash"

bats_require_minimum_version 1.5.0

panes_of() {
  local panes
  panes=$(tmux list-panes -t "$1" -F '#{pane_id}')
  paste -sd ' ' - <<<"${panes}"
}

offered() {
  local ids
  ids=$(cut -f1 "${BATS_TEST_TMPDIR}/fzf.input")
  paste -sd ' ' - <<<"${ids}"
}

@test "arrange - join brings the picked pane into this window" {
  # Arrange
  local pick
  pick=$(line %1 "test:1.0  sh")
  answers "${pick}"

  # Act
  tool arrange join

  # Assert
  [[ "${status}" -eq 0 ]]
  run panes_of test:0
  [[ "${output}" == "%0 %1" ]]
  run window_names test
  [[ "${output}" == "editor" ]]
}

@test "arrange - join offers every pane outside this window" {
  # Arrange
  tmux split-window -d -t test:0
  answers ""

  # Act
  tool arrange join

  # Assert
  run offered
  [[ "${output}" == "%2 %1" ]]
}

@test "arrange - join asks nothing when no other window has a pane" {
  # Arrange
  tmux kill-session -t other
  tmux kill-window -t test:1
  answers ""

  # Act
  tool arrange join

  # Assert
  [[ "${status}" -eq 0 ]]
  [[ ! -e "${BATS_TEST_TMPDIR}/fzf.args" ]]
}

@test "arrange - break moves the picked pane into its own window and goes there" {
  # Arrange
  local pick
  tmux split-window -d -t test:0
  pick=$(line %3 "test:0.1  sh")
  answers "${pick}"

  # Act
  tool arrange break

  # Assert
  [[ "${status}" -eq 0 ]]
  run panes_of test:0
  [[ "${output}" == "%0" ]]
  run panes_of test:2
  [[ "${output}" == "%3" ]]
  client_on '#{window_index}' 2
}

@test "arrange - break offers only the panes that share a window" {
  # Arrange
  tmux split-window -d -t test:0
  answers ""

  # Act
  tool arrange break

  # Assert
  run offered
  [[ "${output}" == "%0 %3" ]]
}

@test "arrange - swap puts the picked pane where this one was" {
  # Arrange
  local pick
  tmux split-window -d -t test:0
  pick=$(line %1 "test:1.0  sh")
  answers "${pick}"

  # Act
  tool arrange swap

  # Assert
  [[ "${status}" -eq 0 ]]
  run panes_of test:0
  [[ "${output}" == "%1 %3" ]]
  run panes_of test:1
  [[ "${output}" == "%0" ]]
}

@test "arrange - swap offers every pane but this one" {
  # Arrange
  answers ""

  # Act
  tool arrange swap

  # Assert
  run offered
  [[ "${output}" == "%2 %1" ]]
}

@test "arrange - layout lays this window out as picked" {
  # Arrange
  local pick
  tmux split-window -d -h -t test:0
  pick=$(line even-vertical "even-vertical  stacked")
  answers "${pick}"

  # Act
  tool arrange layout

  # Assert
  [[ "${status}" -eq 0 ]]
  run tmux list-panes -t test:0 -F '#{pane_left}'
  [[ "${output}" == $'0\n0' ]]
}

@test "arrange - layout offers the mirrored layouts on a tmux that has them" {
  # Arrange
  answers ""

  # Act
  tool arrange layout

  # Assert
  run offered
  [[ "${output}" == "even-horizontal even-vertical main-horizontal main-vertical tiled main-horizontal-mirrored main-vertical-mirrored" ]]
}

@test "arrange - resize moves this pane's edge by the cells picked" {
  # Arrange
  local pick before
  tmux split-window -d -h -t test:0
  before=$(tmux display-message -p -t %0 '#{pane_width}')
  pick=$(line "L 10" "left 10")
  answers "${pick}"

  # Act
  tool arrange resize

  # Assert
  [[ "${status}" -eq 0 ]]
  run tmux display-message -p -t %0 '#{pane_width}'
  [[ "${output}" == "$((before - 10))" ]]
}

@test "arrange - resize offers four sides at three sizes" {
  # Arrange
  answers ""

  # Act
  tool arrange resize

  # Assert
  run cut -f2 "${BATS_TEST_TMPDIR}/fzf.input"
  [[ "${output}" == $'left 5\nleft 10\nleft 20\nright 5\nright 10\nright 20\nup 5\nup 10\nup 20\ndown 5\ndown 10\ndown 20' ]]
}

@test "arrange - with no action it asks which, then runs it" {
  # Arrange
  local action pick
  action=$(line join "join  bring a pane into this window")
  pick=$(line %1 "test:1.0  sh")
  answers "${action}" -- "${pick}"

  # Act
  tool arrange

  # Assert
  [[ "${status}" -eq 0 ]]
  run panes_of test:0
  [[ "${output}" == "%0 %1" ]]
}

@test "arrange - an action it does not know is asked for again" {
  # Arrange
  answers ""

  # Act
  tool arrange sideways

  # Assert
  [[ "${status}" -eq 0 ]]
  run offered
  [[ "${output}" == "join break swap layout resize" ]]
}

@test "arrange - leaving either list without a pick changes nothing" {
  # Arrange
  local action
  action=$(line swap "swap  swap a pane with this one")
  answers "${action}" -- ""

  # Act
  tool arrange

  # Assert
  [[ "${status}" -eq 0 ]]
  run panes_of test:0
  [[ "${output}" == "%0" ]]
}

@test "arrange - pressing the arrange key acts on the pane under the popup" {
  # Arrange
  local action pick
  action=$(line join "join  bring a pane into this window")
  pick=$(line %2 "other:0.0  sh")
  bound_on arrange_key A
  answers "${action}" -- "${pick}"

  # Act
  command tmux -S "${HOST}" send-keys -t host C-b A

  # Assert
  wait_for panes_are 2
  run panes_of test:0
  [[ "${output}" == "%0 %2" ]]
}
