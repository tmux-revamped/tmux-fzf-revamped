#!/usr/bin/env bats

load "${BATS_TEST_DIRNAME}/helpers.bash"

ENTRYPOINT="${BATS_TEST_DIRNAME}/../fzf-revamped.tmux"

setup() {
  setup_test_environment
  PLUGIN_COPY="${BATS_TEST_TMPDIR}/plug in'dir"
  mkdir -p "${PLUGIN_COPY}/src"
  cp "${ENTRYPOINT}" "${PLUGIN_COPY}/fzf-revamped.tmux"
  cat > "${PLUGIN_COPY}/src/fzf.sh" <<'STUB'
#!/usr/bin/env bash
case "${1}" in
  supports-popup) exit "${STUB_POPUP_STATUS:-0}" ;;
  border-flag) exit 0 ;;
esac
printf '%s\n' "$*" >> "${STUB_LOG}"
STUB
  chmod +x "${PLUGIN_COPY}/src/fzf.sh"
  export STUB_LOG="${BATS_TEST_TMPDIR}/stub.log"
  export BIND_LOG="${BATS_TEST_TMPDIR}/bind.log"
  export STUB_POPUP_STATUS=0
  : > "${BIND_LOG}"
  tmux() {
    case "${1}" in
      -V) printf 'tmux 3.5a\n' ;;
      show-option)
        local file
        file="$(_mock_opt_file "${3}")"
        [ -f "${file}" ] && cat "${file}"
        return 0
        ;;
      bind-key)
        shift
        printf '%s\037' "$@" >> "${BIND_LOG}"
        printf '\n' >> "${BIND_LOG}"
        ;;
    esac
    return 0
  }
  export -f tmux
}

teardown() {
  cleanup_test_environment
}

set_opt() {
  printf '%s' "${2}" > "$(_mock_opt_file "${1}")"
}

bound_command() {
  local line
  local fields
  while IFS= read -r line; do
    IFS=$'\037' read -r -a fields <<< "${line}"
    if [ "${fields[0]}" = "${1}" ]; then
      printf '%s' "${fields[${#fields[@]}-1]}"
      return 0
    fi
  done < "${BIND_LOG}"
  return 1
}

@test "fzf-revamped.tmux - popup command runs from a path with a space and a quote" {
  # Arrange
  set_opt @fzf_revamped_session_key s
  bash "${PLUGIN_COPY}/fzf-revamped.tmux"

  # Act
  sh -c "$(bound_command s)"

  # Assert
  [ "$(cat "${STUB_LOG}")" = "session switch" ]
}

@test "fzf-revamped.tmux - new-window fallback runs from a path with a space and a quote" {
  # Arrange
  export STUB_POPUP_STATUS=1
  set_opt @fzf_revamped_window_key w
  bash "${PLUGIN_COPY}/fzf-revamped.tmux"

  # Act
  sh -c "$(bound_command w)"

  # Assert
  [ "$(cat "${STUB_LOG}")" = "window switch" ]
}

@test "fzf-revamped.tmux - last-session run-shell runs from a path with a space and a quote" {
  # Arrange
  set_opt @fzf_revamped_last_key L
  bash "${PLUGIN_COPY}/fzf-revamped.tmux"

  # Act
  sh -c "$(bound_command L)"

  # Assert
  [ "$(cat "${STUB_LOG}")" = "last" ]
}

@test "fzf-revamped.tmux - unset keys stay unbound and only the palette binds" {
  # Arrange
  local first_key

  # Act
  bash "${PLUGIN_COPY}/fzf-revamped.tmux"

  # Assert
  first_key="$(head -n1 "${BIND_LOG}" | cut -d "$(printf '\037')" -f1)"
  [ "$(wc -l < "${BIND_LOG}" | tr -d ' ')" = "1" ] || false
  [ "${first_key}" = "M-f" ]
}

@test "fzf-revamped.tmux - a key set to off binds nothing" {
  # Arrange
  set_opt @fzf_revamped_palette_key off

  # Act
  bash "${PLUGIN_COPY}/fzf-revamped.tmux"

  # Assert
  [ ! -s "${BIND_LOG}" ]
}

@test "fzf-revamped.tmux - broadcast prompt stores quoted input and opens a tmux-quoted popup" {
  # Arrange
  local suffix
  suffix='/plug\\ in\\'"'"'dir/src/fzf.sh broadcast"'
  set_opt @fzf_revamped_broadcast_key b

  # Act
  bash "${PLUGIN_COPY}/fzf-revamped.tmux"

  # Assert
  [ "$(bound_command b)" = "set-option -g @fzf_revamped_broadcast_text \"%%%\" ; display-popup -E -w 60% -h 50% \"${BATS_TEST_TMPDIR}${suffix}" ]
}
