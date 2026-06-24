<div align="center">

<h1>tmux-fzf-revamped</h1>

**Jump to any session, window, or pane, or kill it, from one fzf popup.**

[![Tests](https://github.com/tmux-revamped/tmux-fzf-revamped/actions/workflows/tests.yml/badge.svg)](https://github.com/tmux-revamped/tmux-fzf-revamped/actions/workflows/tests.yml) [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE) [![Version](https://img.shields.io/badge/version-1.1.0-blue.svg)](CHANGELOG.md)

</div>

**3** object types · **switch or kill** · **tmux 3.2 to 3.5** · **38** tests · **95%+** coverage

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

All keys are configurable, and `fzf.sh <session\|window\|pane> kill` can be bound for window and pane kills too.

## Install

With [TPM](https://github.com/tmux-plugins/tpm), add to `~/.tmux.conf`:

```tmux
set -g @plugin 'tmux-revamped/tmux-fzf-revamped'
```

Press `prefix + I`. Requires [fzf](https://github.com/junegunn/fzf) and tmux 3.2+ for `display-popup`.

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
