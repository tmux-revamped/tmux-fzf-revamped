# tmux-fzf-revamped

Guidance for anyone, human or agent, changing tmux-fzf-revamped. What it is and how to use it lives in [README.md](README.md).

[FAMILY.md](FAMILY.md) holds everything this plugin shares with the rest of the tmux-revamped family, and it is the same in every member. This file holds only what is exclusive to tmux-fzf-revamped, under the same headings as the agent guide of every member. Read both before changing anything; a rule that would serve the other members goes into [`FAMILY.md`](FAMILY.md) instead of here.

## Layout

| Path | Holds |
|:-----|:------|
| [`fzf-revamped.tmux`](fzf-revamped.tmux) | The entry point TPM runs |
| [`src/fzf.sh`](src/fzf.sh) | The script the entry point and the keys call |
| [`src/lib/fzf/`](src/lib/fzf) | This member's modules |
| [`src/lib/utils/constants.sh`](src/lib/utils/constants.sh) | This member's constants, including its version |
| [`src/lib/utils/`](src/lib/utils), [`src/lib/tmux/`](src/lib/tmux) | The shared library. Every file there except `constants.sh` is identical in every member |
| [`test/`](test) | The bats suite. `helpers.bash` and `tmux_helpers.bash` are identical in every member; this member's own mocks go in the `_local` files |

## Names

- Settings are tmux options named `@fzf_revamped_<setting>`.
- It has no status placeholders.
- Public functions carry `fzf_`; private ones start with `_`.
- The version constant is `FZF_REVAMPED_VERSION`.
- Its command-line tool, once it exists, is `fzf-revamped`.

## Behaviour

- Switches to, kills, renames or creates sessions, windows and panes from fzf pickers in a popup.
- `M-f` opens the picker menu.
- The entry point checks the tmux version and binds each key to `display-popup -E`, or to `new-window` before tmux 3.2, running [`src/fzf.sh`](src/fzf.sh).

## Domain rules

- Each list line carries the target id as a hidden first column that fzf does not show, so a window named `feature/login` or a session with a space in its name still resolves to the right target.

## Release

- `FZF_REVAMPED_VERSION` in [`src/lib/utils/constants.sh`](src/lib/utils/constants.sh) holds the version. It must equal the newest versioned heading in [`CHANGELOG.md`](CHANGELOG.md) and the README's version badge, which the `version` job in `tests.yml` checks.
- A push to `main` whose version has no tag yet makes the `release` job in `tests.yml` tag `vX.Y.Z` and publish a GitHub release with that changelog section.
- Unreleased changes sit under `## [Unreleased]` in [`CHANGELOG.md`](CHANGELOG.md) until a release is cut.

## Gaps against FAMILY.md

As of 2026-11-15:

- Every script is bash, under `#!/usr/bin/env bash`, not POSIX `sh`, so it is untested under `dash`, `zsh` and BusyBox `sh`.
- The code lives in [`src/`](src) and [`src/lib/`](src/lib); there is no `bin/fzf-revamped`, `lib/state.sh` or `lib/core.sh`.
- No `fzf-revamped` command with `help`, `version` and `doctor` in the family's form, no man page, no completions and no `manifest.json`.
- No gum interface: no `lib/ui.sh`, `lib/table.awk`, themes or `test/bin/gum`.
- No `screens/`: no VHS recording of each feature, no on-screen caption of the keys each recording presses, and no recordings in the README.
- The README sections are not the family's order of Quick start, Usage, topic sections, Portability, Development and License.
- Coverage is kcov with a 95 percent floor on Linux, not bashcov at 100 percent merged from macOS and Linux.
- CI tests GNU, BSD and uutils tools in `tests.yml`, but not the six toolsets through `.github/scripts/toolset.sh`, and no shell matrix under `sh`, `dash`, `bash` and `zsh`.
- No golden transcripts, `call.sh`, `run-matrix.sh` or `linux-container.sh`.
- The version is written by hand and released by `tests.yml`; there is no semantic-release, `package.json`, `release.yml` with `recover`, `bot-merge.yml` or Renovate.
- CI is `tests.yml` and `security.yml`, not `ci.yml`, and no job starts with `step-security/harden-runner`.
- No `.editorconfig`, `.yamllint.yml` or shfmt; the Makefile has `help`, `test`, `test-unit`, `coverage`, `lint` and `clean`, not the family's targets.
