<div align="center">

# tmux-fzf-revamped

<strong>ポップアップの fzf ピッカーから、tmux のセッション、ウィンドウ、ペインに切り替え、終了、名前変更、作成を行います。</strong>

[English](README.md) &nbsp;|&nbsp; 日本語 &nbsp;|&nbsp; [简体中文](README.zh-Hans.md) &nbsp;|&nbsp; [繁體中文（香港）](README.zh-HK.md)

[![ci](https://img.shields.io/github/actions/workflow/status/tmux-revamped/tmux-fzf-revamped/ci.yml?branch=main&style=flat-square&label=ci)](https://github.com/tmux-revamped/tmux-fzf-revamped/actions/workflows/ci.yml)
[![release](https://img.shields.io/github/v/release/tmux-revamped/tmux-fzf-revamped?style=flat-square&label=release)](https://github.com/tmux-revamped/tmux-fzf-revamped/releases/latest)
[![openssf scorecard](https://img.shields.io/ossf-scorecard/github.com/tmux-revamped/tmux-fzf-revamped?style=flat-square&label=openssf%20scorecard)](https://scorecard.dev/viewer/?uri=github.com/tmux-revamped/tmux-fzf-revamped)
[![license](https://img.shields.io/github/license/tmux-revamped/tmux-fzf-revamped?style=flat-square&label=license)](LICENSE)

<p align="center">
  <a href="#クイックスタート"><strong>クイックスタート</strong></a> &nbsp;|&nbsp;
  <a href="#使い方">使い方</a> &nbsp;|&nbsp;
  <a href="#ピッカー">ピッカー</a> &nbsp;|&nbsp;
  <a href="#画面">画面</a>
</p>

</div>

<p align="center">
  <img src="screens/hero.gif" alt="パレットのコマンドを実行し、ピッカーでセッションを切り替え、前のセッションに戻る fzf-revamped" width="800">
</p>

```console
$ FZF_REVAMPED_SESSION_KEY=S FZF_REVAMPED_LAST_KEY=L fzf-revamped list
bind-key S display-popup -E -b rounded -w 60% -h 50% '/home/user/.tmux/plugins/tmux-fzf-revamped/bin/fzf-revamped' session switch
bind-key M-f display-popup -E -b rounded -w 60% -h 50% '/home/user/.tmux/plugins/tmux-fzf-revamped/bin/fzf-revamped' palette
bind-key L run-shell '/home/user/.tmux/plugins/tmux-fzf-revamped/bin/fzf-revamped' last
```

`prefix M-f` で、よく使う tmux コマンドのパレットが開きます。セッション切り替えからブロードキャストまで、ほかのピッカーは自分で選んだキーで開くので、ファミリー全体を入れてもキーは衝突しません。

---

## クイックスタート

### 前提条件

| ツール | バージョン | 用途 |
|:-----|:--------|:---------|
| tmux | ポップアップには 3.2 以降 | 3.2 より前はピッカーがウィンドウで開きます。枠線には 3.4 が必要です |
| fzf | 任意のバージョン | すべてのピッカー。ないときは `doctor` が報告します |
| オープナー | 任意 | URL ピッカー用。macOS では `open`、Linux では `xdg-open` |
| zoxide | 任意 | zoxide ピッカー |
| gum | 任意 | `fzf-revamped` のメニュー、表、色。なくてもすべてのコマンドがプレーンテキストで動きます |

### インストール

```tmux
set -g @plugin 'tmux-revamped/tmux-fzf-revamped'
```

続けて `prefix + I` を押します。TPM を使わない場合は、リポジトリをクローンし、`~/.tmux.conf` からエントリーポイントを実行します。

```bash
git clone https://github.com/tmux-revamped/tmux-fzf-revamped ~/.tmux/plugins/tmux-fzf-revamped
```

```tmux
run-shell ~/.tmux/plugins/tmux-fzf-revamped/fzf-revamped.tmux
```

クローンで `make install` を実行すると、`fzf-revamped` が `~/.local/bin` に、manページと補完が `~/.local/share` の下に入ります。

### 確認

```bash
~/.tmux/plugins/tmux-fzf-revamped/bin/fzf-revamped doctor
```

## 使い方

使いたいピッカーにキーを割り当て、設定を再読み込みするか `fzf-revamped apply` を実行します。

```tmux
set -g @fzf_revamped_session_key 'S'
set -g @fzf_revamped_window_key 'W'
set -g @fzf_revamped_last_key 'L'
```

`M-f` はファミリーのキー割り当てでこのプラグインの枠です。`prefix M-f` を自分で割り当てているときは、プラグインはそのままにし、`doctor` がそれを報告します。`off` にしたキーは割り当てません。キー名が 1 つ無効でも、ほかのキーは割り当てられ、`apply` は tmux のエラーとともに 1 で終わります。

| コマンド | 動作 |
|:--------|:-------------|
| `fzf-revamped apply` | キーを今すぐ割り当てます。プラグインの読み込み時にエントリーポイントが実行します |
| `fzf-revamped list` | apply が行う割り当てをすべて表示します。`--json` で 1 つのオブジェクトを出力します |
| ピッカー名付きの `fzf-revamped` | ピッカー名を付けると、キーと同じようにそのピッカーを実行します。ピッカーの節を参照 |
| `fzf-revamped doctor` | 依存関係ごとに 1 行。ほかの誰かが使っている既定キーも含みます |
| `fzf-revamped version` | バージョンと tmux のバージョン |
| `fzf-revamped help` | ヘルプ。`man fzf-revamped` にも同じコマンドと設定があります |
| `fzf-revamped` | 端末ではメニュー |

| tmux オプション | 既定値 | 意味 |
|:------------|:--------|:--------|
| `@fzf_revamped_popup_width` | `60%` | ポップアップの幅 |
| `@fzf_revamped_popup_height` | `50%` | ポップアップの高さ |
| `@fzf_revamped_popup_border` | `rounded` | tmux 3.4 以降のポップアップの枠線。`rounded`、`single`、`double`、`heavy`、`simple`、`padded`、`none` |
| `@fzf_revamped_preview` | `off` | `on` か `1` で、切り替えピッカーにカーソル下のペインを表示します |
| `@fzf_revamped_mru` | `off` | `on` でセッションを最後に接続した順に並べます |
| `@fzf_revamped_projects` | `~/.config/fzf-revamped/projects` | プロジェクトの選択画面が読むファイル。1 行に 1 つのフォルダを書きます。`XDG_CONFIG_HOME` があればその下を使います |

どのオプションも、ダッシュ区切りのコマンドオプション（例 `--session-key S`）と環境変数（例 `FZF_REVAMPED_SESSION_KEY`）で指定できます。優先順位はコマンドライン、環境変数、tmux オプションの順です。tmux オプションで指定した `preview`、`mru`、`projects` は選択画面を開くたびに読まれ、`fzf-revamped apply` にコマンドラインまたは環境変数で渡したものは割り当てたキーに引き継がれます。空の tmux オプションは既定値を意味します。

<a id="ピッカー"></a>

## ピッカー

| キーのオプション | コマンド | 動作 |
|:-----------|:--------|:-------------|
| `@fzf_revamped_palette_key`、`M-f` | `palette` | 短い一覧から tmux コマンドを実行します |
| `@fzf_revamped_session_key` | `session switch` | 選んだセッションに切り替えます |
| `@fzf_revamped_window_key` | `window switch` | 選んだウィンドウに、そのセッションごと切り替えます |
| `@fzf_revamped_pane_key` | `pane switch` | 選んだペインに切り替えます |
| `@fzf_revamped_kill_key` | `session kill` | 選んだセッションを終了します |
| `@fzf_revamped_tree_key` | `tree` | 任意のセッション、ウィンドウ、ペインに移動します |
| `@fzf_revamped_create_key` | `create` | セッションに切り替えるか、入力した名前で作成します |
| `@fzf_revamped_url_key` | `urls open` | 画面上の URL を開きます。`urls copy` は tmux のバッファーにコピーします |
| `@fzf_revamped_cheatsheet_key` | `cheatsheet` | すべてのキー割り当てを表示し、選んだものを実行します |
| `@fzf_revamped_process_key` | `process` | 選んだプロセスに、確認後 TERM か指定したシグナルを送ります |
| `@fzf_revamped_rename_key` | `rename window` | 選んだウィンドウの名前をプロンプトで変えます。`rename session` はセッションの名前を変えます |
| `@fzf_revamped_multikill_key` | `multi-kill session` | `Tab` で選んだすべてのセッションを、確認後に終了します |
| `@fzf_revamped_broadcast_key` | `broadcast` | テキストを入力させ、選んだすべてのペインに入力して `Enter` を送ります |
| `@fzf_revamped_zoxide_key` | `zoxide` | zoxide のフォルダーでセッションを開きます |
| `@fzf_revamped_last_key` | `last` | ポップアップなしで前のセッションに切り替えます |
| `@fzf_revamped_move_key` | `move-window move` | 選んだウィンドウを、プロンプトで入力したセッションに移動します。`move-window link` はリンクします |
| `@fzf_revamped_arrange_key` | `arrange` | `join`、`break`、`swap`、`layout`、`resize` のどれかを尋ねてから、ペインをこのウィンドウに取り込む、ペインを独立したウィンドウに移す、このペインと入れ替える、このウィンドウのレイアウトを変える、このペインの端を 5、10、20 セル動かす、のいずれかを行います。`arrange join` などと指定すると最初の一覧を省きます |
| `@fzf_revamped_buffer_key` | `buffers paste` | 選んだ tmux バッファをこのペインに貼り付けます。`buffers delete` は削除します |
| `@fzf_revamped_projects_key` | `projects` | プロジェクトファイルにあるフォルダでセッションを開きます。すでに動いているものは `*` 付きで表示され、そこに切り替えます |

`window kill`、`pane kill`、`multi-kill window`、`multi-kill pane` にはキーがなく、コマンドラインから実行します。一覧の各行は対象を隠れた先頭列に持つので、`feature/login` という名前のウィンドウや空白を含むセッションも正しく選べます。

プロジェクトファイルには 1 行に 1 つのフォルダを書きます。`*` を含む行は一致するすべてのフォルダを並べ、`~` はホームフォルダを表し、`#` で始まる行は読み飛ばします。セッション名はフォルダ名から付けます。

<a id="画面"></a>

## 画面

<details>
<summary>すべての画面。本物の tmux の中で <code>make screens</code> で録画し、押したキーをステータスラインに表示しています</summary>
<br>

<table>
<tr>
<td width="50%" valign="top"><img src="screens/palette.png" alt="fzf-revamped: prefix M-f でパレットを開く"><br><sub><code>prefix M-f</code> でパレットを開く。<code>hero.tape</code>より</sub></td>
<td width="50%" valign="top"><img src="screens/palette-split.png" alt="fzf-revamped: パレットの split-window -h を実行"><br><sub>パレットの <code>split-window -h</code> を実行。<code>hero.tape</code>より</sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/sessions.png" alt="fzf-revamped: プレビュー付きのセッション切り替え"><br><sub>プレビュー付きのセッション切り替え。<code>hero.tape</code>より</sub></td>
<td width="50%" valign="top"><img src="screens/switched.png" alt="fzf-revamped: 選んだセッションに移ったクライアント"><br><sub>選んだセッションに移ったクライアント。<code>hero.tape</code>より</sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/last.png" alt="fzf-revamped: last キーで前のセッションに戻る"><br><sub>last キーで前のセッションに戻る。<code>hero.tape</code>より</sub></td>
<td width="50%" valign="top"><img src="screens/windows.png" alt="fzf-revamped: ウィンドウ切り替え"><br><sub>ウィンドウ切り替え。<code>stills.tape</code>より</sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/panes.png" alt="fzf-revamped: ペイン切り替え"><br><sub>ペイン切り替え。<code>stills.tape</code>より</sub></td>
<td width="50%" valign="top"><img src="screens/tree.png" alt="fzf-revamped: セッション、ウィンドウ、ペインのツリー"><br><sub>セッション、ウィンドウ、ペインのツリー。<code>stills.tape</code>より</sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/create.png" alt="fzf-revamped: 新しい名前を入力した作成または切り替え"><br><sub>新しい名前を入力した作成または切り替え。<code>stills.tape</code>より</sub></td>
<td width="50%" valign="top"><img src="screens/created.png" alt="fzf-revamped: 新しいセッション"><br><sub>新しいセッション。<code>stills.tape</code>より</sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/urls.png" alt="fzf-revamped: 画面上の URL"><br><sub>画面上の URL。<code>stills.tape</code>より</sub></td>
<td width="50%" valign="top"><img src="screens/cheatsheet.png" alt="fzf-revamped: 1 つのコマンドに絞ったチートシート"><br><sub>1 つのコマンドに絞ったチートシート。<code>stills.tape</code>より</sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/cheatsheet-run.png" alt="fzf-revamped: チートシートから実行したキー割り当て"><br><sub>チートシートから実行したキー割り当て。ペインが分割されています。<code>stills.tape</code>より</sub></td>
<td width="50%" valign="top"><img src="screens/process.png" alt="fzf-revamped: プロセスピッカー"><br><sub>プロセスピッカー。<code>stills.tape</code>より</sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/process-confirm.png" alt="fzf-revamped: シグナルの前の確認"><br><sub>シグナルの前の確認。<code>stills.tape</code>より</sub></td>
<td width="50%" valign="top"><img src="screens/rename.png" alt="fzf-revamped: 名前変更のプロンプト"><br><sub>名前変更のプロンプト。<code>stills.tape</code>より</sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/kill.png" alt="fzf-revamped: セッション終了"><br><sub>セッション終了。<code>stills.tape</code>より</sub></td>
<td width="50%" valign="top"><img src="screens/multikill.png" alt="fzf-revamped: マルチキルで選んだ 2 つのセッション"><br><sub>マルチキルで選んだ 2 つのセッション。<code>stills.tape</code>より</sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/broadcast.png" alt="fzf-revamped: ブロードキャストで選んだ 2 つのペイン"><br><sub>ブロードキャストで選んだ 2 つのペイン。<code>stills.tape</code>より</sub></td>
<td width="50%" valign="top"><img src="screens/zoxide.png" alt="fzf-revamped: zoxide のフォルダー"><br><sub>zoxide のフォルダー。<code>stills.tape</code>より</sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/move.png" alt="fzf-revamped: ウィンドウ移動のプロンプト"><br><sub>ウィンドウ移動のプロンプト。<code>stills.tape</code>より</sub></td>
<td width="50%" valign="top"><img src="screens/arrange.png" alt="fzf-revamped: ペイン整理の操作一覧"><br><sub>ペイン整理の操作一覧。<code>stills.tape</code>より</sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/arrange-layout.png" alt="fzf-revamped: 整理機能でレイアウトを変えたウィンドウ"><br><sub>整理機能でレイアウトを変えたウィンドウ。<code>stills.tape</code>より</sub></td>
<td width="50%" valign="top"><img src="screens/buffers.png" alt="fzf-revamped: tmux バッファの一覧"><br><sub>tmux バッファの一覧。<code>stills.tape</code>より</sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/projects.png" alt="fzf-revamped: プロジェクトのフォルダ。動いているセッションには印が付きます"><br><sub>プロジェクトのフォルダ。動いているセッションには印が付きます。<code>stills.tape</code>より</sub></td>
<td width="50%" valign="top"><img src="screens/menu.png" alt="fzf-revamped: メニュー"><br><sub>メニュー。<code>stills.tape</code>より</sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/doctor.png" alt="fzf-revamped: doctor"><br><sub><code>doctor</code>。<code>stills.tape</code>より</sub></td>
<td width="50%" valign="top"><img src="screens/list.png" alt="fzf-revamped: list"><br><sub><code>list</code>。<code>stills.tape</code>より</sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/json.png" alt="fzf-revamped: list --json"><br><sub><code>list --json</code>。<code>stills.tape</code>より</sub></td>
<td width="50%" valign="top"><img src="screens/plain-menu.png" alt="fzf-revamped: gum なしのメニュー"><br><sub>gum なしのメニュー。<code>stills.tape</code>より</sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/plain-apply.png" alt="fzf-revamped: メニューからの apply"><br><sub>メニューからの <code>apply</code>。<code>stills.tape</code>より</sub></td>
<td width="50%" valign="top"><img src="screens/version.png" alt="fzf-revamped: バージョン"><br><sub>バージョン。<code>stills.tape</code>より</sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/error.png" alt="fzf-revamped: 不明なコマンド"><br><sub>不明なコマンド。<code>stills.tape</code>より</sub></td>
<td width="50%" valign="top"><img src="screens/themes.png" alt="fzf-revamped: 6 つのテーマのヘッダー"><br><sub>6 つのテーマのヘッダー。<code>themes.tape</code>より</sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/help.png" alt="fzf-revamped: ヘルプ"><br><sub>ヘルプ。<code>help.tape</code>より</sub></td>
<td width="50%" valign="top"><img src="screens/accent.png" alt="fzf-revamped: FZF_REVAMPED_ACCENT によるアクセント"><br><sub><code>FZF_REVAMPED_ACCENT</code> によるアクセント。<code>stills.tape</code>より</sub></td>
</tr>
<tr>
<td width="50%" valign="top"></td>
</tr>
</table>

</details>

## 移植性

プラグインは POSIX `sh` です。CI は下の各行ですべてのテストを実行します。

| シェル | 状態 |
|:------|:-------|
| `dash`、macOS の `/bin/sh` | 対応 |
| `bash` 3.2 と 5.x、システムの `zsh` と Homebrew の `zsh` | 対応 |

| システム | 状態 |
|:-------|:-------|
| macOS | Apple Silicon と Intel の Tahoe。付属のツール、Homebrew の GNU ツール、Homebrew の uutils で確認 |
| Linux | x86_64 と arm64 の Ubuntu 26.04。GNU coreutils、uutils、BusyBox で確認 |

## 開発

| コマンド | 実行内容 |
|:--------|:-------------|
| `make fmt` | すべてのスクリプトに shfmt `-i 2` をかけます |
| `make lint` | shfmt、ShellCheck、mandoc、yamllint、actionlint を、指摘ゼロで通します |
| `make test` | システムの `sh` で bats のテスト |
| `make test-all` | インストール済みのすべてのシェルでテスト。macOS では bash と zsh の両方のビルドを含みます |
| `make test-linux` | Ubuntu のコンテナでテスト |
| `make coverage` | この Mac と Ubuntu のコンテナで bashcov を実行し、合算して 100 パーセントで判定します |
| `make screens` | 上の画面を、本物のプラグインから tmux の中で VHS で録画します。macOS で実行します |
| `make install` | コマンド、manページ、補完を `PREFIX` の下に置きます |

macOS では、`brew bundle` を実行すると、これらのターゲットが使うツールがすべて [`Brewfile`](Brewfile) からインストールされます。

コミットは Conventional Commits の形式に従い、そのまま `main` に入ります。`main` で `ci` が成功すると、`release.yml` が semantic-release を実行します。前回のタグ以降に `feat` か `fix` があればリリースを公開し、バージョン定数を更新し、変更内容を [`CHANGELOG.md`](CHANGELOG.md) に追加します。

## ライセンス

[MIT](LICENSE)、copyright Gustavo Franco。

<!-- family:begin -->

## tmux-revamped ファミリー

このプラグインは tmux-revamped ファミリーの一員です。すべてのメンバーが [`FAMILY.md`](FAMILY.md) の同じ規約と同じ共有ライブラリを持ちます。メンバーは一緒にインストールする前提で作られており、ほかのメンバーが使うキーや tmux オプションを使うメンバーはありません。

あるメンバーで見つかった不具合は、修正完了とする前に全メンバーで同じ不具合を探します。

| メンバー | 機能 |
|---|---|
| [`tmux-autoreload-revamped`](https://github.com/tmux-revamped/tmux-autoreload-revamped) | tmuxの設定を編集して保存するだけで、キーもコマンドも使わずに自動で再読み込みされます |
| [`tmux-battery-revamped`](https://github.com/tmux-revamped/tmux-battery-revamped) | tmuxのステータスバーに電池の状態を表示し、ステータスの描画を一切止めません |
| [`tmux-bluetooth-revamped`](https://github.com/tmux-revamped/tmux-bluetooth-revamped) | 接続中のすべてのBluetooth機器とその電池残量をtmuxのステータスバーに表示し、描画を止めません |
| [`tmux-cpu-revamped`](https://github.com/tmux-revamped/tmux-cpu-revamped) | CPUの負荷、温度、周波数をtmuxのステータスバーに表示し、描画を一切止めません |
| [`tmux-disk-revamped`](https://github.com/tmux-revamped/tmux-disk-revamped) | tmuxのステータスバーにディスク使用量を表示し、ステータスの描画を一切止めません |
| [`tmux-extract-revamped`](https://github.com/tmux-revamped/tmux-extract-revamped) | 画面上の URL、パス、ハッシュなどのトークンを fzf で選び、カーソル位置に入力します。純粋なシェルだけで動きます |
| [`tmux-fzf-revamped`](https://github.com/tmux-revamped/tmux-fzf-revamped) | **このプラグイン**、ポップアップ内の fzf ピッカーから、tmux のセッション、ウィンドウ、ペインの切り替え、終了、名前変更、作成を行います |
| [`tmux-git-revamped`](https://github.com/tmux-revamped/tmux-git-revamped) | アクティブなペインのgitブランチ、変更、プロバイダーの件数を、描画を止めずにtmuxのステータスバーに表示します |
| [`tmux-gpu-revamped`](https://github.com/tmux-revamped/tmux-gpu-revamped) | NVIDIA、AMD、Intel、Apple の GPU の負荷、温度、クロック、電力、メモリを tmux のステータスバーに表示します |
| [`tmux-kube-revamped`](https://github.com/tmux-revamped/tmux-kube-revamped) | 現在の Kubernetes コンテキストと名前空間を、kubectl を使わずに kubeconfig から解析して tmux のステータスバーに表示します |
| [`tmux-launcher-revamped`](https://github.com/tmux-revamped/tmux-launcher-revamped) | 任意の TUI アプリを、現在のペインのディレクトリでポップアップまたはウィンドウとして起動します。アプリごとにキーを設定できます |
| [`tmux-logging-revamped`](https://github.com/tmux-revamped/tmux-logging-revamped) | 任意のペインをファイルに保存します。ライブのログ記録、スクロールバック全体、1 回限りのスクリーンショットに対応します |
| [`tmux-music-revamped`](https://github.com/tmux-revamped/tmux-music-revamped) | 再生中の曲をステータスバーに表示し、ステータスの描画を止めません |
| [`tmux-network-revamped`](https://github.com/tmux-revamped/tmux-network-revamped) | ネットワークのスループットをステータスバーに表示し、描画を止めません |
| [`tmux-pain-control-revamped`](https://github.com/tmux-revamped/tmux-pain-control-revamped) | tmux のペインとウィンドウの操作キー。tmux のバージョンに対応し、vim と共存でき、どの prefix キーも無効にできます |
| [`tmux-persist-revamped`](https://github.com/tmux-revamped/tmux-persist-revamped) | tmuxのすべてのセッション、ウィンドウ、ペインを保存し、タイマーで自動保存して、再起動後にすべて復元します |
| [`tmux-plugin-template`](https://github.com/tmux-revamped/tmux-plugin-template) | tmux-revampedプラグインの出発点です。共有ライブラリ、batsハーネス、CIを含みます |
| [`tmux-pomodoro-revamped`](https://github.com/tmux-revamped/tmux-pomodoro-revamped) | すべての状態をtmuxオプションに保持し、一時ファイルを使わない、tmuxステータスバーのポモドーロタイマーです |
| [`tmux-ram-revamped`](https://github.com/tmux-revamped/tmux-ram-revamped) | RAM、スワップ、メモリプレッシャーをtmuxのステータスバーに表示します。計測はバックグラウンドで行うため描画を待たせません |
| [`tmux-reorder-revamped`](https://github.com/tmux-revamped/tmux-reorder-revamped) | tmuxのステータスバー上でウィンドウのタブをマウスでドラッグして、そのウィンドウを移動します |
| [`tmux-scroll-revamped`](https://github.com/tmux-revamped/tmux-scroll-revamped) | 自分でスクロールできるアプリにはマウスホイールを渡し、それ以外ではtmuxのコピーモードに入ります |
| [`tmux-sensible-revamped`](https://github.com/tmux-revamped/tmux-sensible-revamped) | tmuxのバージョンと端末に合わせて適用され、ユーザーが設定したオプションには触れない、妥当な初期設定です |
| [`tmux-tiling-revamped`](https://github.com/tmux-revamped/tmux-tiling-revamped) | tmuxのタイル型ウィンドウ管理です。BSPのdwindleとspiralを含む8つのレイアウトと、レイアウトの取り消しがあります |
| [`tmux-time-revamped`](https://github.com/tmux-revamped/tmux-time-revamped) | ステータスバーにローカル時計と世界時計を時間帯ごとの色で表示し、カウントダウンと夏時間の警告も出します |
| [`tmux-weather-revamped`](https://github.com/tmux-revamped/tmux-weather-revamped) | wttr.inの天気をバックグラウンドで取得し、ステータスバーを待たせずに表示します |

<!-- family:end -->
