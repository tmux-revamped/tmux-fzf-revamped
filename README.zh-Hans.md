<div align="center">

# tmux-fzf-revamped

<strong>在弹出窗口中的 fzf 选择器里切换、关闭、重命名或创建 tmux 会话、窗口和窗格。</strong>

[English](README.md) | [日本語](README.ja.md) | 简体中文 | [繁體中文（香港）](README.zh-HK.md)

[![Tests](https://github.com/tmux-revamped/tmux-fzf-revamped/actions/workflows/tests.yml/badge.svg)](https://github.com/tmux-revamped/tmux-fzf-revamped/actions/workflows/tests.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Version](https://img.shields.io/badge/version-1.2.0-blue.svg)](CHANGELOG.md)

<p align="center">
  <a href="#功能">功能</a> |
  <a href="#环境要求">环境要求</a> |
  <a href="#安装">安装</a> |
  <a href="#用法">用法</a> |
  <a href="#配置">配置</a> |
  <a href="#按键绑定">按键绑定</a> |
  <a href="#工作原理">工作原理</a> |
  <a href="#开发">开发</a>
</p>

</div>

共 **16** 个操作，默认绑定 **1** 个，命令面板中有 **10** 条 tmux 命令。

---

## 功能

每个操作都会在 tmux 弹出窗口中打开一个 fzf 列表。选中一项后，插件对它执行操作：切换到某个会话、窗口或窗格，关闭它，重命名它，或者创建一个尚不存在的会话。

| 操作 | 作用 |
|:-------|:-------------|
| palette | 运行 10 条 tmux 命令之一：`new-window`、两种分割、下一个、上一个和最近的窗口、`kill-pane`、`kill-window`、`detach-client`、`choose-tree` |
| session switch | 列出会话及其窗口数，并切换客户端 |
| window switch | 列出所有会话中的所有窗口，并选中所选窗口 |
| pane switch | 列出所有窗格及其正在运行的命令，并选中所选窗格 |
| session kill | 关闭所选会话，不需要确认 |
| tree | 把会话、窗口和窗格放在一个列表中，然后跳转到所选项 |
| create | 切换到所选会话；没有匹配项时，以查询文本命名创建一个会话并切换过去 |
| URLs | 列出当前窗格可见屏幕上的 URL，并用 `open` 或 `xdg-open` 打开所选项 |
| cheatsheet | 搜索 `list-keys` 的输出 |
| process | 列出 `ps` 中的进程，询问 `no` 或 `yes`，然后向所选进程发送 `TERM` |
| rename | 选择一个窗口，然后提示输入新名称 |
| multi-kill | 用 `Tab` 标记多个会话，询问 `no` 或 `yes`，然后全部关闭 |
| broadcast | 提示输入一行文本，标记多个窗格，然后在每个窗格中输入该文本并按 `Enter` |
| zoxide | 列出 `zoxide query -l` 的目录，然后在所选目录中连接或创建会话 |
| last | 不打开选择器，直接把客户端切换到上一个会话 |
| move | 选择一个窗口，然后提示输入要移动到的会话 |

由查询文本或目录生成的会话名只保留路径的最后一部分，并把 `.`、`:` 和空格替换为 `_`。

## 环境要求

| 要求 | 版本或说明 |
|:------------|:----------------|
| tmux | 弹出窗口需要 3.2 或更高版本；更旧的 tmux 会在新窗口中打开每个选择器 |
| bash | 3.2 或更高版本，因此 macOS 的 `/bin/bash` 可以使用 |
| [fzf](https://github.com/junegunn/fzf) | 位于 `PATH` 中 |
| [zoxide](https://github.com/ajeetdsouza/zoxide)，可选 | 用于 zoxide 操作 |
| 打开程序，可选 | `open` 或 `xdg-open`，用于 URL 操作 |

CI 在 Linux x86_64 和 arm64 上使用 GNU coreutils 和 uutils coreutils 运行测试套件，并在 macOS Apple Silicon 和 Intel 上使用系统自带的 BSD 工具、GNU coreutils 和 uutils coreutils 运行。

## 安装

使用 [TPM](https://github.com/tmux-plugins/tpm) 时，把插件加入 `~/.tmux.conf`，然后按 `prefix + I`：

```tmux
set -g @plugin 'tmux-revamped/tmux-fzf-revamped'
```

不使用 TPM 时，克隆仓库，并在 `~/.tmux.conf` 中运行入口脚本：

```sh
git clone https://github.com/tmux-revamped/tmux-fzf-revamped ~/.tmux/plugins/tmux-fzf-revamped
```

```tmux
run-shell ~/.tmux/plugins/tmux-fzf-revamped/fzf-revamped.tmux
```

## 用法

`prefix + M-f` 打开命令面板。其他操作在你为它们指定按键之前都保持未绑定。下面的示例用 fzf 选择器替换 tmux 自带的 `s` 和 `w` 选择器，并添加了几个操作：

```tmux
set -g @fzf_revamped_session_key s
set -g @fzf_revamped_window_key w
set -g @fzf_revamped_pane_key e
set -g @fzf_revamped_tree_key T
set -g @fzf_revamped_create_key C
set -g @fzf_revamped_last_key L
```

在任何选择器中，输入文字进行过滤，按 `Enter` 执行，按 `Esc` 不执行直接关闭。把 `@fzf_revamped_preview` 设为 `on` 后，切换选择器会在列表下方显示光标所在项的屏幕内容。

## 配置

| 选项 | 默认值 | 含义 |
|:-------|:--------|:--------|
| `@fzf_revamped_popup_width` | `60%` | 弹出窗口宽度 |
| `@fzf_revamped_popup_height` | `50%` | 弹出窗口高度 |
| `@fzf_revamped_popup_border` | `rounded` | tmux 3.4 及以上版本的弹出窗口边框：`rounded`、`single`、`double`、`heavy`、`simple`、`padded` 或 `none`；旧版 tmux 会忽略 |
| `@fzf_revamped_preview` | 未设置 | `on` 或 `1` 会在切换选择器中实时预览光标所在的窗格 |
| `@fzf_revamped_mru` | 未设置 | `on` 会按最近连接时间排列会话列表 |

下一节中的按键选项只在插件加载时读取一次。

### 内部状态

此选项由插件自己管理，请不要设置。

| 选项 | 保存内容 |
|:-------|:------|
| `@fzf_revamped_broadcast_text` | 在 broadcast 提示中输入的文本，保留到窗格选择器读取为止，随后取消设置 |

## 按键绑定

值为空或为 `off` 时，对应操作不绑定。

| 选项 | 默认值 | 操作 |
|:-------|:--------|:-------|
| `@fzf_revamped_palette_key` | `M-f` | palette |
| `@fzf_revamped_session_key` | 未绑定 | session switch |
| `@fzf_revamped_window_key` | 未绑定 | window switch |
| `@fzf_revamped_pane_key` | 未绑定 | pane switch |
| `@fzf_revamped_kill_key` | 未绑定 | session kill |
| `@fzf_revamped_tree_key` | 未绑定 | tree |
| `@fzf_revamped_create_key` | 未绑定 | create |
| `@fzf_revamped_url_key` | 未绑定 | URLs |
| `@fzf_revamped_cheatsheet_key` | 未绑定 | cheatsheet |
| `@fzf_revamped_process_key` | 未绑定 | process |
| `@fzf_revamped_rename_key` | 未绑定 | rename |
| `@fzf_revamped_multikill_key` | 未绑定 | multi-kill |
| `@fzf_revamped_broadcast_key` | 未绑定 | broadcast |
| `@fzf_revamped_zoxide_key` | 未绑定 | zoxide |
| `@fzf_revamped_last_key` | 未绑定 | last |
| `@fzf_revamped_move_key` | 未绑定 | move |

`M-f` 是本插件在家族按键分配中的位置。其他操作全部保持未绑定，因此安装整个家族也不会产生按键冲突。

## 工作原理

```mermaid
graph LR
    A[按键] --> B[display-popup]
    B --> C[tmux 列表]
    C --> D[fzf]
    D --> E[隐藏的目标 ID]
    E --> F[切换、关闭、重命名或创建]
```

入口脚本 [`fzf-revamped.tmux`](fzf-revamped.tmux) 检查 tmux 版本，把每个按键绑定到 `display-popup -E`，在 tmux 3.2 之前则绑定到 `new-window`，两者都运行 [`src/fzf.sh`](src/fzf.sh)。列表的每一行都带有目标 ID，作为 fzf 不显示的隐藏首列，因此名为 `feature/login` 的窗口或名称中含空格的会话也能解析到正确的对象。在 broadcast、rename 和 move 提示中输入的文本通过会加引号的 `%%%` 占位符传给 tmux，broadcast 再用 `send-keys -l` 输入，因此引号、`$`、`;` 以及 `Enter` 这样的单词都会按字面文本送达。

## 开发

| 命令 | 运行内容 |
|:--------|:-------------|
| `make test` | [`test/`](test) 下的 bats 测试套件 |
| `make lint` | 对所有 shell 文件和 [`family/bin/`](family/bin) 运行 warning 级别的 shellcheck |
| `make coverage` | 在 Linux 上用 kcov 统计行覆盖率，低于 95% 时失败 |

ID 解析、模式和信号校验、版本检查以及会话命名都以纯函数的形式放在 [`src/lib/fzf/fzf.sh`](src/lib/fzf/fzf.sh) 中。[`src/fzf.sh`](src/fzf.sh) 中的每次 tmux 调用都经过同一个包装函数，因此无需 tmux 服务器或 fzf 即可测试路由逻辑。

## 许可证

[MIT](LICENSE)，copyright Gustavo Franco。

<!-- family:begin -->

## tmux-revamped 插件家族

本插件是 tmux-revamped 插件家族的一员。每个成员都带有 [`FAMILY.md`](FAMILY.md) 中的同一份约定、`family/` 下的同一套工具和同一个共享库，并由校验和清单保证逐字节一致。这些成员可以一起安装：任何成员都不会占用其他成员使用的按键或 tmux 选项。

在一个成员中发现的缺陷，要在全部成员中排查之后才算修复完成。这项义务写在约定里，而不是靠记忆，`family/bin/sweep` 负责执行它。

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
| [`tmux-plugin-template`](https://github.com/tmux-revamped/tmux-plugin-template) | tmux-revamped 插件的起点：共享库、bats 测试框架、CI 和系列工具 |
| [`tmux-pomodoro-revamped`](https://github.com/tmux-revamped/tmux-pomodoro-revamped) | tmux 状态栏中的番茄钟计时器，所有状态都保存在 tmux 选项中，不使用临时文件 |
| [`tmux-ram-revamped`](https://github.com/tmux-revamped/tmux-ram-revamped) | 在 tmux 状态栏显示内存、交换空间和内存压力，在后台采样，渲染从不等待 |
| [`tmux-reorder-revamped`](https://github.com/tmux-revamped/tmux-reorder-revamped) | 用鼠标在 tmux 状态栏上拖动窗口标签来移动该窗口 |
| [`tmux-scroll-revamped`](https://github.com/tmux-revamped/tmux-scroll-revamped) | 将鼠标滚轮交给能自行滚动的应用，其他情况下进入 tmux 复制模式 |
| [`tmux-sensible-revamped`](https://github.com/tmux-revamped/tmux-sensible-revamped) | 按 tmux 版本和终端区分的合理默认设置，不改动你自己设置的选项 |
| [`tmux-tiling-revamped`](https://github.com/tmux-revamped/tmux-tiling-revamped) | tmux 的平铺窗口管理：八种布局，包括 BSP dwindle 和 spiral，并支持撤销布局 |
| [`tmux-time-revamped`](https://github.com/tmux-revamped/tmux-time-revamped) | 状态栏中的本地时钟和世界时钟，按一天中的时段着色，并提供倒计时和夏令时提醒 |
| [`tmux-weather-revamped`](https://github.com/tmux-revamped/tmux-weather-revamped) | 在后台从 wttr.in 获取天气并显示在状态栏，状态栏无需等待 |

### 检查安装

所有成员都在磁盘上时，一条命令即可报告它们之间的任何冲突：

```sh
family/bin/doctor --live
```

它读取每个成员和正在运行的 tmux 服务器，报告重复的按键、重复的状态占位符、不符合命名规则的选项，以及约定版本落后的成员。

<!-- family:end -->
