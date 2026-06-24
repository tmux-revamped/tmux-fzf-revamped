# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
