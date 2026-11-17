#!/usr/bin/env bats
# shellcheck disable=SC2016,SC2030,SC2031,SC2034,SC2154

# shellcheck source=test/tmux_helpers.bash
source "${BATS_TEST_DIRNAME:-.}/tmux_helpers.bash"

bats_require_minimum_version 1.5.0

setup() {
  ROOT="$(cd "${BATS_TEST_DIRNAME}/.." && pwd)"
  setup_tmux_server
  HOST="${TMUX_SOCKET}-host"
  mkdir -p "${BATS_TEST_TMPDIR}/stubs"
  tmux rename-window -t test: editor
  tmux new-window -d -t test: -n logs
  tmux new-session -d -s other -n main
  command tmux -S "${HOST}" -f /dev/null new-session -d -s host -x 120 -y 30 \
    "env -u TMUX TERM=xterm-256color tmux -S '${TMUX_SOCKET}' attach-session -t test"
  wait_for attached
}

teardown() {
  [[ -z "${SLEEPER:-}" ]] || kill "${SLEEPER}" 2>/dev/null || :
  command tmux -S "${HOST}" kill-server 2>/dev/null || :
  rm -f "${HOST}"
  teardown_tmux_server
}

screens() {
  printf 'host screen:\n'
  command tmux -S "${HOST}" capture-pane -p -t host || :
  printf 'pane screen:\n'
  tmux capture-pane -p -t test:0 || :
}

wait_for() {
  local delay
  for delay in 0.01 0.02 0.05 0.1 0.1 0.2 0.2 0.5 0.5 1 1 1 2 2; do
    "$@" && return 0
    sleep "${delay}"
  done
  "$@" && return 0
  screens
  return 1
}

attached() {
  local clients
  clients=$(tmux list-clients -F x 2>/dev/null)
  [[ -n "${clients}" ]]
}

first_client() {
  local clients
  clients=$(tmux list-clients -F '#{client_name}')
  printf '%s\n' "${clients%%$'\n'*}"
}

client_on() {
  local client where
  client=$(first_client)
  where=$(tmux display-message -p -c "${client}" "$1")
  [[ "${where}" == "$2" ]]
}

two_lines() {
  local first second
  first=$(line "$1" "$2")
  second=$(line "$3" "$4")
  printf '%s\n%s' "${first}" "${second}"
}

answers() {
  printf '%s\n' "$@" >"${BATS_TEST_TMPDIR}/fzf.answers"
  cat >"${BATS_TEST_TMPDIR}/stubs/fzf" <<EOF
#!/bin/sh
printf '%s\n' "\$*" >>"${BATS_TEST_TMPDIR}/fzf.args"
cat >>"${BATS_TEST_TMPDIR}/fzf.input"
round=\$(( \$(cat "${BATS_TEST_TMPDIR}/fzf.round" 2>/dev/null || printf 0) + 1 ))
printf '%s' "\${round}" >"${BATS_TEST_TMPDIR}/fzf.round"
awk -v r="\${round}" 'BEGIN { RS = "--\\n" } NR == r { printf "%s", \$0 }' "${BATS_TEST_TMPDIR}/fzf.answers"
EOF
  chmod +x "${BATS_TEST_TMPDIR}/stubs/fzf"
}

line() {
  printf '%s\t%s' "$1" "$2"
}

tool() {
  # shellcheck disable=SC2086
  TMUX="${TMUX_SOCKET},1,0" PATH="${BATS_TEST_TMPDIR}/stubs:${PATH}" run ${REVAMPED_TEST_SHELL:-sh} "${ROOT}/bin/fzf-revamped" "$@"
}

load_plugin() {
  local quoted
  quoted=$(printf '%s' "$1" | sed "s/'/'\\\\''/g")
  tmux run-shell "'${quoted}/fzf-revamped.tmux'"
}

window_names() {
  local names
  names=$(tmux list-windows -t "$1" -F '#{window_name}')
  paste -sd ' ' - <<<"${names}"
}

typed() {
  local shell_words
  read -r -a shell_words <<<"${REVAMPED_TEST_SHELL:-sh}"
  TMUX="${TMUX_SOCKET},1,0" PATH="${BATS_TEST_TMPDIR}/stubs:${PATH}" run python3 "${ROOT}/test/on_tty.py" "${shell_words[@]}" "${ROOT}/bin/fzf-revamped" "$@"
}

key_binding() {
  local table
  table=$(tmux list-keys -T "$1")
  awk -v key="$2" '{ for (i = 1; i < NF; i++) { if ($i == "-T") { if ($(i + 2) == key) { print } break } } }' <<<"${table}"
}

@test "entrypoint - loading binds only the palette on prefix M-f" {
  # Arrange
  local key=M-f

  # Act
  load_plugin "${ROOT}"

  # Assert
  run tmux list-keys -T prefix
  run grep -c 'fzf-revamped' <<<"${output}"
  [[ "${output}" == "1" ]]
  run key_binding prefix "${key}"
  [[ "${output}" == *"display-popup -E"*"' palette"* ]]
}

@test "entrypoint - git tracks the entry point and the tool as executable" {
  # Arrange
  local entry=fzf-revamped.tmux tool=bin/fzf-revamped

  # Act
  run git -C "${ROOT}" ls-files --stage -- "${entry}" "${tool}"

  # Assert
  [[ "${lines[0]}" == 100755\ * ]]
  [[ "${lines[1]}" == 100755\ * ]]
}

@test "entrypoint - a checkout path with a space, a quote and a hash still runs from a binding" {
  # Arrange
  local copy="${BATS_TEST_TMPDIR}/it's #1 dir" command
  mkdir -p "${copy}"
  cp -Rf "${ROOT}/bin" "${ROOT}/lib" "${ROOT}/fzf-revamped.tmux" "${copy}/"
  command=$(TMUX="${TMUX_SOCKET},1,0" FZF_REVAMPED_LAST_KEY=L sh "${copy}/bin/fzf-revamped" list)
  command=$(sed -n 's/^bind-key L run-shell //p' <<<"${command}")

  # Act
  run tmux run-shell "${command% last} version"

  # Assert
  [[ "${output}" == "fzf-revamped "* ]]
}

@test "session - switch moves the client to the picked session" {
  # Arrange
  local pick
  pick=$(line other "other  (1 windows)")
  answers "${pick}"

  # Act
  tool session switch

  # Assert
  wait_for client_on '#{session_name}' other
  run cat "${BATS_TEST_TMPDIR}/fzf.args"
  [[ "${output}" == "--no-sort --reverse --height=100% --delimiter "$'\t'" --with-nth 2" ]]
  run cut -f1 "${BATS_TEST_TMPDIR}/fzf.input"
  [[ "${output}" == $'other\ntest' ]]
}

@test "window - switch selects the picked window in its session" {
  # Arrange
  local pick
  pick=$(line test:1 "test:1  logs")
  answers "${pick}"

  # Act
  tool window

  # Assert
  wait_for client_on '#{window_name}' logs
}

@test "pane - switch selects the picked pane" {
  # Arrange
  local pane pick
  tmux split-window -d -t test:0
  pane=$(tmux display-message -p -t test:0.1 '#{pane_id}')
  pick=$(line test:0.1 "test:0.1  sh")
  answers "${pick}"

  # Act
  tool pane switch

  # Assert
  run tmux display-message -p -t test:0 '#{pane_id}'
  [[ "${output}" == "${pane}" ]]
}

@test "session - kill removes the picked session, window and pane alike" {
  # Arrange
  local session window pane
  tmux split-window -d -t test:0
  session=$(line other "other")
  window=$(line test:1 "test:1  logs")
  pane=$(line test:0.1 "test:0.1  sh")
  answers "${session}" -- "${window}" -- "${pane}"

  # Act
  tool session kill
  tool window kill
  tool pane kill

  # Assert
  run tmux has-session -t other
  [[ "${status}" -ne 0 ]]
  run window_names test
  [[ "${output}" == "editor" ]]
  run tmux list-panes -t test:0
  [[ "${#lines[@]}" -eq 1 ]]
}

@test "session - an empty list, an empty pick or a bad mode does nothing harmful" {
  # Arrange
  answers ''

  # Act
  tool nonsense switch

  # Assert
  [[ "${status}" -eq 1 ]]
  tool session switch
  [[ "${status}" -eq 0 ]]
  run tmux list-sessions
  [[ "${#lines[@]}" -eq 2 ]]
}

@test "session - the switch picker shows a preview when it is on" {
  # Arrange
  local pick
  pick=$(line other "other")
  tmux set-option -g @fzf_revamped_preview on
  answers "${pick}"

  # Act
  tool session switch

  # Assert
  run cat "${BATS_TEST_TMPDIR}/fzf.args"
  [[ "${output}" == *"--preview '${ROOT}/bin/fzf-revamped' preview {1} --preview-window=down:40%" ]]
}

@test "session - the list follows the last attach when mru is on" {
  # Arrange
  tmux set-option -g @fzf_revamped_mru on
  answers ''

  # Act
  tool session switch

  # Assert
  run cut -f1 "${BATS_TEST_TMPDIR}/fzf.input"
  [[ "${lines[0]}" == "test" ]]
  [[ "${lines[1]}" == "other" ]]
}

@test "preview - prints the target pane, and nothing without a target" {
  # Arrange
  tmux send-keys -t test:0 'echo preview-marker' Enter
  wait_for tmux_shows test:0 preview-marker

  # Act
  tool preview test:0

  # Assert
  [[ "${output}" == *"preview-marker"* ]]
  tool preview
  [[ -z "${output}" ]]
}

tmux_shows() {
  local screen
  screen=$(tmux capture-pane -p -t "$1")
  [[ "${screen}" == *"$2"* ]]
}

@test "tree - a pane pick selects the pane, a session pick switches to it" {
  # Arrange
  local pane session
  tmux split-window -d -t test:0
  pane=$(line test:0.1 "test:0.1  sh")
  session=$(line other "other")
  answers "${pane}" -- "${session}"

  # Act
  tool tree

  # Assert
  run tmux display-message -p -t test:0 '#{pane_index}'
  [[ "${output}" == "1" ]]
  tool tree
  wait_for client_on '#{session_name}' other
}

@test "create - a match switches, a miss creates a session named from the query" {
  # Arrange
  local match
  match=$(line other "other")
  answers 'oth' "${match}" -- '/srv/my.app'

  # Act
  tool create

  # Assert
  wait_for client_on '#{session_name}' other
  tool create
  run tmux has-session -t my_app
  [[ "${status}" -eq 0 ]]
}

@test "urls - open hands the URL to the opener, copy fills a tmux buffer" {
  # Arrange
  printf '#!/bin/sh\nprintf "%%s\\n" "$1" >"%s"\n' "${BATS_TEST_TMPDIR}/opened" >"${BATS_TEST_TMPDIR}/stubs/xdg-open"
  chmod +x "${BATS_TEST_TMPDIR}/stubs/xdg-open"
  tmux send-keys -t test:0 'echo see https://example.com/doc.' Enter
  wait_for tmux_shows test:0 'see https://example.com/doc.'
  answers 'https://example.com/doc' -- 'https://example.com/doc'

  # Act
  tool urls open

  # Assert
  run cat "${BATS_TEST_TMPDIR}/opened"
  [[ "${output}" == "https://example.com/doc" ]]
  tool urls copy
  run tmux show-buffer
  [[ "${output}" == "https://example.com/doc" ]]
}

@test "palette - the picked command runs" {
  # Arrange
  local pick
  pick=$(line new-window "new-window  open a window")
  answers "${pick}"

  # Act
  tool palette

  # Assert
  run tmux list-windows -t test
  [[ "${#lines[@]}" -eq 3 ]]
}

@test "cheatsheet - every key binding is listed" {
  # Arrange
  answers ''

  # Act
  tool cheatsheet

  # Assert
  [[ "${status}" -eq 0 ]]
  run grep -c 'bind-key' "${BATS_TEST_TMPDIR}/fzf.input"
  [[ "${output}" -gt 50 ]]
}

@test "process - the picked process gets the signal only after a yes" {
  # Arrange
  local pid
  sleep 300 >/dev/null 2>&1 3>&- &
  pid=$!
  SLEEPER="${pid}"
  answers "${pid} sleep" -- no -- "${pid} sleep" -- yes

  # Act
  tool process TERM

  # Assert
  kill -0 "${pid}"
  tool process sigterm
  wait_for sh -c "! kill -0 ${pid} 2>/dev/null"
}

@test "rename - the window is renamed through the prompt" {
  # Arrange
  local pick
  pick=$(line test:1 "test:1  logs")
  answers "${pick}"

  # Act
  typed rename window <<<"build"

  # Assert
  [[ "${status}" -eq 0 ]]
  [[ "${output}" == *"New window name: "* ]]
  run window_names test
  [[ "${output}" == "editor build" ]]
}

@test "rename - a session is renamed through the prompt" {
  # Arrange
  local pick
  pick=$(line other "other")
  answers "${pick}"

  # Act
  typed rename session <<<"renamed"

  # Assert
  [[ "${output}" == *"New session name: "* ]]
  run tmux has-session -t renamed
  [[ "${status}" -eq 0 ]]
}

@test "multi-kill - every marked window goes after a yes, and nothing after a no" {
  # Arrange
  local marked
  tmux new-window -d -t test: -n extra
  marked=$(two_lines test:1 "test:1  logs" test:2 "test:2  extra")
  answers "${marked}" -- no -- "${marked}" -- yes

  # Act
  tool multi-kill window

  # Assert
  run window_names test
  [[ "${output}" == "editor logs extra" ]]
  tool multi-kill window
  run window_names test
  [[ "${output}" == "editor" ]]
}

@test "broadcast - the stored text is typed literally with Enter into each pane, then cleared" {
  # Arrange
  local marked
  tmux set-option -g @fzf_revamped_broadcast_text 'echo C-c'
  marked=$(two_lines test:0.0 "test:0.0  sh" other:0.0 "other:0.0  sh")
  answers "${marked}"

  # Act
  tool broadcast

  # Assert
  wait_for tmux_shows test:0 $'C-c\n'
  wait_for tmux_shows other:0 $'C-c\n'
  run tmux show-options -gqv @fzf_revamped_broadcast_text
  [[ -z "${output}" ]]
}

@test "broadcast - nothing is sent without text or without a pick" {
  # Arrange
  answers ''

  # Act
  tool broadcast

  # Assert
  [[ "${status}" -eq 0 ]]
  [[ ! -e "${BATS_TEST_TMPDIR}/fzf.args" ]]
  tool broadcast 'echo never'
  [[ "${status}" -eq 0 ]]
}

@test "zoxide - the picked folder opens as a session" {
  # Arrange
  local folder="${BATS_TEST_TMPDIR}/proj.x" real
  mkdir -p "${folder}"
  real=$(cd "${folder}" && pwd -P)
  printf '#!/bin/sh\nprintf "%%s\\n" "%s"\n' "${folder}" >"${BATS_TEST_TMPDIR}/stubs/zoxide"
  chmod +x "${BATS_TEST_TMPDIR}/stubs/zoxide"
  answers "${folder}"

  # Act
  tool zoxide

  # Assert
  wait_for session_at proj_x "${real}" "${folder}"
}

session_at() {
  local now
  now=$(tmux display-message -p -t "$1" '#{pane_current_path}')
  [[ "${now}" == "$2" || "${now}" == "$3" ]]
}

@test "zoxide - the session starts in a folder whose path holds a hash tmux reads as a format" {
  # Arrange
  local folder="${BATS_TEST_TMPDIR}/it's #S dir/projy" real
  mkdir -p "${folder}"
  real=$(cd "${folder}" && pwd -P)
  printf '%s\n' "${folder}" >"${BATS_TEST_TMPDIR}/zoxide.out"
  printf '#!/bin/sh\ncat "%s"\n' "${BATS_TEST_TMPDIR}/zoxide.out" >"${BATS_TEST_TMPDIR}/stubs/zoxide"
  chmod +x "${BATS_TEST_TMPDIR}/stubs/zoxide"
  answers "${folder}"

  # Act
  tool zoxide

  # Assert
  wait_for session_at projy "${real}" "${folder}"
}

@test "last - the client returns to the previous session" {
  # Arrange
  local client
  client=$(first_client)
  tmux switch-client -c "${client}" -t other
  wait_for client_on '#{session_name}' other

  # Act
  tool last

  # Assert
  wait_for client_on '#{session_name}' test
}

@test "move-window - the picked window moves to the typed session" {
  # Arrange
  local pick
  pick=$(line test:1 "test:1  logs")
  answers "${pick}"

  # Act
  typed move-window move <<<"other:"

  # Assert
  [[ "${output}" == *"Move to session: "* ]]
  run window_names other
  [[ "${output}" == "main logs" ]]
}

@test "move-window - the picked window links to the typed session" {
  # Arrange
  local pick
  pick=$(line test:0 "test:0  editor")
  answers "${pick}"

  # Act
  typed move-window link <<<"other:"

  # Assert
  [[ "${output}" == *"Link to session: "* ]]
  run window_names other
  [[ "${output}" == "main editor" ]]
}

@test "rename - an empty answer renames nothing" {
  # Arrange
  local pick
  pick=$(line test:1 "test:1  logs")
  answers "${pick}"

  # Act
  typed rename window <<<""

  # Assert
  [[ "${status}" -eq 0 ]]
  run window_names test
  [[ "${output}" == "editor logs" ]]
}

@test "rename - without a terminal it stops before picking" {
  # Arrange
  local pick
  pick=$(line test:1 "test:1  logs")
  answers "${pick}"

  # Act
  tool rename window </dev/null

  # Assert
  [[ "${status}" -eq 1 ]]
  [[ "${output}" == "fzf-revamped: no window name given. run 'fzf-revamped help' for usage." ]]
}

@test "move-window - without a terminal it stops before picking" {
  # Arrange
  local pick
  pick=$(line test:1 "test:1  logs")
  answers "${pick}"

  # Act
  tool move-window </dev/null

  # Assert
  [[ "${status}" -eq 1 ]]
  [[ "${output}" == "fzf-revamped: no session given. run 'fzf-revamped help' for usage." ]]
}

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

host_shows() {
  local screen
  screen=$(command tmux -S "${HOST}" capture-pane -p -t host)
  [[ "${screen}" == *"$1"* ]]
}

windows_are() {
  local names
  names=$(window_names test)
  [[ "${names}" == "$1" ]]
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

panes_are() {
  local panes count
  panes=$(tmux list-panes -t test:0 -F x)
  count=$(grep -c x <<<"${panes}")
  [[ "${count}" == "$1" ]]
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
