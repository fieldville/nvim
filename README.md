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
├── lua/config/        # options.lua: relativenumber off, autoformat off (Omarchy と同じ)
├── lua/plugins/       # omarchy.lua: NEWS 通知 off, スクロールアニメーション off
├── setup              # host 版セットアップ
└── docker/            # docker 版
    ├── Dockerfile
    ├── lvim           # コンテナで nvim を起動するランチャー
    ├── alias.sh       # lvim-build とクリップボード中継 (.bashrc から source)
    ├── setup          # docker 版セットアップ
    └── nvim/          # docker 版だけ上書きコピーされる設定 (lua/config/docker.lua: ホストのクリップボード連携)
```

## セットアップ

### host 版 (デフォルト)

```sh
git clone git@github.com:fieldville/nvim.git ~/.fieldville/nvim
~/.fieldville/nvim/setup
```

`~/.config/nvim` をこのリポジトリへのシンボリックリンクにし、プラグインを同期する。既存の `~/.config/nvim` は `.backup.<日時>` に退避される。

### docker 版 (緊急用)

```sh
~/.fieldville/nvim/docker/setup      # ~/.local/bin/lvim を作り、イメージをビルド
lvim [file...]                       # コンテナで起動
```

`.bashrc` に以下を足すと、`lvim-build` 関数とホストのクリップボード中継 (socat) が使えるようになる。

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

2. GitHub に SSH 鍵を登録する (未登録のマシンのみ)

   ```powershell
   ssh-keygen -t ed25519                              # 鍵がなければ作る
   Get-Content ~\.ssh\id_ed25519.pub | Set-Clipboard  # GitHub > Settings > SSH and GPG keys に貼る
   ssh -T git@github.com                              # 認証確認
   ```

3. clone して `%LOCALAPPDATA%\nvim` をリポジトリに向ける

   ```powershell
   git clone git@github.com:fieldville/nvim.git $env:USERPROFILE\.fieldville\nvim

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
- docker 版 (`lvim`) は Linux / WSL 用。Windows 版にはない

## 運用

- **設定を変える**: `lua/config/options.lua` と `lua/plugins/` だけを編集してコミットする。それ以外のファイルは LazyVim starter のままにしておく
- **docker 版に反映**: 設定を変えたら `lvim-build` でイメージを作り直す。起動は `lvim [file...]`
- **別マシンで再現**: `git clone git@github.com:fieldville/nvim.git ~/.fieldville/nvim && ~/.fieldville/nvim/setup`。Windows は上記「Windows 版」の手順
- **Omarchy への追従**: [omarchy-nvim](https://github.com/omacom/omarchy-pkgs/tree/master/pkgbuilds/omarchy-nvim) が変わったら、取り込んでいる 5 点 (neo-tree, relativenumber, autoformat, news, scroll) との差分だけ見て合わせる。テーマ切替や透過などデスクトップ依存のものは取り込まない
- **追加の判断基準**: LazyVim か Omarchy のデフォルトで済むなら設定を書かない。どうしても必要なものだけ、なぜ必要かをコメントで残して足す
