-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua

-- Omarchy (omarchy-nvim) と同じ既定値
vim.opt.relativenumber = false
vim.g.autoformat = false

-- 検索がファイル末尾で折り返さない
vim.opt.wrapscan = false

-- PowerShell はワイルドカードを展開せず nvim に文字列のまま渡すため、
-- `nvim *.dmp` が "*.dmp" という名前のファイルを開こうとして E303 になる。起動時に展開し直す
if vim.fn.has("win32") == 1 then
  local args, changed = {}, false
  for _, arg in ipairs(vim.fn.argv()) do
    local matches = arg:find("[*?]") and not vim.uv.fs_stat(arg) and vim.fn.glob(arg, false, true) or {}
    if #matches > 0 then
      changed = true
      vim.list_extend(args, matches)
    else
      table.insert(args, arg)
    end
  end
  if changed then
    vim.cmd("args " .. table.concat(vim.tbl_map(vim.fn.fnameescape, args), " "))
  end
end

-- docker 版だけ上書きコピーされる設定 (docker/nvim/lua/config/docker.lua) があれば読む
if vim.uv.fs_stat(vim.fn.stdpath("config") .. "/lua/config/docker.lua") then
  require("config.docker")
end
