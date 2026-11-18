#!/usr/bin/env bash
# shellcheck disable=SC2016,SC2030,SC2031,SC2034,SC2154

# shellcheck source=test/tmux_helpers.bash
source "${BATS_TEST_DIRNAME:-.}/tmux_helpers.bash"

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

said() {
  local messages
  messages=$(tmux show-messages)
  [[ "${messages}" == *"$1"* ]]
}

tmux_shows() {
  local screen
  screen=$(tmux capture-pane -p -t "$1")
  [[ "${screen}" == *"$2"* ]]
}

session_at() {
  local now
  now=$(tmux display-message -p -t "$1" '#{pane_current_path}')
  [[ "${now}" == "$2" || "${now}" == "$3" ]]
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

panes_are() {
  local panes count
  panes=$(tmux list-panes -t test:0 -F x)
  count=$(grep -c x <<<"${panes}")
  [[ "${count}" == "$1" ]]
}

shows() {
  local now
  now=$(tmux display-message -p -t "$1" "$2" 2>/dev/null)
  [[ "${now}" == "$3" ]]
}

gone() {
  ! tmux has-session -t "$1" 2>/dev/null
}

file_holds() {
  [[ -f "$1" ]] || return 1
  grep -qF -- "$2" "$1"
}

windows_of() {
  local names
  names=$(window_names "$1")
  [[ "${names}" == "$2" ]]
}

bound_on() {
  tmux set-option -g "@fzf_revamped_$1" "$2"
  tmux set-environment -g PATH "${BATS_TEST_TMPDIR}/stubs:${PATH}"
  load_plugin "${ROOT}"
}
