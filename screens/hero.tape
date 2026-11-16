Source common.tape
Output hero.gif
Hide
Type "tmux -L revamped-screens attach -t demo"
Enter
Sleep 2s
Type "tmux rename-window shell; tmux new-window -d -n logs; tmux new-session -d -s api -n server; tmux new-session -d -s web -n client; tmux new-window -d -t web -n tests; clear; echo docs at https://example.com/fzf-revamped"
Enter
Sleep 1500ms
Show
Sleep 800ms
Hide
Ctrl+]
Type@5ms "prefix M-f, split -h, Enter"
Enter
Show
Ctrl+B
Escape
Type@1ms "f"
Sleep 2s
Screenshot palette.png
Sleep 800ms
Type "split -h"
Sleep 800ms
Enter
Sleep 1500ms
Screenshot palette-split.png
Sleep 800ms
Hide
Ctrl+]
Type@5ms "prefix S, web, Enter"
Enter
Show
Ctrl+B
Type@1ms "S"
Sleep 2s
Type "web"
Sleep 800ms
Screenshot sessions.png
Sleep 800ms
Enter
Sleep 1500ms
Screenshot switched.png
Sleep 800ms
Hide
Ctrl+]
Type@5ms "prefix L"
Enter
Show
Ctrl+B
Type@1ms "L"
Sleep 1500ms
Screenshot last.png
Sleep 800ms
