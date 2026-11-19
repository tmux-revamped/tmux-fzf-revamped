#!/bin/sh
# shellcheck disable=SC2034

[ -n "${FZF_REVAMPED_STATE_LOADED:-}" ] && return 0
FZF_REVAMPED_STATE_LOADED=1

FZF_REVAMPED_SETTINGS='palette_key	M-f
session_key
window_key
pane_key
kill_key
tree_key
create_key
url_key
cheatsheet_key
process_key
rename_key
multikill_key
broadcast_key
zoxide_key
last_key
move_key
arrange_key
buffer_key
projects_key
popup_width	60%
popup_height	50%
popup_border	rounded
preview
mru
projects	'
FZF_REVAMPED_PICK_NAMES='preview mru projects'
FZF_REVAMPED_NAMES='palette_key session_key window_key pane_key kill_key tree_key create_key url_key cheatsheet_key process_key rename_key multikill_key broadcast_key zoxide_key last_key move_key arrange_key buffer_key projects_key popup_width popup_height popup_border preview mru projects'
FZF_REVAMPED_S_palette_key='M-f'
FZF_REVAMPED_S_session_key=''
FZF_REVAMPED_S_window_key=''
FZF_REVAMPED_S_pane_key=''
FZF_REVAMPED_S_kill_key=''
FZF_REVAMPED_S_tree_key=''
FZF_REVAMPED_S_create_key=''
FZF_REVAMPED_S_url_key=''
FZF_REVAMPED_S_cheatsheet_key=''
FZF_REVAMPED_S_process_key=''
FZF_REVAMPED_S_rename_key=''
FZF_REVAMPED_S_multikill_key=''
FZF_REVAMPED_S_broadcast_key=''
FZF_REVAMPED_S_zoxide_key=''
FZF_REVAMPED_S_last_key=''
FZF_REVAMPED_S_move_key=''
FZF_REVAMPED_S_arrange_key=''
FZF_REVAMPED_S_buffer_key=''
FZF_REVAMPED_S_projects_key=''
FZF_REVAMPED_S_popup_width='60%'
FZF_REVAMPED_S_popup_height='50%'
FZF_REVAMPED_S_popup_border='rounded'
FZF_REVAMPED_S_preview=''
FZF_REVAMPED_S_mru=''
FZF_REVAMPED_S_projects=''
FZF_REVAMPED_BROADCAST=@fzf_revamped_broadcast_text
FZF_REVAMPED_MIRRORED_SINCE=3.5
FZF_REVAMPED_RESIZE_STEPS='5 10 20'
FZF_REVAMPED_TAB='	'
FZF_REVAMPED_PLAN=""
FZF_REVAMPED_TMUX=""
FZF_REVAMPED_TOOL=""
FZF_REVAMPED_CARRIED=""
FZF_REVAMPED_TAKEN=""
FZF_REVAMPED_BORDER=""
REVAMPED_LOG_NS=fzf-revamped
FZF_REVAMPED_KINDS='preview	on 1 off 0
mru	on off'
