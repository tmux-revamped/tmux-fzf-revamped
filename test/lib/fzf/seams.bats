#!/usr/bin/env bats

load "${BATS_TEST_DIRNAME}/../../helpers.bash"

DISPATCHER="${BATS_TEST_DIRNAME}/../../../src/fzf.sh"

setup() {
  setup_test_environment
  unset _FZF_REVAMPED_LOADED
  source "${DISPATCHER}"
}

teardown() {
  cleanup_test_environment
}

@test "seam _fzf forwards to a (stubbed) fzf" {
  fzf() { cat; }
  result="$(printf 'x\n' | _fzf --reverse)"
  [[ "${result}" == "x" ]]
}

@test "seam _open forwards to a (stubbed) opener" {
  open() { echo "opened:$*"; }
  run _open https://example.com
  [[ "${output}" == "opened:https://example.com" ]]
}

@test "seam _zoxide forwards to a (stubbed) zoxide" {
  zoxide() { printf '/a\n/b\n'; }
  run _zoxide
  [[ "${output}" == *"/a"* ]]
}

@test "seam _ps lists processes" {
  run _ps
  [ "${status}" -eq 0 ]
  [[ -n "${output}" ]]
}

@test "seam _signal forwards to a (stubbed) kill" {
  kill() { echo "killed:$*"; }
  run _signal TERM 99999
  [[ "${output}" == *"TERM 99999"* ]]
}

@test "seam _tmux forwards to (mocked) tmux" {
  run _tmux -V
  [ "${status}" -eq 0 ]
}
