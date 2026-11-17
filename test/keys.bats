#!/usr/bin/env bats
# shellcheck disable=SC2016,SC2030,SC2031,SC2034,SC2154

# shellcheck source=test/pickers_helpers.bash
source "${BATS_TEST_DIRNAME:-.}/pickers_helpers.bash"

bats_require_minimum_version 1.5.0

@test "rename - pressing the rename key renames the picked window" {
  # Arrange
  local pick
  pick=$(line test:1 "test:1  logs")
  tmux set-option -g @fzf_revamped_rename_key R
  tmux set-environment -g PATH "${BATS_TEST_TMPDIR}/stubs:${PATH}"
  load_plugin "${ROOT}"
  answers "${pick}"

  # Act
  command tmux -S "${HOST}" send-keys -t host C-b R

  # Assert
  wait_for host_shows "New window name: "
  command tmux -S "${HOST}" send-keys -t host build Enter
  wait_for windows_are "editor build"
}

@test "palette - a checkout path with a space, a quote and a hash still opens the palette from its key" {
  # Arrange
  local copy="${BATS_TEST_TMPDIR}/it's #1 dir" quoted pick
  mkdir -p "${copy}"
  cp -Rf "${ROOT}/bin" "${ROOT}/lib" "${ROOT}/fzf-revamped.tmux" "${copy}/"
  quoted=$(printf '%s' "${copy}" | sed -e "s/'/'\\\\''/g" -e 's/#/##/g')
  pick=$(line split-window "split-window  split down")
  tmux set-environment -g PATH "${BATS_TEST_TMPDIR}/stubs:${PATH}"
  tmux run-shell "'${quoted}/fzf-revamped.tmux'"
  answers "${pick}"

  # Act
  command tmux -S "${HOST}" send-keys -t host C-b M-f

  # Assert
  wait_for panes_are 2
}

@test "session - a preview given to apply on the command line reaches the picker the key opens" {
  # Arrange
  local pick
  pick=$(line other "other")
  tmux set-environment -g PATH "${BATS_TEST_TMPDIR}/stubs:${PATH}"
  answers "${pick}"
  tool --preview on --session-key S apply

  # Act
  command tmux -S "${HOST}" send-keys -t host C-b S

  # Assert
  wait_for client_on '#{session_name}' other
  run grep -c -- '--preview ' "${BATS_TEST_TMPDIR}/fzf.args"
  [[ "${output}" == "1" ]]
}

@test "palette - pressing prefix M-f runs the picked command through the popup" {
  # Arrange
  local pick
  pick=$(line split-window "split-window  split down")
  tmux set-environment -g PATH "${BATS_TEST_TMPDIR}/stubs:${PATH}"
  load_plugin "${ROOT}"
  answers "${pick}"

  # Act
  command tmux -S "${HOST}" send-keys -t host C-b M-f

  # Assert
  wait_for panes_are 2
}

@test "broadcast and last - their keys work from a checkout path with a space, a quote and a hash" {
  # Arrange
  local copy="${BATS_TEST_TMPDIR}/it's #1 dir" quoted marked client
  client=$(first_client)
  mkdir -p "${copy}"
  cp -Rf "${ROOT}/bin" "${ROOT}/lib" "${ROOT}/fzf-revamped.tmux" "${copy}/"
  quoted=$(printf '%s' "${copy}" | sed -e "s/'/'\\\\''/g" -e 's/#/##/g')
  marked=$(line test:0.0 "test:0.0  sh")
  tmux set-option -g @fzf_revamped_broadcast_key B
  tmux set-option -g @fzf_revamped_last_key L
  tmux set-environment -g PATH "${BATS_TEST_TMPDIR}/stubs:${PATH}"
  tmux run-shell "'${quoted}/fzf-revamped.tmux'"
  answers "${marked}"

  # Act
  command tmux -S "${HOST}" send-keys -t host C-b B

  # Assert
  wait_for host_shows "broadcast:"
  command tmux -S "${HOST}" send-keys -t host 'echo odd-path' Enter
  wait_for tmux_shows test:0 $'odd-path\n'
  tmux switch-client -c "${client}" -t other
  wait_for client_on '#{session_name}' other
  command tmux -S "${HOST}" send-keys -t host C-b L
  wait_for client_on '#{session_name}' test
}

@test "window - pressing its key selects the picked window" {
  # Arrange
  local pick
  pick=$(line test:1 "test:1  logs")
  bound_on window_key W
  answers "${pick}"

  # Act
  command tmux -S "${HOST}" send-keys -t host C-b W

  # Assert
  wait_for client_on '#{window_name}' logs
}

@test "pane - pressing its key selects the picked pane" {
  # Arrange
  local pick
  tmux split-window -d -t test:0
  pick=$(line test:0.1 "test:0.1  sh")
  bound_on pane_key P
  answers "${pick}"

  # Act
  command tmux -S "${HOST}" send-keys -t host C-b P

  # Assert
  wait_for shows test:0 '#{pane_index}' 1
}

@test "kill - pressing its key removes the picked session" {
  # Arrange
  local pick
  pick=$(line other "other")
  bound_on kill_key K
  answers "${pick}"

  # Act
  command tmux -S "${HOST}" send-keys -t host C-b K

  # Assert
  wait_for gone other
}

@test "tree - pressing its key selects the picked pane" {
  # Arrange
  local pick
  tmux split-window -d -t test:0
  pick=$(line test:0.1 "test:0.1  sh")
  bound_on tree_key T
  answers "${pick}"

  # Act
  command tmux -S "${HOST}" send-keys -t host C-b T

  # Assert
  wait_for shows test:0 '#{pane_index}' 1
}

@test "create - pressing its key switches to the matching session" {
  # Arrange
  local match
  match=$(line other "other")
  bound_on create_key N
  answers 'oth' "${match}"

  # Act
  command tmux -S "${HOST}" send-keys -t host C-b N

  # Assert
  wait_for client_on '#{session_name}' other
}

@test "urls - pressing its key hands the picked URL to the opener" {
  # Arrange
  printf '#!/bin/sh\nprintf "%%s\\n" "$1" >"%s"\n' "${BATS_TEST_TMPDIR}/opened" >"${BATS_TEST_TMPDIR}/stubs/xdg-open"
  chmod +x "${BATS_TEST_TMPDIR}/stubs/xdg-open"
  tmux send-keys -t test:0 'echo see https://example.com/key.' Enter
  wait_for tmux_shows test:0 'see https://example.com/key.'
  bound_on url_key U
  answers 'https://example.com/key'

  # Act
  command tmux -S "${HOST}" send-keys -t host C-b U

  # Assert
  wait_for file_holds "${BATS_TEST_TMPDIR}/opened" 'https://example.com/key'
}

@test "cheatsheet - pressing its key lists the key bindings in the picker" {
  # Arrange
  bound_on cheatsheet_key C
  answers ''

  # Act
  command tmux -S "${HOST}" send-keys -t host C-b C

  # Assert
  wait_for file_holds "${BATS_TEST_TMPDIR}/fzf.input" 'bind-key'
  wait_for file_holds "${BATS_TEST_TMPDIR}/fzf.input" 'fzf-revamped'
}

@test "process - pressing its key signals the picked process after a yes" {
  # Arrange
  local pid
  sleep 300 >/dev/null 2>&1 3>&- &
  pid=$!
  SLEEPER="${pid}"
  bound_on process_key X
  answers "${pid} sleep" -- yes

  # Act
  command tmux -S "${HOST}" send-keys -t host C-b X

  # Assert
  wait_for sh -c "! kill -0 ${pid} 2>/dev/null"
}

@test "multi-kill - pressing its key removes every marked session after a yes" {
  # Arrange
  local marked
  marked=$(line other "other")
  bound_on multikill_key M
  answers "${marked}" -- yes

  # Act
  command tmux -S "${HOST}" send-keys -t host C-b M

  # Assert
  wait_for gone other
}

@test "zoxide - pressing its key opens the picked folder as a session" {
  # Arrange
  local folder="${BATS_TEST_TMPDIR}/proj.k" real
  mkdir -p "${folder}"
  real=$(cd "${folder}" && pwd -P)
  printf '#!/bin/sh\nprintf "%%s\\n" "%s"\n' "${folder}" >"${BATS_TEST_TMPDIR}/stubs/zoxide"
  chmod +x "${BATS_TEST_TMPDIR}/stubs/zoxide"
  bound_on zoxide_key Z
  answers "${folder}"

  # Act
  command tmux -S "${HOST}" send-keys -t host C-b Z

  # Assert
  wait_for session_at proj_k "${real}" "${folder}"
}

@test "move-window - pressing its key moves the picked window to the typed session" {
  # Arrange
  local pick
  pick=$(line test:1 "test:1  logs")
  bound_on move_key V
  answers "${pick}"

  # Act
  command tmux -S "${HOST}" send-keys -t host C-b V

  # Assert
  wait_for host_shows "Move to session: "
  command tmux -S "${HOST}" send-keys -t host other: Enter
  wait_for windows_of other "main logs"
}
