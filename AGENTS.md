# tmux-fzf-revamped

Guidance for anyone, human or agent, changing tmux-fzf-revamped. What it is and how to use it lives in [README.md](README.md).

[FAMILY.md](FAMILY.md) holds everything this plugin shares with the rest of the tmux-revamped family, and it is the same in every member. This file holds only what is exclusive to tmux-fzf-revamped, under the same headings as the agent guide of every member. Read both before changing anything; a rule that would serve the other members goes into [`FAMILY.md`](FAMILY.md) instead of here.

## Layout

| Path | Holds |
|:-----|:------|
| [`fzf-revamped.tmux`](fzf-revamped.tmux) | The entry point TPM runs: it runs `bin/fzf-revamped apply` |
| [`bin/fzf-revamped`](bin/fzf-revamped) | The command: `apply`, `list`, every picker, `preview`, `doctor`, `version`, `help` and the menu. `apply` and the pickers run without loading the interface modules |
| [`lib/fzf.sh`](lib/fzf.sh) | Reading the settings, the binding plan, the target lists and every picker |
| [`lib/arrange.sh`](lib/arrange.sh), [`lib/pickers.sh`](lib/pickers.sh) | The pane arranger, and the buffer and project pickers |
| [`lib/state.sh`](lib/state.sh) | Every global, including `FZF_REVAMPED_SETTINGS`, the table of setting names and defaults the rest reads |
| [`lib/core.sh`](lib/core.sh) | The version |
| [`lib/`](lib) | Every other file is the shared library, identical in every member |
| [`test/fzf.bats`](test/fzf.bats), [`test/pickers.bats`](test/pickers.bats), [`test/commands.bats`](test/commands.bats), [`test/entrypoint.bats`](test/entrypoint.bats), [`test/arrange.bats`](test/arrange.bats), [`test/sources.bats`](test/sources.bats), [`test/keys.bats`](test/keys.bats) | This member's suites: the helpers and the plan through stubs, the commands, every picker on a private tmux server, and every key pressed through a second tmux attached to it; the last four share [`test/pickers_helpers.bash`](test/pickers_helpers.bash) |
| [`screens/`](screens) | The tapes and the recording's tmux config |

## Names

- Settings are the tmux options `@fzf_revamped_<setting>` listed in `FZF_REVAMPED_SETTINGS`, the long options with dashes, such as `--session-key`, and the environment variables `FZF_REVAMPED_<SETTING>`.
- The broadcast key's prompt writes `@fzf_revamped_broadcast_text`, which `broadcast` reads and clears; it is state, never a setting.
- It has no status placeholders.
- The version constant is `FZF_REVAMPED_VERSION`.
- The command's own functions and the library's never share a name, because the command is sourced after the library and would replace it.

## Behaviour

- `apply` reads every setting with one `tmux display-message` call and one `env` read, reads `list-keys -T prefix` once for the palette key, builds the plan, and sends every binding to tmux in one call. When that call fails, it sends each binding alone, so one invalid key leaves the others bound and `apply` exits 1 with tmux's error.
- A picker key opens `display-popup -E` on tmux 3.2 and later, with a `-b` border on 3.4 and later, and `new-window` before 3.2; the last key runs `run-shell` with no popup.
- A key set to `off` binds nothing, an empty one means its default, and a palette key the person bound before the plugin loaded stays theirs and is reported by `doctor`.
- A picker with nothing to list says so in a tmux message, since its popup would otherwise open and close in the same instant: no URL on the screen, no folder from zoxide, no paste buffer, or no project in the projects file, whose path the message names.
- The pickers read `preview`, `mru` and `projects` from the tmux options when they run, so a change needs no reload; one `apply` got from the command line or the environment rides on the picker keys as an option, since neither exists when tmux runs a key. `FZF_REVAMPED_PICK_NAMES` lists what rides.
- Everything placed in a binding goes through `fzf_revamped_quote`, which single-quotes it and writes each `#` as `"$(printf '%b' '\0043')"`, so a checkout path holding a hash runs the same from a popup, a window or `run-shell`, whether or not tmux expands formats there.
- The entry point clears every inherited `REVAMPED_` variable except the test switches, and every `FZF_REVAMPED_*_LOADED` guard; every other global is assigned outright in the state file.

## Domain rules

- Every list line carries its target as a hidden first column read with `--delimiter` and `--with-nth 2`, so a window named `feature/login` or a session with a space still resolves.
- Window and pane switches run `switch-client` and then the select as separate calls, so the select still happens when there is no client to switch.
- Process and multi-kill ask for a `yes` in fzf before they act.
- Rename and move-window ask for the name or the session on the popup's own terminal, then run the tmux command themselves: a `command-prompt` started inside a popup never receives the keys typed, so it would change nothing. Without a terminal they stop with the usage hint before picking.
- Broadcast types the text with `send-keys -l`, then `Enter`, into each marked pane.
- Arrange and the buffer paste act on the pane under the popup, read with `display-message -p`. Join lists the panes of other windows, break the panes that share a window, and swap every pane but this one; layout offers the two mirrored layouts on tmux 3.5 and later, and resize offers each side at 5, 10 and 20 cells.
- Buffers lists `list-buffers` with tmux's own sample of each buffer and pastes with `paste-buffer -p`, so an app that asked for bracketed paste gets it.
- The projects file is read line by line in the shell: a line is expanded as a glob with the newline as the only separator, so a folder with a space survives, and only folders are kept. One `sed` names every session, by the rule the zoxide picker uses, and one `awk` marks the running ones. The default file is `fzf-revamped/projects` under `XDG_CONFIG_HOME`, or under `~/.config`.

## Release

- `FZF_REVAMPED_VERSION` in [`lib/core.sh`](lib/core.sh) holds the version. Nobody edits it by hand.
- After a green `ci` run on `main`, [`release.yml`](.github/workflows/release.yml) runs semantic-release: a `feat` or `fix` since the last tag publishes a release, [`set-version.sh`](.github/scripts/set-version.sh) stamps the constant, and the notes go into [`CHANGELOG.md`](CHANGELOG.md).

## Gaps against FAMILY.md

As of 2026-11-17, none.
