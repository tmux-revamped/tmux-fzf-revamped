#!/usr/bin/env bats

load "${BATS_TEST_DIRNAME}/../../helpers.bash"

DISPATCHER="${BATS_TEST_DIRNAME}/../../../src/fzf.sh"
ACT() { printf '%s' "${BATS_TEST_TMPDIR}/act"; }

setup() {
  setup_test_environment
  unset _FZF_REVAMPED_LOADED
  source "${DISPATCHER}"
  _tmux() {
    case "${1}" in
      list-sessions) printf 'main\tmain (3 win)\ndev\tdev (1 win)\n' ;;
      list-windows)  printf 'main:1\tmain:1 editor\n' ;;
      list-panes)    printf 'main:1.0\tmain:1.0 vim\n' ;;
      *) echo "TMUX:$*" >> "$(ACT)" ;;
    esac
  }
  _fzf() { head -n1; }
}

teardown() {
  cleanup_test_environment
}

@test "fzf.sh - functions are defined" {
  function_exists fzf_run
  function_exists fzf_items
  function_exists fzf_goto
}

@test "fzf.sh - session switch jumps to the selection" {
  run main session switch
  [[ "$(cat "$(ACT)")" == "TMUX:switch-client -t main" ]]
}

@test "fzf.sh - window switch selects the window" {
  run main window switch
  [[ "$(cat "$(ACT)")" == *"select-window -t main:1"* ]]
}

@test "fzf.sh - pane switch selects the pane" {
  run main pane switch
  [[ "$(cat "$(ACT)")" == *"select-pane -t main:1.0"* ]]
}

@test "fzf.sh - kill routes to each object type" {
  run main session kill
  [[ "$(cat "$(ACT)")" == "TMUX:kill-session -t main" ]]
  rm -f "$(ACT)"
  run main window kill
  [[ "$(cat "$(ACT)")" == "TMUX:kill-window -t main:1" ]]
  rm -f "$(ACT)"
  run main pane kill
  [[ "$(cat "$(ACT)")" == "TMUX:kill-pane -t main:1.0" ]]
}

@test "fzf.sh - an invalid mode falls back to session" {
  run main bogus switch
  [[ "$(cat "$(ACT)")" == "TMUX:switch-client -t main" ]]
}

@test "fzf.sh - an empty selection does nothing" {
  _fzf() { true; }
  run main session switch
  [[ ! -f "$(ACT)" ]]
}

@test "fzf.sh - an empty list does nothing" {
  _tmux() { case "${1}" in list-sessions) printf '' ;; *) echo "TMUX:$*" >> "$(ACT)" ;; esac; }
  run main session switch
  [[ ! -f "$(ACT)" ]]
}

@test "fzf.sh - the tmux seam is callable" {
  unset _FZF_REVAMPED_LOADED
  source "${DISPATCHER}"
  run _tmux -V
  [ "${status}" -eq 0 ]
}

@test "fzf.sh - border-flag subcommand prints a gated flag" {
  run main border-flag 3.4 rounded
  [[ "${output}" == "-b rounded" ]]
  run main border-flag 3.2 rounded
  [[ -z "${output}" ]]
}

@test "fzf.sh - supports-popup subcommand reflects the version" {
  run main supports-popup 3.2
  [ "${status}" -eq 0 ]
  run main supports-popup 3.0
  [ "${status}" -eq 1 ]
}
