export PS1='$ '
export PATH="/Users/Shared/demo/bin:/Users/Shared/demo/tmux-fzf-revamped/bin:${PATH}"
export TZ=UTC
unset FZF_DEFAULT_OPTS FZF_DEFAULT_COMMAND XDG_CONFIG_HOME
unset KODOUGU_THEME KODOUGU_ACCENT FZF_REVAMPED_THEME FZF_REVAMPED_ACCENT NO_COLOR
export HOME=/Users/Shared/demo/home
cd /Users/Shared/demo || return 1
printf '\033]2;demo\033\134'
clear
