return {
  {
    "stevearc/oil.nvim",
    lazy = false, -- Load immediately so `nvim .` opens Oil instead of netrw
    dependencies = { "nvim-tree/nvim-web-devicons" },
    keys = {
      { "-", "<cmd>Oil<CR>", desc = "Open parent directory (Oil)" },
    },
    opts = {
      default_file_explorer = true,
      skip_confirm_for_simple_edits = true,
      columns = { "icon" },
      view_options = {
        show_hidden = true,
        is_always_hidden = function(name, _)
          return name == ".." or name == ".git"
        end,
      },
      float = { border = "rounded" },
      confirmation = { border = "rounded" },
      progress = { border = "rounded" },
      ssh = { border = "rounded" },
      keymaps_help = { border = "rounded" },
    },
  },

  {
    "ibhagwan/fzf-lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    cmd = "FzfLua",
    keys = {
      { "<leader>ff", "<cmd>FzfLua files<CR>", desc = "Find files" },
      { "<leader>fg", "<cmd>FzfLua live_grep<CR>", desc = "Live grep" },
      { "<leader>fb", "<cmd>FzfLua buffers<CR>", desc = "Find buffers" },
      { "<leader>fh", "<cmd>FzfLua help_tags<CR>", desc = "Help tags" },
      { "<leader>fr", "<cmd>FzfLua oldfiles<CR>", desc = "Recent files" },
      { "<leader>fw", "<cmd>FzfLua grep_cword<CR>", desc = "Grep word under cursor" },
      { "<leader>fd", "<cmd>FzfLua diagnostics_workspace<CR>", desc = "Workspace diagnostics" },
      { "<leader>fs", "<cmd>FzfLua lsp_document_symbols<CR>", desc = "Document symbols" },
      { "<leader>fS", "<cmd>FzfLua lsp_live_workspace_symbols<CR>", desc = "Workspace symbols" },
      { "<leader>fk", "<cmd>FzfLua keymaps<CR>", desc = "Search keymaps" },
    },
    opts = {
      winopts = {
        height = 0.85,
        width = 0.85,
        border = "rounded",
        backdrop = 100, -- Preserve full terminal transparency
        preview = {
          border = "rounded",
          layout = "flex",
          flip_columns = 120,
        },
      },
      files = {
        hidden = true,
        fd_opts = "--color=never --type f --hidden --follow --exclude .git",
      },
      grep = {
        hidden = true,
        rg_opts = "--column --line-number --no-heading --color=always --smart-case --max-columns=4096 --hidden -g '!.git/' -e",
      },
    },
    config = function(_, opts)
      local fzf = require("fzf-lua")
      fzf.setup(opts)
      fzf.register_ui_select()
    end,
  },
}
