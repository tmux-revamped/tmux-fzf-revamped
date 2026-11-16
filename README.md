<div align="center">

# tmux-fzf-revamped

<strong>Switch to, kill, rename or create tmux sessions, windows and panes from fzf pickers in a popup.</strong>

English &nbsp;|&nbsp; [日本語](README.ja.md) &nbsp;|&nbsp; [简体中文](README.zh-Hans.md) &nbsp;|&nbsp; [繁體中文（香港）](README.zh-HK.md)

[![ci](https://img.shields.io/github/actions/workflow/status/tmux-revamped/tmux-fzf-revamped/ci.yml?branch=main&style=flat-square&label=ci)](https://github.com/tmux-revamped/tmux-fzf-revamped/actions/workflows/ci.yml)
[![release](https://img.shields.io/github/v/release/tmux-revamped/tmux-fzf-revamped?style=flat-square&label=release)](https://github.com/tmux-revamped/tmux-fzf-revamped/releases/latest)
[![openssf scorecard](https://img.shields.io/ossf-scorecard/github.com/tmux-revamped/tmux-fzf-revamped?style=flat-square&label=openssf%20scorecard)](https://scorecard.dev/viewer/?uri=github.com/tmux-revamped/tmux-fzf-revamped)
[![license](https://img.shields.io/github/license/tmux-revamped/tmux-fzf-revamped?style=flat-square&label=license)](LICENSE)

<p align="center">
  <a href="#quick-start"><strong>Quick start</strong></a> &nbsp;|&nbsp;
  <a href="#usage">Usage</a> &nbsp;|&nbsp;
  <a href="#pickers">Pickers</a> &nbsp;|&nbsp;
  <a href="#screens">Screens</a>
</p>

</div>

<p align="center">
  <img src="screens/hero.gif" alt="fzf-revamped running a palette command, switching session from the picker and returning to the last session" width="800">
</p>

```console
$ FZF_REVAMPED_SESSION_KEY=S FZF_REVAMPED_LAST_KEY=L fzf-revamped list
bind-key S display-popup -E -b rounded -w 60% -h 50% '/home/user/.tmux/plugins/tmux-fzf-revamped/bin/fzf-revamped' session switch
bind-key M-f display-popup -E -b rounded -w 60% -h 50% '/home/user/.tmux/plugins/tmux-fzf-revamped/bin/fzf-revamped' palette
bind-key L run-shell '/home/user/.tmux/plugins/tmux-fzf-revamped/bin/fzf-revamped' last
```

Press `prefix M-f` for a palette of common tmux commands. Every other picker, from the session switcher to the broadcast prompt, waits for a key you choose, so installing the whole family produces no key conflict.

---

## Quick start

### Prerequisites

| Tool | Version | Used for |
|:-----|:--------|:---------|
| tmux | 3.2 or later for popups | before 3.2 each picker opens in a window; the border needs 3.4 |
| fzf | any | every picker; `doctor` reports it missing |
| opener | optional | `open` on macOS or `xdg-open` on Linux, for the URL picker |
| zoxide | optional | the zoxide picker |
| gum | optional | the menu, tables and colours of `fzf-revamped`; without it every command prints plain text |

### Install

```tmux
set -g @plugin 'tmux-revamped/tmux-fzf-revamped'
```

Then press `prefix + I`. Without TPM, clone the repository and run its entry point from `~/.tmux.conf`:

```bash
git clone https://github.com/tmux-revamped/tmux-fzf-revamped ~/.tmux/plugins/tmux-fzf-revamped
```

```tmux
run-shell ~/.tmux/plugins/tmux-fzf-revamped/fzf-revamped.tmux
```

`make install` in the clone also puts `fzf-revamped` in `~/.local/bin`, with its man page and completions under `~/.local/share`.

### Verify

```bash
~/.tmux/plugins/tmux-fzf-revamped/bin/fzf-revamped doctor
```

## Usage

Bind the pickers you want, then reload the config or run `fzf-revamped apply`:

```tmux
set -g @fzf_revamped_session_key 'S'
set -g @fzf_revamped_window_key 'W'
set -g @fzf_revamped_last_key 'L'
```

`M-f` is this plugin's slot in the family key allocation. When you already bound `prefix M-f` yourself, the plugin leaves it alone and `doctor` says so. A key set to `off` binds nothing. When one key name is invalid, the others are still bound and `apply` exits 1 with tmux's error.

| Command | What it does |
|:--------|:-------------|
| `fzf-revamped apply` | Binds the keys now; the entry point runs it when tmux loads the plugin |
| `fzf-revamped list` | Prints every binding apply would make; `--json` prints one object |
| `fzf-revamped` with a picker name | Runs that picker, as its key does; see Pickers |
| `fzf-revamped doctor` | One row per dependency, a default key someone else holds included |
| `fzf-revamped version` | The version, then the tmux version |
| `fzf-revamped help` | The help page; `man fzf-revamped` documents the same commands and settings |
| `fzf-revamped` | On a terminal, a menu |

| tmux option | Default | Meaning |
|:------------|:--------|:--------|
| `@fzf_revamped_popup_width` | `60%` | Popup width |
| `@fzf_revamped_popup_height` | `50%` | Popup height |
| `@fzf_revamped_popup_border` | `rounded` | Popup border on tmux 3.4 and later: `rounded`, `single`, `double`, `heavy`, `simple`, `padded` or `none` |
| `@fzf_revamped_preview` | `off` | `on` or `1` shows the pane under the cursor in the switch pickers |
| `@fzf_revamped_mru` | `off` | `on` orders sessions by their last attach |

Every option is also a command option with dashes, such as `--session-key S`, and an environment variable, such as `FZF_REVAMPED_SESSION_KEY`; the command line wins over the environment, and the environment over the tmux option. An empty tmux option means its default.

<a id="pickers"></a>

## Pickers

| Key option | Command | What it does |
|:-----------|:--------|:-------------|
| `@fzf_revamped_palette_key`, `M-f` | `palette` | Runs a tmux command from a short list |
| `@fzf_revamped_session_key` | `session switch` | Switches to the session picked |
| `@fzf_revamped_window_key` | `window switch` | Switches to the window picked, in its session |
| `@fzf_revamped_pane_key` | `pane switch` | Switches to the pane picked |
| `@fzf_revamped_kill_key` | `session kill` | Kills the session picked |
| `@fzf_revamped_tree_key` | `tree` | Goes to any session, window or pane |
| `@fzf_revamped_create_key` | `create` | Switches to a session, or creates one named after what you typed |
| `@fzf_revamped_url_key` | `urls open` | Opens a URL on the screen; `urls copy` copies it into a tmux buffer |
| `@fzf_revamped_cheatsheet_key` | `cheatsheet` | Browses every key binding |
| `@fzf_revamped_process_key` | `process` | Sends TERM, or the signal given, to the process picked, after a yes |
| `@fzf_revamped_rename_key` | `rename window` | Renames the window picked through a prompt; `rename session` renames a session |
| `@fzf_revamped_multikill_key` | `multi-kill session` | Kills every session marked with `Tab`, after a yes |
| `@fzf_revamped_broadcast_key` | `broadcast` | Prompts for text, then types it and `Enter` into every pane marked |
| `@fzf_revamped_zoxide_key` | `zoxide` | Opens a session at a zoxide folder |
| `@fzf_revamped_last_key` | `last` | Switches to the last session, with no popup |
| `@fzf_revamped_move_key` | `move-window move` | Moves the window picked to a session typed at a prompt; `move-window link` links it |

`window kill`, `pane kill`, `multi-kill window` and `multi-kill pane` have no key and run from the command line. Every list line carries its target as a hidden first column, so a window named `feature/login` or a session with a space still resolves.

<a id="screens"></a>

## Screens

<details>
<summary>Every screen, recorded inside a real tmux with <code>make screens</code>, with each key on the status line</summary>
<br>

<table>
<tr>
<td width="50%" valign="top"><img src="screens/palette.png" alt="fzf-revamped: prefix M-f opens the palette"><br><sub><code>prefix M-f</code> opens the palette, from <code>hero.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/palette-split.png" alt="fzf-revamped: The palette's split-window -h run"><br><sub>The palette's <code>split-window -h</code> run, from <code>hero.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/sessions.png" alt="fzf-revamped: The session switcher with its preview"><br><sub>The session switcher with its preview, from <code>hero.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/switched.png" alt="fzf-revamped: The client on the picked session"><br><sub>The client on the picked session, from <code>hero.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/last.png" alt="fzf-revamped: The last key returns to the previous session"><br><sub>The last key returns to the previous session, from <code>hero.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/windows.png" alt="fzf-revamped: The window switcher"><br><sub>The window switcher, from <code>stills.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/panes.png" alt="fzf-revamped: The pane switcher"><br><sub>The pane switcher, from <code>stills.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/tree.png" alt="fzf-revamped: The tree of sessions, windows and panes"><br><sub>The tree of sessions, windows and panes, from <code>stills.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/create.png" alt="fzf-revamped: Create or switch, with a new name typed"><br><sub>Create or switch, with a new name typed, from <code>stills.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/created.png" alt="fzf-revamped: The new session"><br><sub>The new session, from <code>stills.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/urls.png" alt="fzf-revamped: The URLs on the screen"><br><sub>The URLs on the screen, from <code>stills.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/cheatsheet.png" alt="fzf-revamped: The cheatsheet filtered to one command"><br><sub>The cheatsheet filtered to one command, from <code>stills.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/process.png" alt="fzf-revamped: The process picker"><br><sub>The process picker, from <code>stills.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/process-confirm.png" alt="fzf-revamped: The yes or no before the signal"><br><sub>The yes or no before the signal, from <code>stills.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/rename.png" alt="fzf-revamped: The rename prompt"><br><sub>The rename prompt, from <code>stills.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/kill.png" alt="fzf-revamped: The session killer"><br><sub>The session killer, from <code>stills.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/multikill.png" alt="fzf-revamped: Two sessions marked for multi-kill"><br><sub>Two sessions marked for multi-kill, from <code>stills.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/broadcast.png" alt="fzf-revamped: Two panes marked for a broadcast"><br><sub>Two panes marked for a broadcast, from <code>stills.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/zoxide.png" alt="fzf-revamped: The zoxide folders"><br><sub>The zoxide folders, from <code>stills.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/move.png" alt="fzf-revamped: The move prompt for a window"><br><sub>The move prompt for a window, from <code>stills.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/menu.png" alt="fzf-revamped: The menu"><br><sub>The menu, from <code>stills.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/doctor.png" alt="fzf-revamped: doctor"><br><sub><code>doctor</code>, from <code>stills.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/list.png" alt="fzf-revamped: list"><br><sub><code>list</code>, from <code>stills.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/json.png" alt="fzf-revamped: list --json"><br><sub><code>list --json</code>, from <code>stills.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/plain-menu.png" alt="fzf-revamped: The menu without gum"><br><sub>The menu without gum, from <code>stills.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/plain-apply.png" alt="fzf-revamped: apply from the menu"><br><sub><code>apply</code> from the menu, from <code>stills.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/version.png" alt="fzf-revamped: The version"><br><sub>The version, from <code>stills.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/error.png" alt="fzf-revamped: An unknown command"><br><sub>An unknown command, from <code>stills.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/themes.png" alt="fzf-revamped: The header in six themes"><br><sub>The header in six themes, from <code>themes.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/help.png" alt="fzf-revamped: The help page"><br><sub>The help page, from <code>help.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/accent.png" alt="fzf-revamped: An accent from FZF_REVAMPED_ACCENT"><br><sub>An accent from <code>FZF_REVAMPED_ACCENT</code>, from <code>stills.tape</code></sub></td>
<td width="50%" valign="top"></td>
</tr>
</table>

</details>

## Portability

The plugin is POSIX `sh`. CI runs every suite on each row below.

| Shell | Status |
|:------|:-------|
| `dash`, `/bin/sh` on macOS | Supported |
| `bash` 3.2 and 5.x, the system's `zsh` and Homebrew's | Supported |

| System | Status |
|:-------|:-------|
| macOS | Tahoe on Apple Silicon and Intel, with the tools it ships, Homebrew's GNU tools and Homebrew's uutils |
| Linux | Ubuntu 26.04 on x86_64 and arm64, with GNU coreutils, uutils and BusyBox |

## Development

| Command | What it runs |
|:--------|:-------------|
| `make fmt` | shfmt `-i 2` on every script |
| `make lint` | shfmt, ShellCheck, mandoc, yamllint and actionlint, at zero findings |
| `make test` | The bats suites under the system `sh`, every picker on a real tmux server included |
| `make test-all` | The suites under every installed shell, both builds of bash and zsh on macOS |
| `make test-linux` | The suites in an Ubuntu container |
| `make coverage` | bashcov on this Mac and in the Ubuntu container, merged and gated at 100 percent |
| `make screens` | The screens above, recorded from the real plugin inside tmux with VHS, on macOS |
| `make install` | The command, its man page and completions under `PREFIX` |

Commits follow the conventional commit format and go straight to `main`. After a green `ci` run on `main`, `release.yml` runs semantic-release: every `feat` or `fix` since the last tag publishes a release, stamps the version constant and adds the notes to [`CHANGELOG.md`](CHANGELOG.md).

## License

[MIT](LICENSE), copyright Gustavo Franco.

<!-- family:begin -->

## The tmux-revamped family

This plugin is one member of the tmux-revamped family. Every member carries the same contract in [`FAMILY.md`](FAMILY.md) and the same shared library, and they are built to be installed together: no member claims a key or a tmux option that another member claims.

A defect found in one member is hunted across all of them before the fix is called done.

| Member | What it does |
|---|---|
| [`tmux-autoreload-revamped`](https://github.com/tmux-revamped/tmux-autoreload-revamped) | Edit your tmux config, save, and watch it reload itself, no key, no command |
| [`tmux-battery-revamped`](https://github.com/tmux-revamped/tmux-battery-revamped) | Battery status for your tmux status bar, without ever blocking the status render |
| [`tmux-bluetooth-revamped`](https://github.com/tmux-revamped/tmux-bluetooth-revamped) | Every connected Bluetooth device and its battery in your tmux status bar, without blocking the render |
| [`tmux-cpu-revamped`](https://github.com/tmux-revamped/tmux-cpu-revamped) | CPU load, temperature, and frequency in your tmux status bar, without ever blocking the render |
| [`tmux-disk-revamped`](https://github.com/tmux-revamped/tmux-disk-revamped) | Disk usage for your tmux status bar, without ever blocking the status render |
| [`tmux-extract-revamped`](https://github.com/tmux-revamped/tmux-extract-revamped) | Pick a URL, path, hash or any other token off the screen with fzf and type it at the cursor, in pure shell |
| [`tmux-fzf-revamped`](https://github.com/tmux-revamped/tmux-fzf-revamped) | **this plugin**, Switch to, kill, rename or create tmux sessions, windows and panes from fzf pickers in a popup |
| [`tmux-git-revamped`](https://github.com/tmux-revamped/tmux-git-revamped) | Show the active pane's git branch, changes and provider counts in the tmux status bar without blocking it |
| [`tmux-gpu-revamped`](https://github.com/tmux-revamped/tmux-gpu-revamped) | GPU load, temperature, clock, power and memory in the tmux status bar, from NVIDIA, AMD, Intel and Apple GPUs |
| [`tmux-kube-revamped`](https://github.com/tmux-revamped/tmux-kube-revamped) | Current Kubernetes context and namespace in the tmux status bar, parsed from kubeconfig without kubectl |
| [`tmux-launcher-revamped`](https://github.com/tmux-revamped/tmux-launcher-revamped) | Open any terminal app in a tmux popup, window or split from one menu, starting at the project root |
| [`tmux-logging-revamped`](https://github.com/tmux-revamped/tmux-logging-revamped) | Capture any pane to a file: live logging, full scrollback, or a one-shot screenshot |
| [`tmux-music-revamped`](https://github.com/tmux-revamped/tmux-music-revamped) | Now playing in your tmux status bar, without ever blocking the status render |
| [`tmux-network-revamped`](https://github.com/tmux-revamped/tmux-network-revamped) | Network throughput in your tmux status bar, without ever blocking the render |
| [`tmux-pain-control-revamped`](https://github.com/tmux-revamped/tmux-pain-control-revamped) | Pane and window management bindings for tmux, version aware, vim friendly, every prefix key can be disabled |
| [`tmux-persist-revamped`](https://github.com/tmux-revamped/tmux-persist-revamped) | Save every tmux session, window and pane, auto-save on a timer, and restore it all after a reboot |
| [`tmux-plugin-template`](https://github.com/tmux-revamped/tmux-plugin-template) | The starting point for a tmux-revamped plugin: shared library, bats harness and CI |
| [`tmux-pomodoro-revamped`](https://github.com/tmux-revamped/tmux-pomodoro-revamped) | A Pomodoro timer in the tmux status bar that keeps all of its state in tmux options, with no temp files |
| [`tmux-ram-revamped`](https://github.com/tmux-revamped/tmux-ram-revamped) | RAM, swap and memory pressure in the tmux status bar, sampled in the background so the render never waits |
| [`tmux-reorder-revamped`](https://github.com/tmux-revamped/tmux-reorder-revamped) | Drag a window tab along the tmux status bar with the mouse to move that window |
| [`tmux-scroll-revamped`](https://github.com/tmux-revamped/tmux-scroll-revamped) | Send the mouse wheel to apps that scroll themselves and into tmux copy-mode everywhere else |
| [`tmux-sensible-revamped`](https://github.com/tmux-revamped/tmux-sensible-revamped) | Sensible tmux defaults, gated by tmux version and terminal, that leave the options you set alone |
| [`tmux-tiling-revamped`](https://github.com/tmux-revamped/tmux-tiling-revamped) | Tiling window management for tmux: eight layouts including BSP dwindle and spiral, with layout undo |
| [`tmux-time-revamped`](https://github.com/tmux-revamped/tmux-time-revamped) | Local and world clocks for the tmux status bar, colored by time of day, with countdowns and a DST warning |
| [`tmux-weather-revamped`](https://github.com/tmux-revamped/tmux-weather-revamped) | Weather for the tmux status bar from wttr.in, fetched in the background so the status line never waits |

<!-- family:end -->
