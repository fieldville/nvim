# nvim

LazyVim ベースの Neovim 設定。[Omarchy](https://omarchy.org/) 標準の Neovim ([omarchy-nvim](https://github.com/omacom/omarchy-pkgs/tree/master/pkgbuilds/omarchy-nvim)) を基準にし、カスタマイズは最小限にとどめる。

## 方針

- [LazyVim starter](https://github.com/LazyVim/starter) をそのまま使い、デフォルトから変えない
- Omarchy が LazyVim に加えている設定のうち、デスクトップ非依存のものだけ取り込む
- host 版 (デフォルト) と docker 版 (緊急用) を同じ設定から作る。docker 固有のコードは `docker/` に隔離する

## 構成

```
.                      # = ~/.config/nvim (Windows は %LOCALAPPDATA%\nvim)。LazyVim starter の構成そのまま
├── init.lua
├── lazyvim.json       # extras: neo-tree (Omarchy と同じ)
├── lua/config/        # options.lua: relativenumber off, autoformat off (Omarchy と同じ), nowrapscan, Windows でワイルドカード引数を展開
├── lua/plugins/       # omarchy.lua: NEWS 通知 off, スクロールアニメーション off / dashboard.lua: 起動画面 off / notifier.lua: 通知の表示時間 10 秒 / no-nerd-font.lua: Nerd Font なしのマシン用のアイコン置き換え (環境変数で有効化) / vscode.lua: VSCode (vscode-neovim) 内で止まるプラグインのキーを VSCode の機能に割り当て (VSCode 内でだけ有効)
├── setup              # host 版セットアップ
└── docker/            # docker 版
    ├── Dockerfile
    ├── lvim           # コンテナで nvim を起動するランチャー
    ├── alias.sh       # lvim-build とクリップボード中継 (.bashrc から source)
    ├── setup          # docker 版セットアップ
    └── nvim/          # docker 版だけ上書きコピーされる設定 (lua/config/docker.lua: ホストのクリップボード連携)
```

## セットアップ

リポジトリは public。clone の URL は 2 通りあり、以下の手順では SSH を使っている。

- SSH: `git@github.com:fieldville/nvim.git` — push する自分のマシン向け。GitHub に SSH 鍵の登録が必要
- HTTPS: `https://github.com/fieldville/nvim.git` — 社用マシンなど鍵を登録しないマシン向け。clone と pull は認証なしでできる (push は不可)

### host 版 (デフォルト)

Neovim 0.12 以上が必要。`setup` は Neovim 自体はインストールしない。0.11 以下だと LazyVim が nvim-treesitter を古いコミットに固定するため、`lazy-lock.json` がマシン間で食い違う (apt の Neovim は古いことが多いので、[GitHub Releases](https://github.com/neovim/neovim/releases/latest) のものを使う)。

```sh
git clone git@github.com:fieldville/nvim.git ~/.fieldville/nvim   # HTTPS なら https://github.com/fieldville/nvim.git
~/.fieldville/nvim/setup
```

`~/.config/nvim` をこのリポジトリへのシンボリックリンクにし、プラグインを同期する。既存の `~/.config/nvim` は `.backup.<日時>` に退避される。

### docker 版 (緊急用)

```sh
~/.fieldville/nvim/docker/setup      # ~/.local/bin/lvim を作り、イメージをビルド
lvim [file...]                       # コンテナで起動
```

`.bashrc` に以下を足すと、`lvim-build` 関数とホストのクリップボード中継 (socat) が使えるようになる。ホストに `socat` が必要 (`sudo apt install socat` / `brew install socat`)。入っていないと中継が黙って起動せず、コンテナ内で `clipboard: error invoking nc` になる。

```sh
[ -f ~/.fieldville/nvim/docker/alias.sh ] && . ~/.fieldville/nvim/docker/alias.sh
```

設定を変えたら `lvim-build` でイメージを作り直す。

### Windows 版

Windows では `~/.config/nvim` の代わりに `%LOCALAPPDATA%\nvim` が設定ディレクトリになる。`setup` は bash スクリプトなので使わず、PowerShell で同じこと (clone → リンク → `Lazy! sync`) を手で行う。管理者権限は不要。

1. ツールを入れる ([scoop](https://scoop.sh/))。`git` を先に入れると bucket が使えるようになる

   ```powershell
   scoop install git
   scoop install neovim ripgrep fd fzf lazygit gcc make tree-sitter
   scoop bucket add nerd-fonts
   scoop install CascadiaMono-NF      # アイコン表示用。ターミナルのフォントに設定する
   ```

2. GitHub に SSH 鍵を登録する (SSH で clone するマシンのみ。HTTPS なら不要)

   ```powershell
   ssh-keygen -t ed25519                              # 鍵がなければ作る
   Get-Content ~\.ssh\id_ed25519.pub | Set-Clipboard  # GitHub > Settings > SSH and GPG keys に貼る
   ssh -T git@github.com                              # 認証確認
   ```

3. clone して `%LOCALAPPDATA%\nvim` をリポジトリに向ける

   ```powershell
   git clone git@github.com:fieldville/nvim.git $env:USERPROFILE\.fieldville\nvim   # HTTPS なら https://github.com/fieldville/nvim.git

   $target = "$env:LOCALAPPDATA\nvim"
   if (Test-Path $target) { Rename-Item $target "nvim.backup.$(Get-Date -Format yyyyMMdd-HHmmss)" }
   New-Item -ItemType Junction -Path $target -Target "$env:USERPROFILE\.fieldville\nvim"
   ```

   シンボリックリンクではなくジャンクションにしているのは、管理者権限や開発者モードなしで作れるため。`nvim` から見た挙動は同じ。

4. プラグインを同期する

   ```powershell
   nvim --headless "+Lazy! sync" +qa
   ```

補足:

- プラグインや Mason のバイナリは `%LOCALAPPDATA%\nvim-data` に入る。リポジトリには含まれない
- 更新は `git -C $env:USERPROFILE\.fieldville\nvim pull` のあと `nvim` 内で `:Lazy sync`
- 改行コードは `.gitattributes` で LF に固定してあるので、Git for Windows の `core.autocrlf` の設定によらず LF でチェックアウトされる
- PowerShell はワイルドカードを展開しないので、`nvim *.dmp` は `lua/config/options.lua` で起動時に展開している (しないと E303 で開けない)
- docker 版 (`lvim`) は Linux / WSL 用。Windows 版にはない

### Nerd Font を入れられないマシン

LazyVim のアイコンは Nerd Font 前提で、入っていないターミナルでは豆腐 (□ や ?) になる。社用マシンなどフォントを持ち込めない環境では、環境変数 `NVIM_NO_NERD_FONT` を設定する。`lua/plugins/no-nerd-font.lua` が効いて、アイコンが標準フォントで出る文字 (`E` `W` `+` `-` `>` など) に置き換わる。未設定のマシンでは何も変わらない。

```sh
export NVIM_NO_NERD_FONT=1     # そのマシンだけの設定 (~/.profile.private など) に書く
```

- Windows は `setx NVIM_NO_NERD_FONT 1` (新しく開いたターミナルから有効)。この場合「Windows 版」手順の `CascadiaMono-NF` は入れなくてよい
- docker 版は `lvim` がホストの値をコンテナに渡す
- 置き換わらないのは 2 か所だけ: 差分プレビュー (`<leader>gs` など) の見出しの印と、undo 一覧 (`<leader>su`) の現在位置の印。snacks.nvim に直書きされていて設定では変えられない
- LazyVim やプラグインの更新でアイコンが増えると、新しい豆腐が出ることがある。そのときは `no-nerd-font.lua` に足す

### VSCode (vscode-neovim) の中で使う

VSCode の拡張 [vscode-neovim](https://github.com/vscode-neovim/vscode-neovim) は `~/.config/nvim` をそのまま読むので、この設定が VSCode の中でも動く。ただし VSCode 内では LazyVim が UI 系プラグイン (neo-tree, picker, LSP, gitsigns, trouble など) を止めるため、`<leader>e` や `<leader>ff` などは押しても何も起きなくなる。`lua/plugins/vscode.lua` が同じキーを VSCode 側の相当機能に割り当て直している。ターミナルの `nvim` では何もしない。

- 割り当ての一覧は `lua/plugins/vscode.lua` の `maps` を見る (エクスプローラー、ファイルを開く、検索、タブ、LSP、診断、git、表示切り替え)
- `<leader>sw` / `<leader>sW` はカーソル下の単語をプロジェクト内検索の検索欄に入れて開く。文字列を選択しているとき (マウスでの選択も含む) は選択した文字列で検索する
- `]q` / `[q` はプロジェクト内検索の次 / 前の結果へ移動する (VSCode の `F4` / `Shift+F4` と同じ)。エディタにフォーカスがあるときだけ効くので、`<leader>sw` の直後 (検索欄にフォーカスがある) は `F4` で 1 件目に移動し、そのあと `]q` / `[q` でたどる。移動先では一致箇所が選択された状態になる
- ビジュアルモードでも使うキーは、ビジュアルモードにも割り当てる。ノーマルモードだけだと、選択中は LazyVim の picker 用の割り当てが残り、何も起きない
- 挿入モードのキーと VSCode 本体の設定 (カッコの自動補完 off など) は Neovim からは変えられない。dotfiles の `vscode/keybindings.json` と `vscode/settings.json` に書いてある
- `vscode.lua` を変えたら、VSCode のコマンドパレットで「Neovim: Restart」を実行すると反映される

## 運用

- **設定を変える**: `lua/config/options.lua` と `lua/plugins/` だけを編集してコミットする。それ以外のファイルは LazyVim starter のままにしておく
- **docker 版に反映**: 設定を変えたら `lvim-build` でイメージを作り直す。起動は `lvim [file...]`
- **別マシンで再現**: `git clone git@github.com:fieldville/nvim.git ~/.fieldville/nvim && ~/.fieldville/nvim/setup`。Windows は上記「Windows 版」の手順
- **Omarchy への追従**: [omarchy-nvim](https://github.com/omacom/omarchy-pkgs/tree/master/pkgbuilds/omarchy-nvim) が変わったら、取り込んでいる 5 点 (neo-tree, relativenumber, autoformat, news, scroll) との差分だけ見て合わせる。テーマ切替や透過などデスクトップ依存のものは取り込まない
- **追加の判断基準**: LazyVim か Omarchy のデフォルトで済むなら設定を書かない。どうしても必要なものだけ、なぜ必要かをコメントで残して足す
- **ダッシュボードを見る**: 起動時の表示は `lua/plugins/dashboard.lua` で切ってあるが、機能は残っている。見たいときは `nvim` 内で `:lua Snacks.dashboard()`
