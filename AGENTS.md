# AGENTS.md

README.md の「方針」と「運用」に従うこと。特に:

- カスタマイズは最小限。LazyVim / Omarchy のデフォルトで済むなら設定を書かない
- 編集してよいのは `lua/config/options.lua`、`lua/plugins/`、`docker/` 配下だけ。starter 由来のファイルは変えない
- docker 固有のコードは `docker/` に置き、共通設定には混ぜない
