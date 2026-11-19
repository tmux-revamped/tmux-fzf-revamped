#!/bin/sh
# shellcheck disable=SC2034

[ -n "${FZF_REVAMPED_CORE_LOADED:-}" ] && return 0
FZF_REVAMPED_CORE_LOADED=1

readonly FZF_REVAMPED_VERSION="2.3.0"
