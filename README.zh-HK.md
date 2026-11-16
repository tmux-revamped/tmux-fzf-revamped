<div align="center">

# tmux-fzf-revamped

<strong>在彈出視窗的 fzf 選擇器中切換、關閉、重新命名或建立 tmux 工作階段、視窗和窗格。</strong>

[English](README.md) &nbsp;|&nbsp; [日本語](README.ja.md) &nbsp;|&nbsp; [简体中文](README.zh-Hans.md) &nbsp;|&nbsp; 繁體中文（香港）

[![ci](https://img.shields.io/github/actions/workflow/status/tmux-revamped/tmux-fzf-revamped/ci.yml?branch=main&style=flat-square&label=ci)](https://github.com/tmux-revamped/tmux-fzf-revamped/actions/workflows/ci.yml)
[![release](https://img.shields.io/github/v/release/tmux-revamped/tmux-fzf-revamped?style=flat-square&label=release)](https://github.com/tmux-revamped/tmux-fzf-revamped/releases/latest)
[![openssf scorecard](https://img.shields.io/ossf-scorecard/github.com/tmux-revamped/tmux-fzf-revamped?style=flat-square&label=openssf%20scorecard)](https://scorecard.dev/viewer/?uri=github.com/tmux-revamped/tmux-fzf-revamped)
[![license](https://img.shields.io/github/license/tmux-revamped/tmux-fzf-revamped?style=flat-square&label=license)](LICENSE)

<p align="center">
  <a href="#快速開始"><strong>快速開始</strong></a> &nbsp;|&nbsp;
  <a href="#用法">用法</a> &nbsp;|&nbsp;
  <a href="#選擇器">選擇器</a> &nbsp;|&nbsp;
  <a href="#畫面">畫面</a>
</p>

</div>

<p align="center">
  <img src="screens/hero.gif" alt="fzf-revamped 執行命令面板中的命令，在選擇器中切換工作階段，再回到上一個工作階段" width="800">
</p>

```console
$ FZF_REVAMPED_SESSION_KEY=S FZF_REVAMPED_LAST_KEY=L fzf-revamped list
bind-key S display-popup -E -b rounded -w 60% -h 50% '/home/user/.tmux/plugins/tmux-fzf-revamped/bin/fzf-revamped' session switch
bind-key M-f display-popup -E -b rounded -w 60% -h 50% '/home/user/.tmux/plugins/tmux-fzf-revamped/bin/fzf-revamped' palette
bind-key L run-shell '/home/user/.tmux/plugins/tmux-fzf-revamped/bin/fzf-revamped' last
```

按下 `prefix M-f` 開啟常用 tmux 命令的面板。其他選擇器，由工作階段切換到廣播提示，都等待你自行選擇的按鍵，所以安裝整個系列亦不會產生按鍵衝突。

---

## 快速開始

### 前提條件

| 工具 | 版本 | 用途 |
|:-----|:--------|:---------|
| tmux | 彈出視窗需要 3.2 或以上 | 3.2 之前每個選擇器在視窗中開啟；邊框需要 3.4 |
| fzf | 任何版本 | 所有選擇器；缺少時 `doctor` 會報告 |
| 開啟工具 | 可選 | 用於 URL 選擇器：macOS 上的 `open`，Linux 上的 `xdg-open` |
| zoxide | 可選 | zoxide 選擇器 |
| gum | 可選 | `fzf-revamped` 的選單、表格和顏色；沒有它，所有命令都輸出純文字 |

### 安裝

```tmux
set -g @plugin 'tmux-revamped/tmux-fzf-revamped'
```

然後按 `prefix + I`。不使用 TPM 時，複製儲存庫，並在 `~/.tmux.conf` 中執行它的入口腳本：

```bash
git clone https://github.com/tmux-revamped/tmux-fzf-revamped ~/.tmux/plugins/tmux-fzf-revamped
```

```tmux
run-shell ~/.tmux/plugins/tmux-fzf-revamped/fzf-revamped.tmux
```

在複製的目錄中執行 `make install`，亦會把 `fzf-revamped` 放入 `~/.local/bin`，並把它的 man 手冊和自動完成放在 `~/.local/share` 下。

### 驗證

```bash
~/.tmux/plugins/tmux-fzf-revamped/bin/fzf-revamped doctor
```

## 用法

為想用的選擇器綁定按鍵，然後重新載入設定或執行 `fzf-revamped apply`：

```tmux
set -g @fzf_revamped_session_key 'S'
set -g @fzf_revamped_window_key 'W'
set -g @fzf_revamped_last_key 'L'
```

`M-f` 是本插件在系列按鍵分配中的位置。如果你已自行綁定 `prefix M-f`，插件會保留它，並由 `doctor` 說明。設為 `off` 的按鍵不會綁定。即使一個按鍵名稱無效，其他按鍵仍會綁定，`apply` 會連同 tmux 的錯誤以 1 結束。

| 命令 | 作用 |
|:--------|:-------------|
| `fzf-revamped apply` | 立即綁定按鍵；插件載入時入口點會執行它 |
| `fzf-revamped list` | 列出 apply 會做的每個綁定；`--json` 輸出一個物件 |
| 加上選擇器名稱的 `fzf-revamped` | 加上選擇器名稱時，像按鍵一樣執行該選擇器；見選擇器一節 |
| `fzf-revamped doctor` | 每個依賴一行，包括被他人佔用的預設按鍵 |
| `fzf-revamped version` | 版本，然後是 tmux 版本 |
| `fzf-revamped help` | 說明頁；`man fzf-revamped` 記錄相同的命令和設定 |
| `fzf-revamped` | 在終端機上顯示選單 |

| tmux 選項 | 預設值 | 含義 |
|:------------|:--------|:--------|
| `@fzf_revamped_popup_width` | `60%` | 彈出視窗寬度 |
| `@fzf_revamped_popup_height` | `50%` | 彈出視窗高度 |
| `@fzf_revamped_popup_border` | `rounded` | tmux 3.4 或以後的彈出視窗邊框：`rounded`、`single`、`double`、`heavy`、`simple`、`padded` 或 `none` |
| `@fzf_revamped_preview` | `off` | `on` 或 `1` 時在切換選擇器中顯示游標下的窗格 |
| `@fzf_revamped_mru` | `off` | `on` 時按最後連接時間排列工作階段 |

每個選項亦可寫成以短橫線連接的命令選項，例如 `--session-key S`，以及環境變數，例如 `FZF_REVAMPED_SESSION_KEY`；命令列優先於環境變數，環境變數優先於 tmux 選項。空的 tmux 選項表示使用預設值。

<a id="選擇器"></a>

## 選擇器

| 按鍵選項 | 命令 | 作用 |
|:-----------|:--------|:-------------|
| `@fzf_revamped_palette_key`，`M-f` | `palette` | 由簡短列表執行 tmux 命令 |
| `@fzf_revamped_session_key` | `session switch` | 切換到選取的工作階段 |
| `@fzf_revamped_window_key` | `window switch` | 切換到選取的視窗及其工作階段 |
| `@fzf_revamped_pane_key` | `pane switch` | 切換到選取的窗格 |
| `@fzf_revamped_kill_key` | `session kill` | 關閉選取的工作階段 |
| `@fzf_revamped_tree_key` | `tree` | 前往任何工作階段、視窗或窗格 |
| `@fzf_revamped_create_key` | `create` | 切換到工作階段，或以輸入的名稱建立一個 |
| `@fzf_revamped_url_key` | `urls open` | 開啟畫面上的 URL；`urls copy` 把它複製到 tmux 緩衝區 |
| `@fzf_revamped_cheatsheet_key` | `cheatsheet` | 瀏覽所有按鍵綁定 |
| `@fzf_revamped_process_key` | `process` | 確認後向選取的程序發送 TERM 或指定的訊號 |
| `@fzf_revamped_rename_key` | `rename window` | 透過提示重新命名選取的視窗；`rename session` 重新命名工作階段 |
| `@fzf_revamped_multikill_key` | `multi-kill session` | 確認後關閉以 `Tab` 標記的所有工作階段 |
| `@fzf_revamped_broadcast_key` | `broadcast` | 提示輸入文字，然後把它和 `Enter` 輸入到所有標記的窗格 |
| `@fzf_revamped_zoxide_key` | `zoxide` | 在 zoxide 資料夾開啟工作階段 |
| `@fzf_revamped_last_key` | `last` | 不用彈出視窗，切換到上一個工作階段 |
| `@fzf_revamped_move_key` | `move-window move` | 把選取的視窗移到提示中輸入的工作階段；`move-window link` 則連結它 |

`window kill`、`pane kill`、`multi-kill window` 和 `multi-kill pane` 沒有按鍵，由命令列執行。列表的每一行都把目標放在隱藏的第一欄，所以名為 `feature/login` 的視窗或含空格的工作階段亦能正確定位。

<a id="畫面"></a>

## 畫面

<details>
<summary>所有畫面，在真實的 tmux 中用 <code>make screens</code> 錄製，每個按鍵顯示在狀態列上</summary>
<br>

<table>
<tr>
<td width="50%" valign="top"><img src="screens/palette.png" alt="fzf-revamped：prefix M-f 開啟命令面板"><br><sub><code>prefix M-f</code> 開啟命令面板，來自 <code>hero.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/palette-split.png" alt="fzf-revamped：執行面板中的 split-window -h"><br><sub>執行面板中的 <code>split-window -h</code>，來自 <code>hero.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/sessions.png" alt="fzf-revamped：附預覽的工作階段切換"><br><sub>附預覽的工作階段切換，來自 <code>hero.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/switched.png" alt="fzf-revamped：用戶端切換到選取的工作階段"><br><sub>用戶端切換到選取的工作階段，來自 <code>hero.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/last.png" alt="fzf-revamped：last 鍵回到上一個工作階段"><br><sub>last 鍵回到上一個工作階段，來自 <code>hero.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/windows.png" alt="fzf-revamped：視窗切換"><br><sub>視窗切換，來自 <code>stills.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/panes.png" alt="fzf-revamped：窗格切換"><br><sub>窗格切換，來自 <code>stills.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/tree.png" alt="fzf-revamped：工作階段、視窗和窗格的樹"><br><sub>工作階段、視窗和窗格的樹，來自 <code>stills.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/create.png" alt="fzf-revamped：輸入新名稱的建立或切換"><br><sub>輸入新名稱的建立或切換，來自 <code>stills.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/created.png" alt="fzf-revamped：新工作階段"><br><sub>新工作階段，來自 <code>stills.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/urls.png" alt="fzf-revamped：畫面上的 URL"><br><sub>畫面上的 URL，來自 <code>stills.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/cheatsheet.png" alt="fzf-revamped：篩選到一個命令的速查表"><br><sub>篩選到一個命令的速查表，來自 <code>stills.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/process.png" alt="fzf-revamped：程序選擇器"><br><sub>程序選擇器，來自 <code>stills.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/process-confirm.png" alt="fzf-revamped：發送訊號前的確認"><br><sub>發送訊號前的確認，來自 <code>stills.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/rename.png" alt="fzf-revamped：重新命名提示"><br><sub>重新命名提示，來自 <code>stills.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/kill.png" alt="fzf-revamped：工作階段關閉"><br><sub>工作階段關閉，來自 <code>stills.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/multikill.png" alt="fzf-revamped：多選關閉中標記的兩個工作階段"><br><sub>多選關閉中標記的兩個工作階段，來自 <code>stills.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/broadcast.png" alt="fzf-revamped：廣播中標記的兩個窗格"><br><sub>廣播中標記的兩個窗格，來自 <code>stills.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/zoxide.png" alt="fzf-revamped：zoxide 資料夾"><br><sub>zoxide 資料夾，來自 <code>stills.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/move.png" alt="fzf-revamped：視窗移動提示"><br><sub>視窗移動提示，來自 <code>stills.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/menu.png" alt="fzf-revamped：選單"><br><sub>選單，來自 <code>stills.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/doctor.png" alt="fzf-revamped：doctor"><br><sub><code>doctor</code>，來自 <code>stills.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/list.png" alt="fzf-revamped：list"><br><sub><code>list</code>，來自 <code>stills.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/json.png" alt="fzf-revamped：list --json"><br><sub><code>list --json</code>，來自 <code>stills.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/plain-menu.png" alt="fzf-revamped：沒有 gum 的選單"><br><sub>沒有 gum 的選單，來自 <code>stills.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/plain-apply.png" alt="fzf-revamped：從選單執行 apply"><br><sub>從選單執行 <code>apply</code>，來自 <code>stills.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/version.png" alt="fzf-revamped：版本"><br><sub>版本，來自 <code>stills.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/error.png" alt="fzf-revamped：不明命令"><br><sub>不明命令，來自 <code>stills.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/themes.png" alt="fzf-revamped：六種主題下的標題"><br><sub>六種主題下的標題，來自 <code>themes.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/help.png" alt="fzf-revamped：說明頁"><br><sub>說明頁，來自 <code>help.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/accent.png" alt="fzf-revamped：來自 FZF_REVAMPED_ACCENT 的強調色"><br><sub>來自 <code>FZF_REVAMPED_ACCENT</code> 的強調色，來自 <code>stills.tape</code></sub></td>
<td width="50%" valign="top"></td>
</tr>
</table>

</details>

## 可攜性

插件是 POSIX `sh`。CI 在下列每一行上執行全部測試。

| Shell | 狀態 |
|:------|:-------|
| `dash`、macOS 上的 `/bin/sh` | 支援 |
| `bash` 3.2 和 5.x、系統內建的 `zsh` 和 Homebrew 的 `zsh` | 支援 |

| 系統 | 狀態 |
|:-------|:-------|
| macOS | Apple Silicon 和 Intel 上的 Tahoe，使用內建的工具、Homebrew 的 GNU 工具和 Homebrew 的 uutils |
| Linux | x86_64 和 arm64 上的 Ubuntu 26.04，使用 GNU coreutils、uutils 和 BusyBox |

## 開發

| 指令 | 執行內容 |
|:--------|:-------------|
| `make fmt` | 對每個腳本執行 shfmt `-i 2` |
| `make lint` | shfmt、ShellCheck、mandoc、yamllint 和 actionlint，零警告 |
| `make test` | 在系統 `sh` 下執行 bats 測試 |
| `make test-all` | 在每個已安裝的 shell 下執行測試，macOS 上包括 bash 和 zsh 的兩種版本 |
| `make test-linux` | 在 Ubuntu 容器中執行測試 |
| `make coverage` | 在這部 Mac 和 Ubuntu 容器中執行 bashcov，合併後以 100% 為門檻 |
| `make screens` | 以 VHS 在 tmux 中從真實插件錄製上述畫面，在 macOS 上執行 |
| `make install` | 把指令、man 手冊和自動完成安裝到 `PREFIX` 下 |

提交遵循 Conventional Commits 格式，直接進入 `main`。`main` 上的 `ci` 通過後，`release.yml` 會執行 semantic-release：自上一個標籤以來的每個 `feat` 或 `fix` 都會發佈新版本，更新版本常數，並把說明寫入 [`CHANGELOG.md`](CHANGELOG.md)。

## 授權

[MIT](LICENSE)，copyright Gustavo Franco。

<!-- family:begin -->

## tmux-revamped 插件家族

這個插件是 tmux-revamped 插件家族的一員。每個成員都帶有 [`FAMILY.md`](FAMILY.md) 中相同的約定和相同的共用程式庫，並且設計為一起安裝：沒有成員佔用另一個成員佔用的按鍵或 tmux 選項。

在一個成員中發現的缺陷，要在全部成員中排查後才算修正完成。

| 成員 | 功能 |
|---|---|
| [`tmux-autoreload-revamped`](https://github.com/tmux-revamped/tmux-autoreload-revamped) | 編輯並儲存 tmux 設定後，它會自動重新載入，毋須按鍵，也毋須指令 |
| [`tmux-battery-revamped`](https://github.com/tmux-revamped/tmux-battery-revamped) | 在 tmux 狀態列顯示電池狀態，從不阻塞狀態列繪製 |
| [`tmux-bluetooth-revamped`](https://github.com/tmux-revamped/tmux-bluetooth-revamped) | 在 tmux 狀態列顯示每部已連接的藍牙裝置及其電量，不阻塞繪製 |
| [`tmux-cpu-revamped`](https://github.com/tmux-revamped/tmux-cpu-revamped) | 在 tmux 狀態列顯示 CPU 負載、溫度及頻率，從不阻塞繪製 |
| [`tmux-disk-revamped`](https://github.com/tmux-revamped/tmux-disk-revamped) | 在 tmux 狀態列顯示磁碟用量，從不阻塞狀態列繪製 |
| [`tmux-extract-revamped`](https://github.com/tmux-revamped/tmux-extract-revamped) | 用 fzf 從畫面上揀選 URL、路徑、雜湊值或任何其他字詞，並輸入到游標位置，全部以純 shell 實現 |
| [`tmux-fzf-revamped`](https://github.com/tmux-revamped/tmux-fzf-revamped) | **本插件**，在彈出視窗的 fzf 選擇器中切換、關閉、重新命名或建立 tmux 工作階段、視窗和窗格 |
| [`tmux-git-revamped`](https://github.com/tmux-revamped/tmux-git-revamped) | 在 tmux 狀態列顯示當前窗格的 git 分支、改動和託管平台數目，而不會阻塞顯示 |
| [`tmux-gpu-revamped`](https://github.com/tmux-revamped/tmux-gpu-revamped) | 在 tmux 狀態列顯示 NVIDIA、AMD、Intel 及 Apple GPU 的負載、溫度、時脈、功耗及記憶體 |
| [`tmux-kube-revamped`](https://github.com/tmux-revamped/tmux-kube-revamped) | 在 tmux 狀態列顯示目前的 Kubernetes 上下文及命名空間，毋須 kubectl，直接解析 kubeconfig |
| [`tmux-launcher-revamped`](https://github.com/tmux-revamped/tmux-launcher-revamped) | 在彈出視窗或新視窗中啟動任何 TUI 應用程式，從目前窗格的目錄開始，每個應用程式可設定一個按鍵 |
| [`tmux-logging-revamped`](https://github.com/tmux-revamped/tmux-logging-revamped) | 將任何窗格儲存到檔案：即時記錄、完整捲動緩衝區或一次性截圖 |
| [`tmux-music-revamped`](https://github.com/tmux-revamped/tmux-music-revamped) | 在 tmux 狀態列顯示正在播放的歌曲，從不阻塞狀態列的繪製 |
| [`tmux-network-revamped`](https://github.com/tmux-revamped/tmux-network-revamped) | 在 tmux 狀態列顯示網絡傳輸量，從不阻塞繪製 |
| [`tmux-pain-control-revamped`](https://github.com/tmux-revamped/tmux-pain-control-revamped) | tmux 的窗格和視窗管理按鍵，配合 tmux 版本，與 vim 相容，每個 prefix 按鍵都可停用 |
| [`tmux-persist-revamped`](https://github.com/tmux-revamped/tmux-persist-revamped) | 儲存 tmux 的所有工作階段、視窗及窗格，按計時器自動儲存，並在重新開機後全部還原 |
| [`tmux-plugin-template`](https://github.com/tmux-revamped/tmux-plugin-template) | tmux-revamped 插件的起點：共用程式庫、bats 測試框架和 CI |
| [`tmux-pomodoro-revamped`](https://github.com/tmux-revamped/tmux-pomodoro-revamped) | tmux 狀態列中的番茄鐘計時器，所有狀態都儲存在 tmux 選項中，不使用暫存檔 |
| [`tmux-ram-revamped`](https://github.com/tmux-revamped/tmux-ram-revamped) | 在 tmux 狀態列顯示記憶體、交換空間及記憶體壓力，在背景取樣，繪製從不等待 |
| [`tmux-reorder-revamped`](https://github.com/tmux-revamped/tmux-reorder-revamped) | 用滑鼠在 tmux 狀態列上拖動視窗標籤來移動該視窗 |
| [`tmux-scroll-revamped`](https://github.com/tmux-revamped/tmux-scroll-revamped) | 將滑鼠滾輪交給能自行捲動的應用程式，其他情況下進入 tmux 複製模式 |
| [`tmux-sensible-revamped`](https://github.com/tmux-revamped/tmux-sensible-revamped) | 按 tmux 版本和終端機區分的合理預設設定，不會改動你自己設定的選項 |
| [`tmux-tiling-revamped`](https://github.com/tmux-revamped/tmux-tiling-revamped) | tmux 的平鋪視窗管理：八種版面，包括 BSP dwindle 和 spiral，並支援復原版面 |
| [`tmux-time-revamped`](https://github.com/tmux-revamped/tmux-time-revamped) | 狀態列中的本地時鐘和世界時鐘，按一天中的時段著色，並提供倒數和夏令時間提示 |
| [`tmux-weather-revamped`](https://github.com/tmux-revamped/tmux-weather-revamped) | 在背景從 wttr.in 取得天氣並顯示在狀態列，狀態列毋須等待 |

<!-- family:end -->
