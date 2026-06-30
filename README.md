<div align="center">

<h1>tmux-fzf-revamped</h1>

**Jump to any session, window, or pane, or kill it, from one fzf popup.**

[![Tests](https://github.com/tmux-revamped/tmux-fzf-revamped/actions/workflows/tests.yml/badge.svg)](https://github.com/tmux-revamped/tmux-fzf-revamped/actions/workflows/tests.yml) [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE) [![Version](https://img.shields.io/badge/version-1.2.0-blue.svg)](CHANGELOG.md)

</div>

**switch · kill · create · tree · broadcast** · **tmux 3.2 to 3.5** · **103** tests · **95%+** coverage

A fast fzf interface for navigating tmux. Fuzzy-search your sessions, windows, or panes and jump straight to the choice, or kill it. Each picker runs in a popup, and the hidden target id rides along in the list so a window named `feature/login` still resolves to the right place.

Built from [tmux-plugin-template](https://github.com/tmux-revamped/tmux-plugin-template).

<table>
<tr>
<td><strong>One interface, three scopes</strong><br>Sessions, windows, and panes, each on its own key, all through the same picker.</td>
<td><strong>Switch or kill</strong><br>Jump to the selection or remove it; the kill pickers reuse the same lists.</td>
</tr>
<tr>
<td><strong>Exact targeting</strong><br>The target id travels as a hidden column, so spaces and slashes in names never break navigation.</td>
<td><strong>Popup-native</strong><br>Runs in a tmux popup over your current pane, no split, no clutter.</td>
</tr>
</table>

## Keys

| Key | Action |
|-----|--------|
| `prefix + s` | switch session |
| `prefix + w` | switch window |
| `prefix + e` | switch pane |
| `prefix + X` | kill session |
| `prefix + T` | tree view across sessions, windows, and panes |
| `prefix + C` | switch to a session, or create one from the typed name |
| `prefix + u` | open a URL from the current pane's scrollback |
| `prefix + O` | command palette of common tmux commands |
| `prefix + /` | search the keybinding list |
| `prefix + k` | pick a process and send it a signal (confirmed) |
| `prefix + R` | rename a window |
| `prefix + K` | mark several sessions and kill them (confirmed) |
| `prefix + b` | broadcast a command to several marked panes |
| `prefix + G` | open or attach a session at a zoxide directory |
| `prefix + L` | toggle to the last session |
| `prefix + M` | move a window into another session |

All keys are configurable. The dispatcher also accepts `fzf.sh <session\|window\|pane> kill` for window and pane kills, `fzf.sh urls copy` to copy instead of open, `fzf.sh process <SIGNAL>` for a non-default signal, `fzf.sh rename session`, `fzf.sh multi-kill <mode>`, and `fzf.sh move-window link`.

## Install

With [TPM](https://github.com/tmux-plugins/tpm), add to `~/.tmux.conf`:

```tmux
set -g @plugin 'tmux-revamped/tmux-fzf-revamped'
```

Press `prefix + I`. Requires [fzf](https://github.com/junegunn/fzf) and tmux 3.2+ for `display-popup`. [zoxide](https://github.com/ajeetdsouza/zoxide) is optional and only powers the directory picker.

## Configuration

| Option | Default | Meaning |
|--------|---------|---------|
| `@fzf_revamped_session_key` | `s` | switch-session key |
| `@fzf_revamped_window_key` | `w` | switch-window key |
| `@fzf_revamped_pane_key` | `e` | switch-pane key |
| `@fzf_revamped_kill_key` | `X` | kill-session key |
| `@fzf_revamped_popup_width` | `60%` | popup width |
| `@fzf_revamped_popup_height` | `50%` | popup height |
| `@fzf_revamped_popup_border` | `rounded` | popup border style on tmux 3.4+ (`rounded`, `single`, `double`, `heavy`, `simple`, `padded`, or `none`); ignored on older tmux |
| `@fzf_revamped_preview` | _(off)_ | set to `on` to show a live pane preview in the switch pickers |
| `@fzf_revamped_mru` | _(off)_ | set to `on` to order the session picker by most recent attach |
| `@fzf_revamped_tree_key` | `T` | tree-view key |
| `@fzf_revamped_create_key` | `C` | create-on-miss key |
| `@fzf_revamped_url_key` | `u` | URL picker key |
| `@fzf_revamped_palette_key` | `O` | command-palette key |
| `@fzf_revamped_cheatsheet_key` | `/` | keybinding-search key |
| `@fzf_revamped_process_key` | `k` | process-killer key |
| `@fzf_revamped_rename_key` | `R` | rename key |
| `@fzf_revamped_multikill_key` | `K` | multi-kill key |
| `@fzf_revamped_broadcast_key` | `b` | broadcast key |
| `@fzf_revamped_zoxide_key` | `G` | zoxide-directory key |
| `@fzf_revamped_last_key` | `L` | last-session toggle key |
| `@fzf_revamped_move_key` | `M` | move-window key |

## Compatibility

Needs tmux 3.2+ for `display-popup` and fzf on the path. Runs on Linux (x86_64 and arm64) and macOS (Intel and Apple Silicon).

## Development

```bash
make test    # bats suite
make lint    # shellcheck
make coverage  # kcov line coverage on Linux
```

The id extraction and mode validation live in [`src/lib/fzf/fzf.sh`](src/lib/fzf/fzf.sh) as pure functions. Every tmux call routes through a single seam, so the switch and kill routing is fully tested without a tmux server or fzf.

## License

[MIT](LICENSE), copyright Gustavo Franco.
