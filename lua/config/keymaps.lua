-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Toggle zoom of the current window like tmux `prefix + z`
-- (opens it in a new tab, so the original split layout is kept)
vim.keymap.set("n", "<leader>z", function()
  if vim.t.zoomed and vim.fn.tabpagenr("$") > 1 then
    vim.cmd("tabclose")
  else
    vim.cmd("tab split")
    vim.t.zoomed = true
  end
end, { desc = "Toggle Zoom (tab)" })
