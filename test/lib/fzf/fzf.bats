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

@test "fzf_extract_urls finds, trims, and dedups urls in first-seen order" {
  run bash -c "printf 'see https://example.com/a, and http://b.org/x. https://example.com/a\n' | fzf_extract_urls"
  [[ "${lines[0]}" == "https://example.com/a" ]]
  [[ "${lines[1]}" == "http://b.org/x" ]]
  [ "${#lines[@]}" -eq 2 ]
}

@test "fzf_extract_urls handles ftp and file schemes" {
  run bash -c "printf 'ftp://host/f file:///etc/hosts\n' | fzf_extract_urls"
  [[ "${output}" == *"ftp://host/f"* ]]
  [[ "${output}" == *"file:///etc/hosts"* ]]
}

@test "fzf_extract_urls prints nothing when there are no urls" {
  run bash -c "printf 'plain text only\n' | fzf_extract_urls"
  [[ -z "${output}" ]]
}

@test "fzf_valid_signal normalizes and defaults" {
  [[ "$(fzf_valid_signal term)" == "TERM" ]]
  [[ "$(fzf_valid_signal SIGKILL)" == "KILL" ]]
  [[ "$(fzf_valid_signal hup)" == "HUP" ]]
  [[ "$(fzf_valid_signal bogus)" == "TERM" ]]
  [[ "$(fzf_valid_signal)" == "TERM" ]]
}

@test "fzf_signal_list offers the signal menu" {
  run fzf_signal_list
  [[ "${output}" == *"TERM"* ]]
  [[ "${output}" == *"KILL"* ]]
}

@test "fzf_palette_list offers common commands" {
  run fzf_palette_list
  [[ "${output}" == *"new-window"* ]]
  [[ "${output}" == *"split-window -h"* ]]
}

@test "fzf_pid_of returns the leading numeric field" {
  [[ "$(fzf_pid_of "  123 vim")" == "123" ]]
  [[ "$(fzf_pid_of "456 bash -l")" == "456" ]]
}

@test "fzf_target_kind classifies by id shape" {
  [[ "$(fzf_target_kind "main")" == "session" ]]
  [[ "$(fzf_target_kind "main:1")" == "window" ]]
  [[ "$(fzf_target_kind "main:1.0")" == "pane" ]]
}

@test "fzf_session_name builds a tmux-safe basename" {
  [[ "$(fzf_session_name "/home/u/my proj")" == "my_proj" ]]
  [[ "$(fzf_session_name "/home/u/v1.2")" == "v1_2" ]]
  [[ "$(fzf_session_name "/data/")" == "data" ]]
  [[ "$(fzf_session_name "solo")" == "solo" ]]
}

@test "fzf_mru_sort orders by epoch desc and drops the key" {
  run bash -c "printf '100\tmain\tmain disp\n200\tdev\tdev disp\n' | fzf_mru_sort"
  [[ "${lines[0]}" == "$(printf 'dev\tdev disp')" ]]
  [[ "${lines[1]}" == "$(printf 'main\tmain disp')" ]]
}
