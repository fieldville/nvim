-- Omarchy (omarchy-nvim) が LazyVim に加えている設定のうち、デスクトップ非依存のもの
-- https://github.com/omacom/omarchy-pkgs/tree/master/pkgbuilds/omarchy-nvim
return {
  -- LazyVim / Neovim の NEWS ポップアップを出さない
  { "LazyVim/LazyVim", opts = { news = { lazyvim = false, neovim = false } } },
  -- スクロールアニメーションを切る
  { "folke/snacks.nvim", opts = { scroll = { enabled = false } } },
}
