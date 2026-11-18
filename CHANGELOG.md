# Changelog

# [2.2.0](https://github.com/tmux-revamped/tmux-fzf-revamped/compare/v2.1.0...v2.2.0) (2026-11-18)


### Bug Fixes

* stop counting some characters twice ([115d1a4](https://github.com/tmux-revamped/tmux-fzf-revamped/commit/115d1a48e634599e84e7d279a85860345fa9ac04))


### Features

* add arrange, buffers and projects pickers ([9e8ff6e](https://github.com/tmux-revamped/tmux-fzf-revamped/commit/9e8ff6e1498804cf96d44d5d617174effffed946))

# [2.1.0](https://github.com/tmux-revamped/tmux-fzf-revamped/compare/v2.0.0...v2.1.0) (2026-11-17)


### Features

* run a binding from the cheatsheet ([cc4d755](https://github.com/tmux-revamped/tmux-fzf-revamped/commit/cc4d755a1b290e0886367dba9e0c56ab5f1c54e4))

# [2.0.0](https://github.com/tmux-revamped/tmux-fzf-revamped/compare/v1.2.0...v2.0.0) (2026-11-17)


* feat!: one default key per plugin, allocated family wide ([3680a76](https://github.com/tmux-revamped/tmux-fzf-revamped/commit/3680a7623f87dd8fffdd62211bd1f25528060aff))


### Bug Fixes

* broadcast typed text with send-keys -l ([bd4bd4f](https://github.com/tmux-revamped/tmux-fzf-revamped/commit/bd4bd4f992239092a5f38660aca2a5b506b22619))
* carry settings, quote popups and folders ([3e33fcb](https://github.com/tmux-revamped/tmux-fzf-revamped/commit/3e33fcb12c4254edfa1350ecff7f08de54b55dea))
* **ci:** read the first released version, not Unreleased ([6875569](https://github.com/tmux-revamped/tmux-fzf-revamped/commit/68755695c15049458bb2bcc9feb513d8e791bd97))
* **family:** fail when git cannot read a mode ([b12799e](https://github.com/tmux-revamped/tmux-fzf-revamped/commit/b12799e7b9114725184cd25063e231af419cf118))
* **family:** honor only active exceptions ([ca9547e](https://github.com/tmux-revamped/tmux-fzf-revamped/commit/ca9547e920534a6bbe106f2f61e6fdc46b4d470e))
* **family:** keep a member exception on propagate ([4cdb8b5](https://github.com/tmux-revamped/tmux-fzf-revamped/commit/4cdb8b52736630ae0680bb7e7e02a81561477069))
* **family:** read html taglines in gen-readme ([bb2f820](https://github.com/tmux-revamped/tmux-fzf-revamped/commit/bb2f820aa755ee30812730b7f60541b7928b1207))
* **family:** reject unquoted replacements ([a7b8798](https://github.com/tmux-revamped/tmux-fzf-revamped/commit/a7b879835f2b026f84fbd19335eac5cd3d66c468))
* **family:** require executable entry points ([fe3d715](https://github.com/tmux-revamped/tmux-fzf-revamped/commit/fe3d715f18b420d02a48439aeb177de17f619612))
* keep typed prompt text literal ([be4ecba](https://github.com/tmux-revamped/tmux-fzf-revamped/commit/be4ecbae6088795f451bb630efefcd30ed9888b8))
* quote plugin path in command strings ([3792566](https://github.com/tmux-revamped/tmux-fzf-revamped/commit/3792566457a2bdfddc0e45b45278e70e57204212))
* quote the coverage path and share one Makefile ([723c9f1](https://github.com/tmux-revamped/tmux-fzf-revamped/commit/723c9f11eb9034cddb277bcdd296eabc1e466eab))
* skip binding actions with an empty key ([d6adb5e](https://github.com/tmux-revamped/tmux-fzf-revamped/commit/d6adb5e5650b3f3e71692d65ee4f8d8220c198c0))


### Features

* add a shared desktop notifier ([714be8c](https://github.com/tmux-revamped/tmux-fzf-revamped/commit/714be8c71d1c4007286fcf2066df07c4c725e0d3))
* **family:** accept bot updates in the audit ([8e456fb](https://github.com/tmux-revamped/tmux-fzf-revamped/commit/8e456fb436373a0a2a35cc2ae32c90b560fdc207))
* **family:** adopt the family contract ([1c9c6cc](https://github.com/tmux-revamped/tmux-fzf-revamped/commit/1c9c6cc6f7b4bf9708e8b29af978b22587ed2a84))
* **family:** measure key clashes against a live server ([ea05b51](https://github.com/tmux-revamped/tmux-fzf-revamped/commit/ea05b51d49169ef796e98ff916f21579ea56369d))
* **family:** one shared core and one pipeline ([6b375a2](https://github.com/tmux-revamped/tmux-fzf-revamped/commit/6b375a20608e03ad9680691cbb3509687da9533d))
* rewrite the plugin in POSIX sh ([7f3c074](https://github.com/tmux-revamped/tmux-fzf-revamped/commit/7f3c074ab4c9ae97270722fe4a65052d4e07b98a))


### BREAKING CHANGES

* every default key moved. family/docs/migration.md maps the old
keys to the new ones and shows how to restore any of them.

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Fixed

- Key bindings, the popup fallback, and the preview pane quote the plugin path,
  so an install path containing a space or a quote runs the picker.
- Actions whose key option is empty, the default for every action except the
  palette, are no longer passed to `bind-key` with an empty key. A key option
  set to `off` also leaves its action unbound.
- Text typed into the broadcast, rename, and move-window prompts reaches tmux
  through the quoting `%%%` placeholder, so quotes, `$`, and `;` stay literal
  instead of ending the command or running in a shell.
- Broadcast types the text with `send-keys -l`, so a command such as `Enter` or
  `C-c` arrives as those characters rather than as a key press.

## [1.2.0] - 2026-06-30

### Added

- Tree picker that spans sessions, windows, and panes in one view.
- Create-on-miss: type a name that matches nothing and the picker creates and
  attaches that session.
- URL picker that pulls links from the current pane and opens them in the
  browser or copies them to the tmux buffer.
- Command palette of common tmux commands, run on select.
- Keybinding cheatsheet picker over `list-keys`.
- Process picker that sends a signal to a chosen process, behind a confirm.
- Window and session rename through a tmux prompt.
- Multi-select kill that removes several marked objects after a confirm.
- Broadcast a command to several marked panes at once.
- zoxide directory picker that opens or attaches a session at a project dir.
- Last-session toggle and an opt-in most-recently-attached order for the
  session picker.
- Move or link a window into another session.
- Opt-in live pane preview in the switch pickers via `@fzf_revamped_preview`.

## [1.1.0] - 2026-06-23

### Added

- `@fzf_revamped_popup_border` sets the popup border style on tmux 3.4 and newer
  (upstream tmux-fzf #96, PR #97).

### Changed

- The picker bindings now check for `display-popup` support. On tmux older than
  3.2, where popups do not exist, the pickers open in a new window instead, and
  the border flag is withheld so no unknown option reaches an old tmux
  (upstream tmux-fzf #49). The cross-session session, window, and pane palette
  was already unified, ahead of upstream PR #101.

## [1.0.0] - 2026-06-22

### Added

- Fuzzy-search and jump to any session, window, or pane from an fzf popup.
- Kill pickers for sessions, windows, and panes, reusing the same lists.
- The target id rides as a hidden column, so names with spaces or slashes
  always resolve to the right object.
- Configurable keys and popup size.
