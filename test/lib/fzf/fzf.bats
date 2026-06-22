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
