-- VSCode (vscode-neovim 拡張) の中で動くときだけ効く設定。ターミナルの nvim では何もしない。
-- LazyVim は VSCode 内だと自前の extra (lazyvim.plugins.extras.vscode) を自動で読み、UI 系プラグイン
-- (neo-tree, picker, gitsigns, LSP, trouble, lualine など) を止める。その結果 <leader>e や <leader>ff などの
-- キーが何も起きなくなるので、同じキーを VSCode 側の相当機能に割り当て直して手癖をそのまま使えるようにする。
-- extra が既に割り当てているキー (<leader><space>, <leader>/, <leader>ss, <leader>ft, <C-/>, H, L) と、
-- vscode-neovim が既に割り当てているキー (gd, gD, K, <C-w> 系, gt/gT) はここには書かない。
-- 挿入モードのキーと VSCode 本体の設定 (自動カッコ補完 off など) は Neovim からは変えられないので、
-- dotfiles の vscode/keybindings.json と vscode/settings.json に書いてある。
if not vim.g.vscode then
  return {}
end

local vscode = require("vscode")

-- { モード, キー, VSCode のコマンド ID, 元の LazyVim での機能 }
local maps = {
  -- ファイルツリー (neo-tree)
  { "n", "<leader>e", "workbench.view.explorer", "Explorer" },
  { "n", "<leader>E", "workbench.view.explorer", "Explorer" },
  { "n", "<leader>fe", "workbench.view.explorer", "Explorer" },
  { "n", "<leader>fE", "workbench.view.explorer", "Explorer" },
  { "n", "<leader>be", "workbench.files.action.focusOpenEditorsView", "Buffer Explorer" },
  { "n", "<leader>ge", "workbench.view.scm", "Git Explorer" },

  -- ファイルを開く (picker)
  { "n", "<leader>ff", "workbench.action.quickOpen", "Find Files" },
  { "n", "<leader>fF", "workbench.action.quickOpen", "Find Files" },
  { "n", "<leader>fg", "workbench.action.quickOpen", "Find Files (git)" },
  { "n", "<leader>fr", "workbench.action.quickOpen", "Recent" }, -- 何も打たなければ最近開いた順に並ぶ
  { "n", "<leader>fR", "workbench.action.quickOpen", "Recent" },
  { "n", "<leader>fb", "workbench.action.showAllEditors", "Buffers" },
  { "n", "<leader>,", "workbench.action.showAllEditors", "Buffers" },
  { "n", "<leader>fp", "workbench.action.openRecent", "Projects" },
  { "n", "<leader>fc", "workbench.action.openSettingsJson", "Config File" },

  -- 検索 (picker, grug-far)
  { "n", "<leader>sg", "workbench.action.findInFiles", "Grep" },
  { "n", "<leader>sG", "workbench.action.findInFiles", "Grep" },
  { "n", "<leader>sr", "workbench.action.replaceInFiles", "Search and Replace" },
  { "n", "<leader>sb", "actions.find", "Buffer Lines" },
  { "n", "<leader>sS", "workbench.action.showAllSymbols", "Workspace Symbols" },
  { "n", "<leader>sd", "workbench.actions.view.problems", "Diagnostics" },
  { "n", "<leader>sD", "workbench.actions.view.problems", "Diagnostics" },
  { "n", "<leader>sk", "workbench.action.openGlobalKeybindings", "Keymaps" },
  { "n", "<leader>sC", "workbench.action.showCommands", "Commands" },
  { "n", "<leader>sc", "workbench.action.showCommands", "Command History" },
  { "n", "<leader>:", "workbench.action.showCommands", "Command History" },
  { "n", "<leader>su", "timeline.focus", "Undo History" }, -- ファイルごとの保存履歴 (タイムライン)

  -- バッファ = VSCode のエディタタブ
  { "n", "<leader>bd", "workbench.action.closeActiveEditor", "Delete Buffer" },
  { "n", "<leader>bD", "workbench.action.closeActiveEditor", "Delete Buffer and Window" },
  { "n", "<leader>bo", "workbench.action.closeOtherEditors", "Delete Other Buffers" },
  { "n", "<leader>br", "workbench.action.closeEditorsToTheRight", "Delete Buffers to the Right" },
  { "n", "<leader>bl", "workbench.action.closeEditorsToTheLeft", "Delete Buffers to the Left" },
  { "n", "<leader>bp", "workbench.action.pinEditor", "Pin Buffer" },
  { "n", "[b", "workbench.action.previousEditor", "Prev Buffer" },
  { "n", "]b", "workbench.action.nextEditor", "Next Buffer" },

  -- LSP
  { "n", "gr", "editor.action.goToReferences", "References" },
  { "n", "gI", "editor.action.goToImplementation", "Goto Implementation" },
  { "n", "gy", "editor.action.goToTypeDefinition", "Goto Type Definition" },
  { "n", "gK", "editor.action.triggerParameterHints", "Signature Help" },
  { { "n", "x" }, "<leader>ca", "editor.action.quickFix", "Code Action" },
  { "n", "<leader>cA", "editor.action.sourceAction", "Source Action" },
  { "n", "<leader>cr", "editor.action.rename", "Rename" },
  { "n", "<leader>cR", "renameFile", "Rename File" },
  { "n", "<leader>cf", "editor.action.formatDocument", "Format" },
  { "x", "<leader>cf", "editor.action.formatSelection", "Format" },
  { "n", "<leader>cd", "editor.action.showHover", "Line Diagnostics" }, -- ホバーに診断も出る
  { "n", "<leader>cs", "outline.focus", "Symbols (Trouble)" },

  -- 診断 (trouble)。VSCode には重大度ごとの移動がないので ]e / ]w も「次の問題」になる
  { "n", "]d", "editor.action.marker.next", "Next Diagnostic" },
  { "n", "[d", "editor.action.marker.prev", "Prev Diagnostic" },
  { "n", "]e", "editor.action.marker.next", "Next Error" },
  { "n", "[e", "editor.action.marker.prev", "Prev Error" },
  { "n", "]w", "editor.action.marker.next", "Next Warning" },
  { "n", "[w", "editor.action.marker.prev", "Prev Warning" },
  { "n", "<leader>xx", "workbench.actions.view.problems", "Diagnostics (Trouble)" },
  { "n", "<leader>xX", "workbench.actions.view.problems", "Buffer Diagnostics (Trouble)" },

  -- git (lazygit, gitsigns)。lazygit の代わりにソース管理ビューを開く
  { "n", "<leader>gg", "workbench.view.scm", "Lazygit" },
  { "n", "<leader>gG", "workbench.view.scm", "Lazygit" },
  { "n", "<leader>gs", "workbench.view.scm", "Git Status" },
  { "n", "<leader>gd", "git.openChange", "Git Diff" },
  { "n", "<leader>gb", "git.blame.toggleEditorDecoration", "Git Blame Line" },
  { "n", "]h", "workbench.action.editor.nextChange", "Next Hunk" },
  { "n", "[h", "workbench.action.editor.previousChange", "Prev Hunk" },
  { { "n", "x" }, "<leader>ghs", "git.stageSelectedRanges", "Stage Hunk" },
  { { "n", "x" }, "<leader>ghr", "git.revertSelectedRanges", "Reset Hunk" },
  { "n", "<leader>ghu", "git.unstageSelectedRanges", "Undo Stage Hunk" },
  { "n", "<leader>ghS", "git.stage", "Stage Buffer" },
  { "n", "<leader>ghR", "git.clean", "Reset Buffer" },
  { "n", "<leader>ghp", "editor.action.dirtydiff.next", "Preview Hunk Inline" },
  { "n", "<leader>ghb", "git.blame.toggleEditorDecoration", "Blame Line" },
  { "n", "<leader>ghd", "git.openChange", "Diff This" },

  -- 表示の切り替え。折り返しやズームは VSCode 側の持ち物なので VSCode のコマンドで切り替える
  { "n", "<leader>uw", "editor.action.toggleWordWrap", "Toggle Wrap" },
  { "n", "<leader>uz", "workbench.action.toggleZenMode", "Toggle Zen Mode" },
  { "n", "<leader>uZ", "workbench.action.toggleMaximizeEditorGroup", "Toggle Zoom" },
  { "n", "<leader>wm", "workbench.action.toggleMaximizeEditorGroup", "Toggle Zoom" },
  { "n", "<leader>z", "workbench.action.toggleMaximizeEditorGroup", "Toggle Zoom" }, -- config/keymaps.lua の tmux 風ズーム
  { "n", "<leader>uC", "workbench.action.selectTheme", "Colorschemes" },
  { "n", "<leader>un", "notifications.clearAll", "Dismiss All Notifications" },
  { "n", "<leader>n", "notifications.showList", "Notification History" },

  -- その他
  { "n", "<leader>qq", "workbench.action.closeWindow", "Quit All" },
}

-- config/keymaps.lua (<leader>z) より後に上書きしたいので、キーマップを読み終えた合図 (LazyVimKeymaps) を待つ
vim.api.nvim_create_autocmd("User", {
  pattern = "LazyVimKeymaps",
  callback = function()
    for _, m in ipairs(maps) do
      vim.keymap.set(m[1], m[2], function()
        vscode.action(m[3])
      end, { desc = m[4] })
    end

    -- カーソル下の単語を検索欄に入れてプロジェクト内検索 (Grep word)
    vim.keymap.set("n", "<leader>sw", function()
      vscode.action("workbench.action.findInFiles", { args = { { query = vim.fn.expand("<cword>") } } })
    end, { desc = "Grep Word" })
    vim.keymap.set("n", "<leader>sW", function()
      vscode.action("workbench.action.findInFiles", { args = { { query = vim.fn.expand("<cword>") } } })
    end, { desc = "Grep Word" })
  end,
})

return {}
