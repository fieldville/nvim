# nvim

LazyVim ベースの Neovim 設定。[Omarchy](https://omarchy.org/) 標準の Neovim ([omarchy-nvim](https://github.com/omacom/omarchy-pkgs/tree/master/pkgbuilds/omarchy-nvim)) を基準にし、カスタマイズは最小限にとどめる。

## 方針

- [LazyVim starter](https://github.com/LazyVim/starter) をそのまま使い、デフォルトから変えない
- Omarchy が LazyVim に加えている設定のうち、デスクトップ非依存のものだけ取り込む
- host 版 (デフォルト) と docker 版 (緊急用) を同じ設定から作る。docker 固有のコードは `docker/` に隔離する

## 構成

```
.                      # = ~/.config/nvim (LazyVim starter の構成そのまま)
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
