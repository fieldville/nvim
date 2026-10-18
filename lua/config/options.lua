-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua

-- Omarchy (omarchy-nvim) と同じ既定値
vim.opt.relativenumber = false
vim.g.autoformat = false

-- docker 版だけ上書きコピーされる設定 (docker/nvim/lua/config/docker.lua) があれば読む
if vim.uv.fs_stat(vim.fn.stdpath("config") .. "/lua/config/docker.lua") then
  require("config.docker")
end
