#!/usr/bin/env bats

load "${BATS_TEST_DIRNAME}/../../helpers.bash"

setup() {
  setup_test_environment
  unset _FZF_REVAMPED_LOADED
  source "${BATS_TEST_DIRNAME}/../../../src/lib/fzf/fzf.sh"
}

teardown() {
  cleanup_test_environment
}

@test "fzf_id_of extracts the id before the tab" {
  [[ "$(fzf_id_of "$(printf 'main\tmain  (3 windows)')")" == "main" ]]
}

@test "fzf_id_of returns the whole line when there is no tab" {
  [[ "$(fzf_id_of "plain")" == "plain" ]]
}

@test "fzf_valid_mode accepts known modes and defaults the rest" {
  [[ "$(fzf_valid_mode session)" == "session" ]]
  [[ "$(fzf_valid_mode window)" == "window" ]]
  [[ "$(fzf_valid_mode pane)" == "pane" ]]
  [[ "$(fzf_valid_mode bogus)" == "session" ]]
}

@test "fzf_version_ge compares major and minor numbers" {
  run fzf_version_ge 3.4 3.2
  [ "${status}" -eq 0 ]
  run fzf_version_ge 3.10 3.4
  [ "${status}" -eq 0 ]
  run fzf_version_ge 3.2 3.4
  [ "${status}" -eq 1 ]
  run fzf_version_ge 3.4a 3.4
  [ "${status}" -eq 0 ]
  run fzf_version_ge 2.9 3.0
  [ "${status}" -eq 1 ]
}

@test "fzf_supports_popup needs tmux 3.2" {
  run fzf_supports_popup 3.2
  [ "${status}" -eq 0 ]
  run fzf_supports_popup 3.1
  [ "${status}" -eq 1 ]
}

@test "fzf_border_flag is gated on tmux 3.4 and a real style" {
  [[ "$(fzf_border_flag 3.4 rounded)" == "-b rounded" ]]
  [[ "$(fzf_border_flag 3.5 double)" == "-b double" ]]
  [[ -z "$(fzf_border_flag 3.3 rounded)" ]]
  [[ -z "$(fzf_border_flag 3.4 none)" ]]
  [[ -z "$(fzf_border_flag 3.4 '')" ]]
}
