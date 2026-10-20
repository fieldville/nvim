-- 起動時のダッシュボード (LazyVim ロゴ画面) を出さない
-- Grep → Quickfix からファイルを開く流れでダッシュボードのウィンドウが残って邪魔になるため
return {
  { "folke/snacks.nvim", opts = { dashboard = { enabled = false } } },
}
