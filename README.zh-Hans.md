<div align="center">

# tmux-fzf-revamped

<strong>在弹出窗口的 fzf 选择器中切换、关闭、重命名或创建 tmux 会话、窗口和窗格。</strong>

[English](README.md) &nbsp;|&nbsp; [日本語](README.ja.md) &nbsp;|&nbsp; 简体中文 &nbsp;|&nbsp; [繁體中文（香港）](README.zh-HK.md)

[![ci](https://img.shields.io/github/actions/workflow/status/tmux-revamped/tmux-fzf-revamped/ci.yml?branch=main&style=flat-square&label=ci)](https://github.com/tmux-revamped/tmux-fzf-revamped/actions/workflows/ci.yml)
[![release](https://img.shields.io/github/v/release/tmux-revamped/tmux-fzf-revamped?style=flat-square&label=release)](https://github.com/tmux-revamped/tmux-fzf-revamped/releases/latest)
[![openssf scorecard](https://img.shields.io/ossf-scorecard/github.com/tmux-revamped/tmux-fzf-revamped?style=flat-square&label=openssf%20scorecard)](https://scorecard.dev/viewer/?uri=github.com/tmux-revamped/tmux-fzf-revamped)
[![license](https://img.shields.io/github/license/tmux-revamped/tmux-fzf-revamped?style=flat-square&label=license)](LICENSE)

<p align="center">
  <a href="#快速开始"><strong>快速开始</strong></a> &nbsp;|&nbsp;
  <a href="#用法">用法</a> &nbsp;|&nbsp;
  <a href="#选择器">选择器</a> &nbsp;|&nbsp;
  <a href="#界面">界面</a>
</p>

</div>

<p align="center">
  <img src="screens/hero.gif" alt="fzf-revamped 运行命令面板中的命令，在选择器中切换会话，再回到上一个会话" width="800">
</p>

```console
$ FZF_REVAMPED_SESSION_KEY=S FZF_REVAMPED_LAST_KEY=L fzf-revamped list
bind-key S display-popup -E -b rounded -w 60% -h 50% '/home/user/.tmux/plugins/tmux-fzf-revamped/bin/fzf-revamped' session switch
bind-key M-f display-popup -E -b rounded -w 60% -h 50% '/home/user/.tmux/plugins/tmux-fzf-revamped/bin/fzf-revamped' palette
bind-key L run-shell '/home/user/.tmux/plugins/tmux-fzf-revamped/bin/fzf-revamped' last
```

按下 `prefix M-f` 打开常用 tmux 命令的面板。其他选择器，从会话切换到广播提示，都等待你自己选择的按键，所以安装整个家族也不会产生按键冲突。

---

## 快速开始

### 前提条件

| 工具 | 版本 | 用途 |
|:-----|:--------|:---------|
| tmux | 弹出窗口需要 3.2 或更高 | 3.2 之前每个选择器在窗口中打开；边框需要 3.4 |
| fzf | 任意版本 | 所有选择器；缺少时 `doctor` 会报告 |
| 打开工具 | 可选 | 用于 URL 选择器：macOS 上的 `open`，Linux 上的 `xdg-open` |
| zoxide | 可选 | zoxide 选择器 |
| gum | 可选 | `fzf-revamped` 的菜单、表格和颜色；没有它，所有命令都输出纯文本 |

### 安装

```tmux
set -g @plugin 'tmux-revamped/tmux-fzf-revamped'
```

然后按 `prefix + I`。不用 TPM 时，克隆仓库，并在 `~/.tmux.conf` 中运行它的入口文件：

```bash
git clone https://github.com/tmux-revamped/tmux-fzf-revamped ~/.tmux/plugins/tmux-fzf-revamped
```

```tmux
run-shell ~/.tmux/plugins/tmux-fzf-revamped/fzf-revamped.tmux
```

在克隆的目录中运行 `make install`，还会把 `fzf-revamped` 放进 `~/.local/bin`，把它的 man 手册和补全放在 `~/.local/share` 下。

### 验证

```bash
~/.tmux/plugins/tmux-fzf-revamped/bin/fzf-revamped doctor
```

## 用法

为想用的选择器绑定按键，然后重新加载配置或运行 `fzf-revamped apply`：

```tmux
set -g @fzf_revamped_session_key 'S'
set -g @fzf_revamped_window_key 'W'
set -g @fzf_revamped_last_key 'L'
```

`M-f` 是本插件在家族按键分配中的位置。如果你已经自己绑定了 `prefix M-f`，插件会保留它，并由 `doctor` 说明。设为 `off` 的按键不绑定。即使一个按键名无效，其他按键仍会绑定，`apply` 会带着 tmux 的错误以 1 退出。

| 命令 | 作用 |
|:--------|:-------------|
| `fzf-revamped apply` | 立即绑定按键；插件加载时入口点会运行它 |
| `fzf-revamped list` | 打印 apply 会做的每个绑定；`--json` 输出一个对象 |
| 带选择器名称的 `fzf-revamped` | 带上选择器名称时，像按键一样运行该选择器；见选择器一节 |
| `fzf-revamped doctor` | 每个依赖一行，包括被他人占用的默认按键 |
| `fzf-revamped version` | 版本，然后是 tmux 版本 |
| `fzf-revamped help` | 帮助页；`man fzf-revamped` 记录相同的命令和设置 |
| `fzf-revamped` | 在终端上显示菜单 |

| tmux 选项 | 默认值 | 含义 |
|:------------|:--------|:--------|
| `@fzf_revamped_popup_width` | `60%` | 弹出窗口宽度 |
| `@fzf_revamped_popup_height` | `50%` | 弹出窗口高度 |
| `@fzf_revamped_popup_border` | `rounded` | tmux 3.4 及以后的弹出窗口边框：`rounded`、`single`、`double`、`heavy`、`simple`、`padded` 或 `none` |
| `@fzf_revamped_preview` | `off` | `on` 或 `1` 时在切换选择器中显示光标下的窗格 |
| `@fzf_revamped_mru` | `off` | `on` 时按最后连接时间排列会话 |

每个选项也可以写成用短横线连接的命令选项，例如 `--session-key S`，以及环境变量，例如 `FZF_REVAMPED_SESSION_KEY`；命令行优先于环境变量，环境变量优先于 tmux 选项。以 tmux 选项给出的 `preview` 和 `mru` 在选择器运行时读取；通过命令行或环境变量传给 `fzf-revamped apply` 的值会带到它绑定的按键上。空的 tmux 选项表示使用默认值。

<a id="选择器"></a>

## 选择器

| 按键选项 | 命令 | 作用 |
|:-----------|:--------|:-------------|
| `@fzf_revamped_palette_key`，`M-f` | `palette` | 从简短列表中运行 tmux 命令 |
| `@fzf_revamped_session_key` | `session switch` | 切换到选中的会话 |
| `@fzf_revamped_window_key` | `window switch` | 切换到选中的窗口及其会话 |
| `@fzf_revamped_pane_key` | `pane switch` | 切换到选中的窗格 |
| `@fzf_revamped_kill_key` | `session kill` | 关闭选中的会话 |
| `@fzf_revamped_tree_key` | `tree` | 前往任意会话、窗口或窗格 |
| `@fzf_revamped_create_key` | `create` | 切换到会话，或用输入的名称创建一个 |
| `@fzf_revamped_url_key` | `urls open` | 打开屏幕上的 URL；`urls copy` 把它复制到 tmux 缓冲区 |
| `@fzf_revamped_cheatsheet_key` | `cheatsheet` | 浏览所有按键绑定，并运行选中的那个 |
| `@fzf_revamped_process_key` | `process` | 确认后向选中的进程发送 TERM 或指定的信号 |
| `@fzf_revamped_rename_key` | `rename window` | 通过提示重命名选中的窗口；`rename session` 重命名会话 |
| `@fzf_revamped_multikill_key` | `multi-kill session` | 确认后关闭用 `Tab` 标记的所有会话 |
| `@fzf_revamped_broadcast_key` | `broadcast` | 提示输入文本，然后把它和 `Enter` 输入到所有标记的窗格 |
| `@fzf_revamped_zoxide_key` | `zoxide` | 在 zoxide 文件夹打开会话 |
| `@fzf_revamped_last_key` | `last` | 不用弹出窗口，切换到上一个会话 |
| `@fzf_revamped_move_key` | `move-window move` | 把选中的窗口移到提示中输入的会话；`move-window link` 则链接它 |

`window kill`、`pane kill`、`multi-kill window` 和 `multi-kill pane` 没有按键，从命令行运行。列表的每一行都把目标放在隐藏的第一列，所以名为 `feature/login` 的窗口或含空格的会话也能正确定位。

<a id="界面"></a>

## 界面

<details>
<summary>所有界面，在真实的 tmux 中用 <code>make screens</code> 录制，每个按键显示在状态栏上</summary>
<br>

<table>
<tr>
<td width="50%" valign="top"><img src="screens/palette.png" alt="fzf-revamped：prefix M-f 打开命令面板"><br><sub><code>prefix M-f</code> 打开命令面板，来自 <code>hero.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/palette-split.png" alt="fzf-revamped：运行面板中的 split-window -h"><br><sub>运行面板中的 <code>split-window -h</code>，来自 <code>hero.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/sessions.png" alt="fzf-revamped：带预览的会话切换"><br><sub>带预览的会话切换，来自 <code>hero.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/switched.png" alt="fzf-revamped：客户端切换到选中的会话"><br><sub>客户端切换到选中的会话，来自 <code>hero.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/last.png" alt="fzf-revamped：last 键回到上一个会话"><br><sub>last 键回到上一个会话，来自 <code>hero.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/windows.png" alt="fzf-revamped：窗口切换"><br><sub>窗口切换，来自 <code>stills.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/panes.png" alt="fzf-revamped：窗格切换"><br><sub>窗格切换，来自 <code>stills.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/tree.png" alt="fzf-revamped：会话、窗口和窗格的树"><br><sub>会话、窗口和窗格的树，来自 <code>stills.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/create.png" alt="fzf-revamped：输入新名称的创建或切换"><br><sub>输入新名称的创建或切换，来自 <code>stills.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/created.png" alt="fzf-revamped：新会话"><br><sub>新会话，来自 <code>stills.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/urls.png" alt="fzf-revamped：屏幕上的 URL"><br><sub>屏幕上的 URL，来自 <code>stills.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/cheatsheet.png" alt="fzf-revamped：筛选到一个命令的速查表"><br><sub>筛选到一个命令的速查表，来自 <code>stills.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/cheatsheet-run.png" alt="fzf-revamped：从速查表运行的按键绑定"><br><sub>从速查表运行的按键绑定：窗格已分割，来自 <code>stills.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/process.png" alt="fzf-revamped：进程选择器"><br><sub>进程选择器，来自 <code>stills.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/process-confirm.png" alt="fzf-revamped：发送信号前的确认"><br><sub>发送信号前的确认，来自 <code>stills.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/rename.png" alt="fzf-revamped：重命名提示"><br><sub>重命名提示，来自 <code>stills.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/kill.png" alt="fzf-revamped：会话关闭"><br><sub>会话关闭，来自 <code>stills.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/multikill.png" alt="fzf-revamped：多选关闭中标记的两个会话"><br><sub>多选关闭中标记的两个会话，来自 <code>stills.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/broadcast.png" alt="fzf-revamped：广播中标记的两个窗格"><br><sub>广播中标记的两个窗格，来自 <code>stills.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/zoxide.png" alt="fzf-revamped：zoxide 文件夹"><br><sub>zoxide 文件夹，来自 <code>stills.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/move.png" alt="fzf-revamped：窗口移动提示"><br><sub>窗口移动提示，来自 <code>stills.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/menu.png" alt="fzf-revamped：菜单"><br><sub>菜单，来自 <code>stills.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/doctor.png" alt="fzf-revamped：doctor"><br><sub><code>doctor</code>，来自 <code>stills.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/list.png" alt="fzf-revamped：list"><br><sub><code>list</code>，来自 <code>stills.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/json.png" alt="fzf-revamped：list --json"><br><sub><code>list --json</code>，来自 <code>stills.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/plain-menu.png" alt="fzf-revamped：没有 gum 的菜单"><br><sub>没有 gum 的菜单，来自 <code>stills.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/plain-apply.png" alt="fzf-revamped：从菜单运行 apply"><br><sub>从菜单运行 <code>apply</code>，来自 <code>stills.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/version.png" alt="fzf-revamped：版本"><br><sub>版本，来自 <code>stills.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/error.png" alt="fzf-revamped：未知命令"><br><sub>未知命令，来自 <code>stills.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/themes.png" alt="fzf-revamped：六种主题下的标题"><br><sub>六种主题下的标题，来自 <code>themes.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/help.png" alt="fzf-revamped：帮助页"><br><sub>帮助页，来自 <code>help.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/accent.png" alt="fzf-revamped：来自 FZF_REVAMPED_ACCENT 的强调色"><br><sub>来自 <code>FZF_REVAMPED_ACCENT</code> 的强调色，来自 <code>stills.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"></td>
</tr>
</table>

</details>

## 可移植性

插件是 POSIX `sh`。CI 在下面每一行上运行全部测试。

| Shell | 状态 |
|:------|:-------|
| `dash`、macOS 上的 `/bin/sh` | 支持 |
| `bash` 3.2 和 5.x、系统自带的 `zsh` 和 Homebrew 的 `zsh` | 支持 |

| 系统 | 状态 |
|:-------|:-------|
| macOS | Apple Silicon 和 Intel 上的 Tahoe，使用系统自带的工具、Homebrew 的 GNU 工具和 Homebrew 的 uutils |
| Linux | x86_64 和 arm64 上的 Ubuntu 26.04，使用 GNU coreutils、uutils 和 BusyBox |

## 开发

| 命令 | 运行内容 |
|:--------|:-------------|
| `make fmt` | 对每个脚本运行 shfmt `-i 2` |
| `make lint` | shfmt、ShellCheck、mandoc、yamllint 和 actionlint，零告警 |
| `make test` | 在系统 `sh` 下运行 bats 测试 |
| `make test-all` | 在每个已安装的 shell 下运行测试，macOS 上包括 bash 和 zsh 的两种构建 |
| `make test-linux` | 在 Ubuntu 容器中运行测试 |
| `make coverage` | 在这台 Mac 和 Ubuntu 容器中运行 bashcov，合并后以 100% 为门槛 |
| `make screens` | 用 VHS 在 tmux 中从真实插件录制上面的界面，在 macOS 上运行 |
| `make install` | 把命令、man 手册和补全安装到 `PREFIX` 下 |

提交遵循 Conventional Commits 格式，直接进入 `main`。`main` 上的 `ci` 通过后，`release.yml` 运行 semantic-release：自上一个标签以来的每个 `feat` 或 `fix` 都会发布新版本，更新版本常量，并把说明写进 [`CHANGELOG.md`](CHANGELOG.md)。

## 许可证

[MIT](LICENSE)，copyright Gustavo Franco。

<!-- family:begin -->

## tmux-revamped 插件家族

这个插件是 tmux-revamped 插件家族的一员。每个成员都带有 [`FAMILY.md`](FAMILY.md) 中相同的约定和相同的共享库，并且设计为一起安装：没有成员占用另一个成员占用的按键或 tmux 选项。

在一个成员中发现的缺陷，要在全部成员中排查之后才算修复完成。

| 成员 | 功能 |
|---|---|
| [`tmux-autoreload-revamped`](https://github.com/tmux-revamped/tmux-autoreload-revamped) | 编辑并保存 tmux 配置后，它会自动重新加载，无需按键，也无需命令 |
| [`tmux-battery-revamped`](https://github.com/tmux-revamped/tmux-battery-revamped) | 在 tmux 状态栏显示电池状态，从不阻塞状态栏渲染 |
| [`tmux-bluetooth-revamped`](https://github.com/tmux-revamped/tmux-bluetooth-revamped) | 在 tmux 状态栏显示每个已连接的蓝牙设备及其电量，不阻塞渲染 |
| [`tmux-cpu-revamped`](https://github.com/tmux-revamped/tmux-cpu-revamped) | 在 tmux 状态栏显示 CPU 负载、温度和频率，从不阻塞渲染 |
| [`tmux-disk-revamped`](https://github.com/tmux-revamped/tmux-disk-revamped) | 在 tmux 状态栏显示磁盘用量，从不阻塞状态栏渲染 |
| [`tmux-extract-revamped`](https://github.com/tmux-revamped/tmux-extract-revamped) | 用 fzf 从屏幕上挑选 URL、路径、哈希或任意其他词元，并输入到光标处，全部用纯 shell 实现 |
| [`tmux-fzf-revamped`](https://github.com/tmux-revamped/tmux-fzf-revamped) | **本插件**，在弹出窗口中的 fzf 选择器里切换、关闭、重命名或创建 tmux 会话、窗口和窗格 |
| [`tmux-git-revamped`](https://github.com/tmux-revamped/tmux-git-revamped) | 在 tmux 状态栏中显示活动窗格的 git 分支、改动和托管平台计数，且不阻塞渲染 |
| [`tmux-gpu-revamped`](https://github.com/tmux-revamped/tmux-gpu-revamped) | 在 tmux 状态栏中显示 NVIDIA、AMD、Intel 和 Apple GPU 的负载、温度、频率、功耗和显存 |
| [`tmux-kube-revamped`](https://github.com/tmux-revamped/tmux-kube-revamped) | 在 tmux 状态栏中显示当前的 Kubernetes 上下文和命名空间，不依赖 kubectl，直接解析 kubeconfig |
| [`tmux-launcher-revamped`](https://github.com/tmux-revamped/tmux-launcher-revamped) | 在弹出窗口或新窗口中启动任意 TUI 应用，从当前窗格的目录开始，每个应用可配置一个按键 |
| [`tmux-logging-revamped`](https://github.com/tmux-revamped/tmux-logging-revamped) | 将任意窗格保存到文件：实时日志、完整回滚缓冲区或一次性截图 |
| [`tmux-music-revamped`](https://github.com/tmux-revamped/tmux-music-revamped) | 在 tmux 状态栏显示正在播放的曲目，从不阻塞状态栏渲染 |
| [`tmux-network-revamped`](https://github.com/tmux-revamped/tmux-network-revamped) | 在 tmux 状态栏显示网络吞吐量，从不阻塞渲染 |
| [`tmux-pain-control-revamped`](https://github.com/tmux-revamped/tmux-pain-control-revamped) | tmux 的窗格和窗口管理按键，适配 tmux 版本，兼容 vim，每个 prefix 按键都可禁用 |
| [`tmux-persist-revamped`](https://github.com/tmux-revamped/tmux-persist-revamped) | 保存 tmux 的所有会话、窗口和窗格，按定时器自动保存，并在重启后全部恢复 |
| [`tmux-plugin-template`](https://github.com/tmux-revamped/tmux-plugin-template) | tmux-revamped 插件的起点：共享库、bats 测试框架和 CI |
| [`tmux-pomodoro-revamped`](https://github.com/tmux-revamped/tmux-pomodoro-revamped) | tmux 状态栏中的番茄钟计时器，所有状态都保存在 tmux 选项中，不使用临时文件 |
| [`tmux-ram-revamped`](https://github.com/tmux-revamped/tmux-ram-revamped) | 在 tmux 状态栏显示内存、交换空间和内存压力，在后台采样，渲染从不等待 |
| [`tmux-reorder-revamped`](https://github.com/tmux-revamped/tmux-reorder-revamped) | 用鼠标在 tmux 状态栏上拖动窗口标签来移动该窗口 |
| [`tmux-scroll-revamped`](https://github.com/tmux-revamped/tmux-scroll-revamped) | 将鼠标滚轮交给能自行滚动的应用，其他情况下进入 tmux 复制模式 |
| [`tmux-sensible-revamped`](https://github.com/tmux-revamped/tmux-sensible-revamped) | 按 tmux 版本和终端区分的合理默认设置，不改动你自己设置的选项 |
| [`tmux-tiling-revamped`](https://github.com/tmux-revamped/tmux-tiling-revamped) | tmux 的平铺窗口管理：八种布局，包括 BSP dwindle 和 spiral，并支持撤销布局 |
| [`tmux-time-revamped`](https://github.com/tmux-revamped/tmux-time-revamped) | 状态栏中的本地时钟和世界时钟，按一天中的时段着色，并提供倒计时和夏令时提醒 |
| [`tmux-weather-revamped`](https://github.com/tmux-revamped/tmux-weather-revamped) | 在后台从 wttr.in 获取天气并显示在状态栏，状态栏无需等待 |

<!-- family:end -->
