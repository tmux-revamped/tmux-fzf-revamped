#!/usr/bin/env bats

load "${BATS_TEST_DIRNAME}/../../helpers.bash"

setup() {
  setup_test_environment
  source "${BATS_TEST_DIRNAME}/../../../src/lib/utils/constants.sh"
}

teardown() {
  cleanup_test_environment
}

@test "constants.sh - exposes the plugin version" {
  variable_exists FZF_REVAMPED_VERSION
  [[ "${FZF_REVAMPED_VERSION}" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]
}

@test "constants.sh - exposes the shared defaults" {
  variable_exists TMUX_PLUGIN_DEFAULT_MAX_AGE
  variable_exists TMUX_PLUGIN_PENDING
}

@test "constants.sh - the load guard makes a second source a no-op" {
  source "${BATS_TEST_DIRNAME}/../../../src/lib/utils/constants.sh"
  [[ "${FZF_REVAMPED_VERSION}" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]
}
