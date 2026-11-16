-- Nerd Font を入れられないマシン用: アイコンを標準フォントで出る文字に置き換える
-- 社用マシンなどフォントを持ち込めない環境では、アイコンが豆腐 (□ や ?) になって読めないため。
-- 環境変数 NVIM_NO_NERD_FONT が空でないときだけ効く。未設定のマシンでは何もしない (LazyVim のデフォルトのまま)。
-- LazyVim には一括の切り替えがなく、アイコンを持つプラグインごとに指定するしかないので 1 ファイルにまとめている。
-- 残るのは snacks.nvim に直書きされていて設定で変えられない 2 か所だけ:
-- 差分プレビュー (<leader>gs など) の見出しの印と、undo 一覧 (<leader>su) の現在位置の印
if (vim.env.NVIM_NO_NERD_FONT or "") == "" then
  return {}
end

-- 折りたたみの印。LazyVim の options.lua が Nerd Font のグリフを入れている
vim.opt.fillchars:append({ foldopen = "v", foldclose = ">" })

-- :Lazy の画面。lazy.nvim の設定は starter 由来の lua/config/lazy.lua にあり、そちらは変えない方針なのでここで差し替える。
-- 値は lazy.nvim の README が Nerd Font なしの場合として挙げているもの
local lazy_icons = require("lazy.core.config").options.ui.icons
for name, icon in pairs({
  cmd = "⌘",
  config = "🛠",
  event = "📅",
  favorite = "* ",
  ft = "📂",
  import = "import ",
  init = "⚙",
  keys = "🗝",
  lazy = "💤 ",
  plugin = "🔌",
  runtime = "💻",
  require = "🌙",
  source = "📄",
  start = "🚀",
  task = "📌",
}) do
  lazy_icons[name] = icon
end

-- 補完候補やシンボルの種別 (Function, Variable, ...)。アイコンの代わりに名前の先頭 3 文字
local kinds = {}
for kind in pairs(LazyVim.config.icons.kinds) do
  kinds[kind] = kind:sub(1, 3) .. " "
end
local diagnostics = { Error = "E ", Warn = "W ", Hint = "H ", Info = "I " }

return {
  -- ファイル種別のアイコン: グリフの代わりに頭文字 1 文字 (neo-tree, バッファ一覧, ピッカーが使う)
  { "nvim-mini/mini.icons", opts = { style = "ascii" } },

  -- LazyVim が各プラグインに配っている表 (診断の印, git 差分, 補完候補の種別)
  {
    "LazyVim/LazyVim",
    opts = {
      icons = {
        misc = { dots = "…" },
        diagnostics = diagnostics,
        git = { added = "+", modified = "~", removed = "-" },
        kinds = kinds,
      },
    },
  },

  -- ステータスライン
  {
    "nvim-lualine/lualine.nvim",
    opts = function(_, opts)
      opts.options.icons_enabled = false -- ブランチとファイル種別のアイコン
      opts.options.section_separators = ""
      opts.options.component_separators = "|"
      -- 以下は LazyVim がグリフを直書きしている部品。同じ部品をグリフなしで作り直す
      opts.sections.lualine_c[1] = LazyVim.lualine.root_dir({ icon = "root:" })
      opts.sections.lualine_c[4] = { LazyVim.lualine.pretty_path({ readonly_icon = " [RO] " }) }
      opts.sections.lualine_z = {
        function()
          return os.date("%R")
        end,
      }
    end,
  },

  -- バッファのタブ行
  {
    "akinsho/bufferline.nvim",
    opts = {
      options = { buffer_close_icon = "x", close_icon = "x", left_trunc_marker = "<", right_trunc_marker = ">" },
    },
  },

  -- 行削除の印 (gitsigns 本来のデフォルトに戻す)
  {
    "lewis6991/gitsigns.nvim",
    opts = {
      signs = { delete = { text = "▁" }, topdelete = { text = "▔" } },
      signs_staged = { delete = { text = "▁" }, topdelete = { text = "▔" } },
    },
  },

  -- コマンドラインとメッセージ
  {
    "folke/noice.nvim",
    opts = {
      cmdline = {
        format = {
          cmdline = { icon = ">" },
          search_down = { icon = "/" },
          search_up = { icon = "?" },
          lua = { icon = "lua" },
          help = { icon = "help" },
          calculator = { icon = "=" },
          input = { icon = ">" },
        },
      },
      format = { level = { icons = { error = "E", warn = "W", info = "I" } } },
      popupmenu = { kind_icons = false },
    },
  },

  -- 通知, 入力欄, ピッカー
  {
    "folke/snacks.nvim",
    opts = {
      notifier = { icons = { error = "E ", warn = "W ", info = "I ", debug = "D ", trace = "T " } },
      input = { icon = ">" },
      picker = {
        prompt = "> ",
        icons = {
          files = { dir = "+ ", dir_open = "- ", file = "  " },
          keymaps = { nowait = "! " },
          undo = { saved = "* " },
          ui = { live = "~ " },
          git = { commit = "", added = "A", deleted = "D", ignored = "!", renamed = "R", unmerged = "U" },
          diagnostics = diagnostics,
          lsp = { unavailable = "x", enabled = "on ", disabled = "off ", attached = "* " },
          kinds = kinds,
        },
      },
    },
  },

  -- 起動画面 (:lua Snacks.dashboard()) のメニュー。LazyVim が並べた項目からアイコンだけ外す
  {
    "folke/snacks.nvim",
    opts = function(_, opts)
      for _, key in ipairs(vim.tbl_get(opts, "dashboard", "preset", "keys") or {}) do
        key.icon = ""
      end
    end,
  },

  -- キー案内。対応表ごとのアイコンを出さず、キー名は文字で書く (kickstart.nvim の Nerd Font なし設定と同じ)
  {
    "folke/which-key.nvim",
    opts = function(_, opts)
      local keys = {}
      for _, key in ipairs(vim.split("Up Down Left Right CR Esc ScrollWheelDown ScrollWheelUp NL BS Space Tab", " ")) do
        keys[key] = "<" .. key .. "> "
      end
      for _, mod in ipairs({ "C", "M", "D", "S" }) do
        keys[mod] = "<" .. mod .. "-…> "
      end
      for n = 1, 12 do
        keys["F" .. n] = "<F" .. n .. ">"
      end
      opts.icons = vim.tbl_deep_extend("force", opts.icons or {}, { mappings = false, keys = keys })
    end,
  },

  -- TODO コメントの印
  {
    "folke/todo-comments.nvim",
    opts = {
      keywords = {
        FIX = { icon = "F " },
        TODO = { icon = "T " },
        HACK = { icon = "H " },
        WARN = { icon = "W " },
        PERF = { icon = "P " },
        NOTE = { icon = "N " },
      },
    },
  },

  -- 診断やシンボルの一覧
  {
    "folke/trouble.nvim",
    opts = {
      icons = {
        indent = { fold_open = "v ", fold_closed = "> " },
        folder_closed = "+ ",
        folder_open = "- ",
        kinds = kinds,
      },
    },
  },

  -- ファイルツリー
  {
    "nvim-neo-tree/neo-tree.nvim",
    opts = {
      default_component_configs = {
        indent = { with_expanders = false }, -- 開閉の印はフォルダの +/- だけにする
        icon = { folder_closed = "+", folder_open = "-", folder_empty = "+", folder_empty_open = "-" },
        git_status = {
          symbols = {
            modified = "M",
            renamed = "R",
            untracked = "?",
            ignored = "!",
            unstaged = "U",
            staged = "S",
            conflict = "C",
          },
        },
      },
    },
  },

  -- 検索と置換
  { "MagicDuck/grug-far.nvim", opts = { icons = { enabled = false } } },
}
