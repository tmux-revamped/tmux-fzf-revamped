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

One key by default, the palette, which reaches every picker.

| Key | Action |
|-----|--------|
| `prefix + M-f` | command palette: every picker in one menu |

Every other action ships unbound so that installing the whole family produces
no key conflict. Bind the ones you want:

```tmux
set -g @fzf_revamped_session_key s
set -g @fzf_revamped_window_key w
set -g @fzf_revamped_pane_key e
set -g @fzf_revamped_kill_key X
set -g @fzf_revamped_tree_key T
set -g @fzf_revamped_create_key C
set -g @fzf_revamped_url_key u
set -g @fzf_revamped_cheatsheet_key /
set -g @fzf_revamped_process_key k
set -g @fzf_revamped_rename_key R
set -g @fzf_revamped_multikill_key K
set -g @fzf_revamped_broadcast_key b
set -g @fzf_revamped_zoxide_key G
set -g @fzf_revamped_last_key L
set -g @fzf_revamped_move_key M
```

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

<!-- family:begin -->

## The tmux-revamped family

This plugin is one member of the tmux-revamped family. Every member carries the
same contract in [`FAMILY.md`](FAMILY.md), the same tooling under `family/`, and
the same shared library, all held byte-identical by a checksum manifest. They are
built to be installed together: no member claims a key or a tmux option that
another member claims.

A defect found in one member is hunted across all of them before the fix is
called done. That obligation is written into the contract rather than left to
memory, and `family/bin/sweep` is how it is discharged.

| Member | What it does |
|---|---|
| [`tmux-autoreload-revamped`](https://github.com/tmux-revamped/tmux-autoreload-revamped) | Edit your tmux config, save, and watch it reload itself, no key, no command |
| [`tmux-battery-revamped`](https://github.com/tmux-revamped/tmux-battery-revamped) | Battery status for your tmux status bar, without ever blocking the status render |
| [`tmux-bluetooth-revamped`](https://github.com/tmux-revamped/tmux-bluetooth-revamped) | Every connected Bluetooth device and its battery in your tmux status bar, without blocking the render |
| [`tmux-cpu-revamped`](https://github.com/tmux-revamped/tmux-cpu-revamped) | CPU load, temperature, and frequency in your tmux status bar, without ever blocking the render |
| [`tmux-disk-revamped`](https://github.com/tmux-revamped/tmux-disk-revamped) | Disk usage for your tmux status bar, without ever blocking the status render |
| [`tmux-extract-revamped`](https://github.com/tmux-revamped/tmux-extract-revamped) | Fuzzy-grab any URL, path, or word off the screen and paste it, pure shell, no Python |
| [`tmux-fzf-revamped`](https://github.com/tmux-revamped/tmux-fzf-revamped) | **this plugin**, Jump to any session, window, or pane, or kill it, from one fzf popup |
| [`tmux-git-revamped`](https://github.com/tmux-revamped/tmux-git-revamped) | Git repository status in your tmux status bar, without ever blocking the render |
| [`tmux-gpu-revamped`](https://github.com/tmux-revamped/tmux-gpu-revamped) | GPU load, temperature, frequency, and memory for your tmux status bar |
| [`tmux-kube-revamped`](https://github.com/tmux-revamped/tmux-kube-revamped) | Current Kubernetes context and namespace in your tmux status bar, async, kubectl-free, never blocking |
| [`tmux-launcher-revamped`](https://github.com/tmux-revamped/tmux-launcher-revamped) | Launch any TUI app in a popup or a window, scoped to the current pane's directory, with one configurable bindi |
| [`tmux-logging-revamped`](https://github.com/tmux-revamped/tmux-logging-revamped) | Capture any pane to a file: live logging, full scrollback, or a one-shot screenshot |
| [`tmux-music-revamped`](https://github.com/tmux-revamped/tmux-music-revamped) | Now playing in your tmux status bar, without ever blocking the status render |
| [`tmux-network-revamped`](https://github.com/tmux-revamped/tmux-network-revamped) | Network throughput in your tmux status bar, without ever blocking the render |
| [`tmux-pain-control-revamped`](https://github.com/tmux-revamped/tmux-pain-control-revamped) | Standard pane and window management bindings for tmux, version aware, vim friendly, and fully configurable |
| [`tmux-persist-revamped`](https://github.com/tmux-revamped/tmux-persist-revamped) | One plugin that captures every session, window, pane, layout, and working |
| [`tmux-plugin-template`](https://github.com/tmux-revamped/tmux-plugin-template) | A template for building non-blocking tmux status plugins |
| [`tmux-pomodoro-revamped`](https://github.com/tmux-revamped/tmux-pomodoro-revamped) | A Pomodoro timer in your tmux status bar, with zero temp files: all state lives in tmux options |
| [`tmux-ram-revamped`](https://github.com/tmux-revamped/tmux-ram-revamped) | RAM usage for your tmux status bar, without ever blocking the status render |
| [`tmux-scroll-revamped`](https://github.com/tmux-revamped/tmux-scroll-revamped) | Mouse wheel that does the right thing: scroll the app directly, copy-mode everywhere else. No app names to con |
| [`tmux-sensible-revamped`](https://github.com/tmux-revamped/tmux-sensible-revamped) | Sensible tmux defaults that normalize behavior across every tmux version, OS, and terminal, without clobbering |
| [`tmux-tiling-revamped`](https://github.com/tmux-revamped/tmux-tiling-revamped) | --- |
| [`tmux-time-revamped`](https://github.com/tmux-revamped/tmux-time-revamped) | Local clock and world clocks in your tmux status bar, without ever blocking the render |
| [`tmux-weather-revamped`](https://github.com/tmux-revamped/tmux-weather-revamped) | Weather in your tmux status bar, fetched in the background so the render never waits on the network |

### Checking an installation

With every member on disk, one command reports any conflict between them:

```sh
family/bin/doctor --live
```

It reads each member and the running tmux server, and reports duplicate keys,
duplicate status placeholders, options outside the naming grammar, and any
member whose contract version has fallen behind.

<!-- family:end -->
