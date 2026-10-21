-- 右上の通知 (snacks.nvim notifier) の表示時間を延ばす
-- デフォルトの 3 秒では読み切る前に消えてしまうため
return {
  { "folke/snacks.nvim", opts = { notifier = { timeout = 10000 } } },
}
