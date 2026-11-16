# shellcheck shell=bash
# shellcheck disable=SC2207

_fzf_revamped() {
  local cur prev
  cur="${COMP_WORDS[COMP_CWORD]}"
  prev="${COMP_WORDS[COMP_CWORD - 1]}"

  case "${prev}" in
  --theme)
    COMPREPLY=($(compgen -W "kodougu catppuccin-mocha catppuccin-latte dracula nord gruvbox tokyo-night mono" -- "${cur}"))
    return
    ;;
  --popup-border)
    COMPREPLY=($(compgen -W "rounded single double heavy simple padded none" -- "${cur}"))
    return
    ;;
  --preview)
    COMPREPLY=($(compgen -W "on off" -- "${cur}"))
    return
    ;;
  --mru)
    COMPREPLY=($(compgen -W "on off" -- "${cur}"))
    return
    ;;
  session | window | pane)
    COMPREPLY=($(compgen -W "switch kill" -- "${cur}"))
    return
    ;;
  urls)
    COMPREPLY=($(compgen -W "open copy" -- "${cur}"))
    return
    ;;
  move-window)
    COMPREPLY=($(compgen -W "move link" -- "${cur}"))
    return
    ;;
  rename)
    COMPREPLY=($(compgen -W "session window" -- "${cur}"))
    return
    ;;
  multi-kill)
    COMPREPLY=($(compgen -W "session window pane" -- "${cur}"))
    return
    ;;
  --palette-key | --session-key | --window-key | --pane-key | --kill-key | --tree-key | --create-key | --url-key | --cheatsheet-key | --process-key | --rename-key | --multikill-key | --broadcast-key | --zoxide-key | --last-key | --move-key | --popup-width | --popup-height)
    return
    ;;
  *) ;;
  esac

  COMPREPLY=($(compgen -W "apply list session window pane tree create urls palette cheatsheet process rename multi-kill broadcast zoxide last move-window preview doctor version help --json --theme --palette-key --session-key --window-key --pane-key --kill-key --tree-key --create-key --url-key --cheatsheet-key --process-key --rename-key --multikill-key --broadcast-key --zoxide-key --last-key --move-key --popup-width --popup-height --popup-border --preview --mru" -- "${cur}"))
}

complete -F _fzf_revamped fzf-revamped
