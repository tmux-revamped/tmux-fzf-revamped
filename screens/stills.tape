Source common.tape
Output scratch.gif
Hide
Type "tmux -L revamped-screens attach -t demo"
Enter
Sleep 2s
Type "tmux rename-window shell; tmux new-window -d -n logs; tmux new-session -d -s api -n server; tmux new-session -d -s web -n client; tmux new-window -d -t web -n tests; clear; echo docs at https://example.com/fzf-revamped"
Enter
Sleep 1500ms
Show
Sleep 500ms
Hide
Ctrl+]
Type@5ms "prefix W, tests, Enter"
Enter
Show
Ctrl+B
Type@1ms "W"
Sleep 2s
Type "tests"
Sleep 800ms
Screenshot windows.png
Sleep 800ms
Enter
Sleep 1500ms
Hide
Ctrl+]
Type@5ms "prefix L"
Enter
Show
Ctrl+B
Type@1ms "L"
Sleep 1500ms
Hide
Type "tmux split-window -d"
Enter
Sleep 800ms
Show
Hide
Ctrl+]
Type@5ms "prefix E, Escape"
Enter
Show
Ctrl+B
Type@1ms "E"
Sleep 2s
Screenshot panes.png
Sleep 800ms
Escape
Sleep 1500ms
Hide
Ctrl+]
Type@5ms "prefix T, Escape"
Enter
Show
Ctrl+B
Type@1ms "T"
Sleep 2s
Screenshot tree.png
Sleep 800ms
Escape
Sleep 1500ms
Hide
Ctrl+]
Type@5ms "prefix C, scratch, Enter"
Enter
Show
Ctrl+B
Type@1ms "C"
Sleep 2s
Type "scratch"
Sleep 800ms
Screenshot create.png
Sleep 800ms
Enter
Sleep 1500ms
Screenshot created.png
Sleep 800ms
Hide
Ctrl+]
Type@5ms "prefix L"
Enter
Show
Ctrl+B
Type@1ms "L"
Sleep 1500ms
Hide
Ctrl+]
Type@5ms "prefix U, Escape"
Enter
Show
Ctrl+B
Type@1ms "U"
Sleep 2s
Screenshot urls.png
Sleep 800ms
Escape
Sleep 1500ms
Hide
Ctrl+]
Type@5ms "prefix ?, 'select-window, Escape"
Enter
Show
Ctrl+B
Type@1ms "?"
Sleep 2s
Type "'select-window"
Sleep 800ms
Screenshot cheatsheet.png
Sleep 800ms
Escape
Sleep 1500ms
Hide
Type "sleep 600 &"
Enter
Type "clear"
Enter
Show
Hide
Ctrl+]
Type@5ms "prefix P, sleep, Enter, Escape"
Enter
Show
Ctrl+B
Type@1ms "P"
Sleep 2s
Type "sleep"
Sleep 800ms
Screenshot process.png
Sleep 800ms
Enter
Sleep 1500ms
Screenshot process-confirm.png
Sleep 800ms
Escape
Sleep 1500ms
Hide
Ctrl+]
Type@5ms "prefix R, logs, Enter, build, Enter"
Enter
Show
Ctrl+B
Type@1ms "R"
Sleep 2s
Type "logs"
Sleep 800ms
Enter
Sleep 1500ms
Type "build"
Sleep 800ms
Screenshot rename.png
Sleep 800ms
Enter
Sleep 1500ms
Hide
Ctrl+]
Type@5ms "prefix K, api, Escape"
Enter
Show
Ctrl+B
Type@1ms "K"
Sleep 2s
Type "api"
Sleep 800ms
Screenshot kill.png
Sleep 800ms
Escape
Sleep 1500ms
Hide
Ctrl+]
Type@5ms "prefix X, Tab, Tab, Escape"
Enter
Show
Ctrl+B
Type@1ms "X"
Sleep 2s
Tab
Sleep 400ms
Tab
Sleep 400ms
Screenshot multikill.png
Sleep 800ms
Escape
Sleep 1500ms
Hide
Ctrl+]
Type@5ms "prefix B, echo hello, Enter, Tab, Tab, Escape"
Enter
Show
Ctrl+B
Type@1ms "B"
Sleep 1s
Type "echo hello"
Sleep 500ms
Enter
Sleep 2s
Tab
Sleep 400ms
Tab
Sleep 800ms
Screenshot broadcast.png
Sleep 800ms
Escape
Sleep 2s
Hide
Ctrl+]
Type@5ms "prefix Z, Escape"
Enter
Show
Ctrl+B
Type@1ms "Z"
Sleep 2s
Screenshot zoxide.png
Sleep 800ms
Escape
Sleep 1500ms
Hide
Ctrl+]
Type@5ms "prefix M, build, Enter, Enter"
Enter
Show
Ctrl+B
Type@1ms "M"
Sleep 2s
Type "build"
Sleep 800ms
Enter
Sleep 1500ms
Screenshot move.png
Sleep 800ms
Enter
Sleep 1500ms
Hide
Type "tmux kill-pane -a; clear"
Enter
Show
Hide
Ctrl+]
Type@5ms "fzf-revamped list, Enter"
Enter
Show
Type "fzf-revamped list"
Sleep 400ms
Enter
Sleep 2s
Screenshot list.png
Sleep 800ms
Hide
Type "clear"
Enter
Show
Hide
Ctrl+]
Type@5ms "fzf-revamped list --json, Enter"
Enter
Show
Type "fzf-revamped list --json"
Sleep 400ms
Enter
Sleep 2s
Screenshot json.png
Sleep 800ms
Hide
Type "clear"
Enter
Show
Hide
Ctrl+]
Type@5ms "fzf-revamped version, Enter"
Enter
Show
Type "fzf-revamped version"
Sleep 400ms
Enter
Sleep 2s
Screenshot version.png
Sleep 800ms
Hide
Type "clear"
Enter
Show
Hide
Ctrl+]
Type@5ms "fzf-revamped frobnicate, Enter"
Enter
Show
Type "fzf-revamped frobnicate"
Sleep 400ms
Enter
Sleep 2s
Screenshot error.png
Sleep 800ms
Hide
Type "clear"
Enter
Show
Hide
Ctrl+]
Type@5ms "FZF_REVAMPED_ACCENT=#89DCEB fzf-revamped, Enter, Escape"
Enter
Show
Type "FZF_REVAMPED_ACCENT='#89DCEB' fzf-revamped"
Sleep 400ms
Enter
Sleep 3s
Screenshot accent.png
Sleep 800ms
Escape
Sleep 2s
Hide
Type "clear"
Enter
Show
Hide
Ctrl+]
Type@5ms "fzf-revamped, Enter, Escape"
Enter
Show
Type "fzf-revamped"
Sleep 400ms
Enter
Sleep 3s
Screenshot menu.png
Sleep 800ms
Escape
Sleep 2s
Hide
Type "clear"
Enter
Show
Hide
Ctrl+]
Type@5ms "fzf-revamped doctor, Enter"
Enter
Show
Type "fzf-revamped doctor"
Sleep 400ms
Enter
Sleep 5s
Screenshot doctor.png
Sleep 800ms
Hide
Type "clear"
Enter
Show
Hide
Type "export PATH=/usr/bin:/bin:/usr/sbin:/sbin:/Users/Shared/demo/bin:/Users/Shared/demo/tmux-fzf-revamped/bin"
Enter
Type "clear"
Enter
Show
Hide
Ctrl+]
Type@5ms "fzf-revamped, Enter, 2 Enter"
Enter
Show
Type "fzf-revamped"
Sleep 400ms
Enter
Sleep 2s
Screenshot plain-menu.png
Sleep 800ms
Type "2"
Sleep 400ms
Enter
Sleep 3s
Screenshot plain-apply.png
Sleep 800ms
