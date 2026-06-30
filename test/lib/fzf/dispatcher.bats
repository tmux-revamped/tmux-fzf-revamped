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
      capture-pane)  printf 'visit https://example.com/a, then http://b.org/x. https://example.com/a\n' ;;
      list-keys)     printf 'bind-key -T prefix s choose-tree\n' ;;
      *) echo "TMUX:$*" >> "$(ACT)" ;;
    esac
  }
  _fzf() { head -n1; }
  _open() { echo "OPEN:$*" >> "$(ACT)"; }
  _zoxide() { printf '/home/u/proj\n/tmp\n'; }
  _ps() { printf '  123 vim\n  456 bash\n'; }
  _signal() { echo "SIG:$*" >> "$(ACT)"; }
}

teardown() {
  cleanup_test_environment
}

@test "fzf.sh - functions are defined" {
  function_exists fzf_run
  function_exists fzf_items
  function_exists fzf_goto
  function_exists fzf_tree
  function_exists fzf_urls
  function_exists fzf_processes
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

@test "fzf.sh - switch uses a preview window when enabled" {
  tmux set-option -gq @fzf_revamped_preview on
  run main session switch
  [[ "$(cat "$(ACT)")" == "TMUX:switch-client -t main" ]]
}

@test "fzf.sh - session list can be ordered by recency" {
  tmux set-option -gq @fzf_revamped_mru on
  _tmux() {
    case "${1}" in
      list-sessions) printf '100\tmain\tmain disp\n200\tdev\tdev disp\n' ;;
      *) echo "TMUX:$*" >> "$(ACT)" ;;
    esac
  }
  run main session switch
  [[ "$(cat "$(ACT)")" == "TMUX:switch-client -t dev" ]]
}

@test "fzf.sh - preview prints the captured pane" {
  _tmux() { echo "TMUX:$*" >> "$(ACT)"; }
  run main preview main:1.0
  [[ "$(cat "$(ACT)")" == *"capture-pane -pe -t main:1.0"* ]]
}

@test "fzf.sh - preview with an empty id does nothing" {
  _tmux() { echo "TMUX:$*" >> "$(ACT)"; }
  run main preview ""
  [[ ! -f "$(ACT)" ]]
}

@test "fzf.sh - tree routes a pane selection to select-pane" {
  _fzf() { tail -n1; }
  run main tree
  [[ "$(cat "$(ACT)")" == *"select-pane -t main:1.0"* ]]
}

@test "fzf.sh - tree routes a session selection to switch-client" {
  _fzf() { head -n1; }
  run main tree
  [[ "$(cat "$(ACT)")" == *"switch-client -t main"* ]]
}

@test "fzf.sh - tree with an empty selection does nothing" {
  _fzf() { true; }
  run main tree
  [[ ! -f "$(ACT)" ]]
}

@test "fzf.sh - create switches to a matched session" {
  _fzf() { printf 'main\nmain\tmain (3 win)\n'; }
  run main create
  [[ "$(cat "$(ACT)")" == "TMUX:switch-client -t main" ]]
}

@test "fzf.sh - create makes a new session on a miss" {
  _fzf() { printf 'newproj\n'; }
  run main create
  [[ "$(cat "$(ACT)")" == *"new-session -A -d -s newproj"* ]]
  [[ "$(cat "$(ACT)")" == *"switch-client -t newproj"* ]]
}

@test "fzf.sh - create with no query and no match does nothing" {
  _fzf() { printf '\n'; }
  run main create
  [[ ! -f "$(ACT)" ]]
}

@test "fzf.sh - urls open routes through the browser seam" {
  run main urls open
  [[ "$(cat "$(ACT)")" == "OPEN:https://example.com/a" ]]
}

@test "fzf.sh - urls copy stores the url in a tmux buffer" {
  run main urls copy
  [[ "$(cat "$(ACT)")" == *"set-buffer https://example.com/a"* ]]
}

@test "fzf.sh - urls does nothing when the pane has none" {
  _tmux() { case "${1}" in capture-pane) printf 'no links\n' ;; *) echo "TMUX:$*" >> "$(ACT)" ;; esac; }
  run main urls open
  [[ ! -f "$(ACT)" ]]
}

@test "fzf.sh - urls does nothing on an empty selection" {
  _fzf() { true; }
  run main urls open
  [[ ! -f "$(ACT)" ]]
}

@test "fzf.sh - palette runs the picked command" {
  run main palette
  [[ "$(cat "$(ACT)")" == "TMUX:new-window" ]]
}

@test "fzf.sh - palette with an empty selection does nothing" {
  _fzf() { true; }
  run main palette
  [[ ! -f "$(ACT)" ]]
}

@test "fzf.sh - cheatsheet succeeds with keys" {
  run main cheatsheet
  [ "${status}" -eq 0 ]
}

@test "fzf.sh - cheatsheet succeeds with no keys" {
  _tmux() { case "${1}" in list-keys) printf '' ;; *) : ;; esac; }
  run main cheatsheet
  [ "${status}" -eq 0 ]
}

@test "fzf.sh - process signals the picked pid after confirm" {
  fzf_confirm() { return 0; }
  run main process
  [[ "$(cat "$(ACT)")" == "SIG:TERM 123" ]]
}

@test "fzf.sh - process honors a custom signal" {
  fzf_confirm() { return 0; }
  run main process KILL
  [[ "$(cat "$(ACT)")" == "SIG:KILL 123" ]]
}

@test "fzf.sh - process aborts when not confirmed" {
  fzf_confirm() { return 1; }
  run main process
  [[ ! -f "$(ACT)" ]]
}

@test "fzf.sh - process does nothing with no processes" {
  _ps() { printf ''; }
  run main process
  [[ ! -f "$(ACT)" ]]
}

@test "fzf.sh - process does nothing on an empty selection" {
  _fzf() { true; }
  run main process
  [[ ! -f "$(ACT)" ]]
}

@test "fzf.sh - confirm is true only for yes" {
  _fzf() { printf 'yes\n'; }
  run fzf_confirm
  [ "${status}" -eq 0 ]
  _fzf() { printf 'no\n'; }
  run fzf_confirm
  [ "${status}" -eq 1 ]
}

@test "fzf.sh - rename window prompts a window rename" {
  run main rename window
  [[ "$(cat "$(ACT)")" == *"command-prompt -p New window name:"* ]]
  [[ "$(cat "$(ACT)")" == *"rename-window -t 'main:1'"* ]]
}

@test "fzf.sh - rename session prompts a session rename" {
  run main rename session
  [[ "$(cat "$(ACT)")" == *"rename-session -t 'main'"* ]]
}

@test "fzf.sh - rename pane falls back to renaming its window" {
  run main rename pane
  [[ "$(cat "$(ACT)")" == *"rename-window -t 'main:1'"* ]]
}

@test "fzf.sh - rename does nothing on an empty selection" {
  _fzf() { true; }
  run main rename window
  [[ ! -f "$(ACT)" ]]
}

@test "fzf.sh - multi-kill removes each marked object after confirm" {
  _fzf() { printf 'main\tm\n\n\tonly\ndev\td\n'; }
  fzf_confirm() { return 0; }
  run main multi-kill session
  [[ "$(cat "$(ACT)")" == *"kill-session -t main"* ]]
  [[ "$(cat "$(ACT)")" == *"kill-session -t dev"* ]]
}

@test "fzf.sh - multi-kill aborts when not confirmed" {
  _fzf() { printf 'main\tm\n'; }
  fzf_confirm() { return 1; }
  run main multi-kill session
  [[ ! -f "$(ACT)" ]]
}

@test "fzf.sh - multi-kill does nothing on an empty selection" {
  _fzf() { true; }
  run main multi-kill session
  [[ ! -f "$(ACT)" ]]
}

@test "fzf.sh - multi-kill does nothing on an empty list" {
  _tmux() { case "${1}" in list-sessions) printf '' ;; *) : ;; esac; }
  run main multi-kill session
  [[ ! -f "$(ACT)" ]]
}

@test "fzf.sh - broadcast sends the command to each marked pane" {
  _fzf() { printf 'main:1.0\tp\n\n\tx\n'; }
  run main broadcast "ls -la"
  [[ "$(cat "$(ACT)")" == *"send-keys -t main:1.0 ls -la Enter"* ]]
}

@test "fzf.sh - broadcast with no command does nothing" {
  run main broadcast ""
  [[ ! -f "$(ACT)" ]]
}

@test "fzf.sh - broadcast with an empty selection does nothing" {
  _fzf() { true; }
  run main broadcast "ls"
  [[ ! -f "$(ACT)" ]]
}

@test "fzf.sh - broadcast does nothing with no panes" {
  _tmux() { case "${1}" in list-panes) printf '' ;; *) : ;; esac; }
  run main broadcast "ls"
  [[ ! -f "$(ACT)" ]]
}

@test "fzf.sh - zoxide opens a session at the picked directory" {
  run main zoxide
  [[ "$(cat "$(ACT)")" == *"new-session -A -d -s proj -c /home/u/proj"* ]]
  [[ "$(cat "$(ACT)")" == *"switch-client -t proj"* ]]
}

@test "fzf.sh - zoxide does nothing with no directories" {
  _zoxide() { printf ''; }
  run main zoxide
  [[ ! -f "$(ACT)" ]]
}

@test "fzf.sh - zoxide does nothing on an empty selection" {
  _fzf() { true; }
  run main zoxide
  [[ ! -f "$(ACT)" ]]
}

@test "fzf.sh - last toggles to the previous session" {
  run main last
  [[ "$(cat "$(ACT)")" == "TMUX:switch-client -l" ]]
}

@test "fzf.sh - move-window prompts a move" {
  run main move-window move
  [[ "$(cat "$(ACT)")" == *"move-window -s 'main:1'"* ]]
}

@test "fzf.sh - move-window can link instead" {
  run main move-window link
  [[ "$(cat "$(ACT)")" == *"link-window -s 'main:1'"* ]]
}

@test "fzf.sh - move-window does nothing on an empty selection" {
  _fzf() { true; }
  run main move-window move
  [[ ! -f "$(ACT)" ]]
}

@test "fzf.sh - move-window does nothing with no windows" {
  _tmux() { case "${1}" in list-windows) printf '' ;; *) : ;; esac; }
  run main move-window move
  [[ ! -f "$(ACT)" ]]
}
