<div align="center">

# tmux-fzf-revamped

<strong>在彈出視窗的 fzf 選擇器中切換、關閉、重新命名或建立 tmux 工作階段、視窗和窗格。</strong>

[English](README.md) | [日本語](README.ja.md) | [简体中文](README.zh-Hans.md) | 繁體中文（香港）

[![family](https://img.shields.io/github/actions/workflow/status/tmux-revamped/tmux-fzf-revamped/family.yml?branch=main&style=flat-square&label=family)](https://github.com/tmux-revamped/tmux-fzf-revamped/actions/workflows/family.yml)
[![tests](https://img.shields.io/github/actions/workflow/status/tmux-revamped/tmux-fzf-revamped/tests.yml?branch=main&style=flat-square&label=tests)](https://github.com/tmux-revamped/tmux-fzf-revamped/actions/workflows/tests.yml)
[![release](https://img.shields.io/github/v/release/tmux-revamped/tmux-fzf-revamped?style=flat-square&label=release)](https://github.com/tmux-revamped/tmux-fzf-revamped/releases/latest)
[![openssf scorecard](https://img.shields.io/ossf-scorecard/github.com/tmux-revamped/tmux-fzf-revamped?style=flat-square&label=openssf%20scorecard)](https://scorecard.dev/viewer/?uri=github.com/tmux-revamped/tmux-fzf-revamped)
[![license](https://img.shields.io/github/license/tmux-revamped/tmux-fzf-revamped?style=flat-square&label=license)](LICENSE)

<p align="center">
  <a href="#功能">功能</a> |
  <a href="#系統要求">系統要求</a> |
  <a href="#安裝">安裝</a> |
  <a href="#用法">用法</a> |
  <a href="#設定">設定</a> |
  <a href="#按鍵綁定">按鍵綁定</a> |
  <a href="#運作原理">運作原理</a> |
  <a href="#開發">開發</a>
</p>

</div>

共 **16** 個動作，預設綁定 **1** 個，指令面板內有 **10** 條 tmux 指令。

---

## 功能

每個動作都會在 tmux 彈出視窗中開啟一個 fzf 清單。選取一項後，插件便對它執行動作：切換到某個工作階段、視窗或窗格，關閉它，重新命名它，或建立一個尚未存在的工作階段。

| 動作 | 作用 |
|:-------|:-------------|
| palette | 執行 10 條 tmux 指令之一：`new-window`、兩種分割、下一個、上一個及最近的視窗、`kill-pane`、`kill-window`、`detach-client`、`choose-tree` |
| session switch | 列出工作階段及其視窗數目，並切換用戶端 |
| window switch | 列出所有工作階段中的所有視窗，並選取所選視窗 |
| pane switch | 列出所有窗格及其正在執行的指令，並選取所選窗格 |
| session kill | 關閉所選工作階段，不需確認 |
| tree | 把工作階段、視窗和窗格放在同一個清單，然後跳到所選項目 |
| create | 切換到所選工作階段；沒有相符項目時，以查詢文字命名建立工作階段並切換過去 |
| URLs | 列出目前窗格可見畫面上的 URL，並以 `open` 或 `xdg-open` 開啟所選項目 |
| cheatsheet | 搜尋 `list-keys` 的輸出 |
| process | 列出 `ps` 的處理程序，詢問 `no` 或 `yes`，然後向所選處理程序傳送 `TERM` |
| rename | 選取一個視窗，然後提示輸入新名稱 |
| multi-kill | 以 `Tab` 標記多個工作階段，詢問 `no` 或 `yes`，然後全部關閉 |
| broadcast | 提示輸入一行文字，標記多個窗格，然後在每個窗格輸入該文字並按 `Enter` |
| zoxide | 列出 `zoxide query -l` 的目錄，然後在所選目錄連接或建立工作階段 |
| last | 不開啟選擇器，直接把用戶端切換到上一個工作階段 |
| move | 選取一個視窗，然後提示輸入要移往的工作階段 |

由查詢文字或目錄產生的工作階段名稱只保留路徑的最後一部分，並把 `.`、`:` 和空格換成 `_`。

## 系統要求

| 要求 | 版本或備註 |
|:------------|:----------------|
| tmux | 彈出視窗需要 3.2 或以上版本；較舊的 tmux 會在新視窗開啟每個選擇器 |
| bash | 3.2 或以上版本，因此 macOS 的 `/bin/bash` 可以使用 |
| [fzf](https://github.com/junegunn/fzf) | 位於 `PATH` 中 |
| [zoxide](https://github.com/ajeetdsouza/zoxide)，可選 | 用於 zoxide 動作 |
| 開啟程式，可選 | `open` 或 `xdg-open`，用於 URL 動作 |

CI 在 Linux x86_64 和 arm64 上以 GNU coreutils 和 uutils coreutils 執行測試套件，並在 macOS Apple Silicon 和 Intel 上以系統內建的 BSD 工具、GNU coreutils 和 uutils coreutils 執行。

## 安裝

使用 [TPM](https://github.com/tmux-plugins/tpm) 時，把插件加入 `~/.tmux.conf`，然後按 `prefix + I`：

```tmux
set -g @plugin 'tmux-revamped/tmux-fzf-revamped'
```

不使用 TPM 時，複製儲存庫，並在 `~/.tmux.conf` 中執行入口腳本：

```sh
git clone https://github.com/tmux-revamped/tmux-fzf-revamped ~/.tmux/plugins/tmux-fzf-revamped
```

```tmux
run-shell ~/.tmux/plugins/tmux-fzf-revamped/fzf-revamped.tmux
```

## 用法

`prefix + M-f` 開啟指令面板。其他動作在你為它們指定按鍵之前都保持未綁定。以下例子以 fzf 選擇器取代 tmux 內建的 `s` 和 `w` 選擇器，並加入幾個動作：

```tmux
set -g @fzf_revamped_session_key s
set -g @fzf_revamped_window_key w
set -g @fzf_revamped_pane_key e
set -g @fzf_revamped_tree_key T
set -g @fzf_revamped_create_key C
set -g @fzf_revamped_last_key L
```

在任何選擇器中，輸入文字篩選，按 `Enter` 執行，按 `Esc` 不執行直接關閉。把 `@fzf_revamped_preview` 設為 `on` 後，切換選擇器會在清單下方顯示游標所在項目的畫面。

## 設定

| 選項 | 預設值 | 意思 |
|:-------|:--------|:--------|
| `@fzf_revamped_popup_width` | `60%` | 彈出視窗闊度 |
| `@fzf_revamped_popup_height` | `50%` | 彈出視窗高度 |
| `@fzf_revamped_popup_border` | `rounded` | tmux 3.4 或以上版本的彈出視窗邊框：`rounded`、`single`、`double`、`heavy`、`simple`、`padded` 或 `none`；舊版 tmux 會忽略 |
| `@fzf_revamped_preview` | 未設定 | `on` 或 `1` 會在切換選擇器中即時預覽游標所在的窗格 |
| `@fzf_revamped_mru` | 未設定 | `on` 會按最近連接時間排列工作階段清單 |

下一節的按鍵選項只在插件載入時讀取一次。

### 內部狀態

此選項由插件自行管理，請勿設定。

| 選項 | 保存內容 |
|:-------|:------|
| `@fzf_revamped_broadcast_text` | 在 broadcast 提示中輸入的文字，保留至窗格選擇器讀取為止，其後取消設定 |

## 按鍵綁定

值為空或為 `off` 時，該動作不會綁定。

| 選項 | 預設值 | 動作 |
|:-------|:--------|:-------|
| `@fzf_revamped_palette_key` | `M-f` | palette |
| `@fzf_revamped_session_key` | 未綁定 | session switch |
| `@fzf_revamped_window_key` | 未綁定 | window switch |
| `@fzf_revamped_pane_key` | 未綁定 | pane switch |
| `@fzf_revamped_kill_key` | 未綁定 | session kill |
| `@fzf_revamped_tree_key` | 未綁定 | tree |
| `@fzf_revamped_create_key` | 未綁定 | create |
| `@fzf_revamped_url_key` | 未綁定 | URLs |
| `@fzf_revamped_cheatsheet_key` | 未綁定 | cheatsheet |
| `@fzf_revamped_process_key` | 未綁定 | process |
| `@fzf_revamped_rename_key` | 未綁定 | rename |
| `@fzf_revamped_multikill_key` | 未綁定 | multi-kill |
| `@fzf_revamped_broadcast_key` | 未綁定 | broadcast |
| `@fzf_revamped_zoxide_key` | 未綁定 | zoxide |
| `@fzf_revamped_last_key` | 未綁定 | last |
| `@fzf_revamped_move_key` | 未綁定 | move |

`M-f` 是本插件在家族按鍵分配中的位置。其他動作全部保持未綁定，因此安裝整個家族亦不會產生按鍵衝突。

## 運作原理

```mermaid
graph LR
    A[按鍵] --> B[display-popup]
    B --> C[tmux 清單]
    C --> D[fzf]
    D --> E[隱藏的目標 ID]
    E --> F[切換、關閉、重新命名或建立]
```

入口腳本 [`fzf-revamped.tmux`](fzf-revamped.tmux) 檢查 tmux 版本，把每個按鍵綁定到 `display-popup -E`，在 tmux 3.2 之前則綁定到 `new-window`，兩者都執行 [`src/fzf.sh`](src/fzf.sh)。清單每一行都帶有目標 ID，作為 fzf 不顯示的隱藏首欄，因此名為 `feature/login` 的視窗或名稱含空格的工作階段，亦能解析到正確的對象。在 broadcast、rename 和 move 提示中輸入的文字，經由會加上引號的 `%%%` 佔位符傳給 tmux，broadcast 再以 `send-keys -l` 輸入，因此引號、`$`、`;` 以及 `Enter` 這類字詞都會按字面文字送達。

## 開發

| 指令 | 執行內容 |
|:--------|:-------------|
| `make test` | [`test/`](test) 下的 bats 測試套件 |
| `make lint` | 對所有 shell 檔案和 [`family/bin/`](family/bin) 執行 warning 級別的 shellcheck |
| `make coverage` | 在 Linux 上以 kcov 計算行覆蓋率，低於 95% 時失敗 |

ID 解析、模式及訊號驗證、版本檢查和工作階段命名，都以純函數形式放在 [`src/lib/fzf/fzf.sh`](src/lib/fzf/fzf.sh)。[`src/fzf.sh`](src/fzf.sh) 中每次 tmux 呼叫都經過同一個包裝函數，因此毋須 tmux 伺服器或 fzf 便可測試路由邏輯。

## 授權

[MIT](LICENSE)，copyright Gustavo Franco。

<!-- family:begin -->

## tmux-revamped 插件家族

本插件是 tmux-revamped 插件家族的成員。每個成員都帶有 [`FAMILY.md`](FAMILY.md) 中的同一份約定、`family/` 下的同一套工具和同一個共用程式庫，並由校驗和清單確保逐位元組一致。這些成員可以一併安裝：任何成員都不會佔用其他成員使用的按鍵或 tmux 選項。

在一個成員中發現的缺陷，要在全部成員中排查後才算修正完成。這項責任寫在約定之中，而不是依靠記憶，`family/bin/sweep` 負責執行。

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
| [`tmux-plugin-template`](https://github.com/tmux-revamped/tmux-plugin-template) | tmux-revamped 插件的起點：共用程式庫、bats 測試框架、CI 和系列工具 |
| [`tmux-pomodoro-revamped`](https://github.com/tmux-revamped/tmux-pomodoro-revamped) | tmux 狀態列中的番茄鐘計時器，所有狀態都儲存在 tmux 選項中，不使用暫存檔 |
| [`tmux-ram-revamped`](https://github.com/tmux-revamped/tmux-ram-revamped) | 在 tmux 狀態列顯示記憶體、交換空間及記憶體壓力，在背景取樣，繪製從不等待 |
| [`tmux-reorder-revamped`](https://github.com/tmux-revamped/tmux-reorder-revamped) | 用滑鼠在 tmux 狀態列上拖動視窗標籤來移動該視窗 |
| [`tmux-scroll-revamped`](https://github.com/tmux-revamped/tmux-scroll-revamped) | 將滑鼠滾輪交給能自行捲動的應用程式，其他情況下進入 tmux 複製模式 |
| [`tmux-sensible-revamped`](https://github.com/tmux-revamped/tmux-sensible-revamped) | 按 tmux 版本和終端機區分的合理預設設定，不會改動你自己設定的選項 |
| [`tmux-tiling-revamped`](https://github.com/tmux-revamped/tmux-tiling-revamped) | tmux 的平鋪視窗管理：八種版面，包括 BSP dwindle 和 spiral，並支援復原版面 |
| [`tmux-time-revamped`](https://github.com/tmux-revamped/tmux-time-revamped) | 狀態列中的本地時鐘和世界時鐘，按一天中的時段著色，並提供倒數和夏令時間提示 |
| [`tmux-weather-revamped`](https://github.com/tmux-revamped/tmux-weather-revamped) | 在背景從 wttr.in 取得天氣並顯示在狀態列，狀態列毋須等待 |

### 檢查安裝

所有成員都在磁碟上時，一個指令即可報告它們之間的任何衝突：

```sh
family/bin/doctor --live
```

它讀取每個成員和正在運行的 tmux 伺服器，報告重複的按鍵、重複的狀態佔位符、不符合命名規則的選項，以及約定版本落後的成員。

<!-- family:end -->
