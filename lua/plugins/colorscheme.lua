return {
  {
    "rose-pine/neovim",
    name = "rose-pine",
    lazy = false,
    priority = 1000,
    opts = {
      variant = "main",
      dark_variant = "main",
      dim_inactive_windows = false,
      extend_background_behind_borders = true,
      styles = {
        bold = true,
        italic = false, -- Upright comments & keywords as requested
        transparency = true, -- Full terminal background transparency
      },
      highlight_groups = {
        -- Ensure all floats, popups, completion menus, and statuslines stay fully transparent
        Normal = { bg = "NONE" },
        NormalNC = { bg = "NONE" },
        NormalFloat = { bg = "NONE" },
        FloatBorder = { fg = "highlight_high", bg = "NONE" },
        FloatTitle = { fg = "foam", bg = "NONE", bold = true },
        Pmenu = { fg = "subtle", bg = "NONE" },
        PmenuSel = { fg = "text", bg = "overlay", bold = true },
        PmenuSbar = { bg = "NONE" },
        PmenuThumb = { bg = "highlight_med" },
        StatusLine = { fg = "subtle", bg = "NONE" },
        StatusLineNC = { fg = "muted", bg = "NONE" },
        SignColumn = { bg = "NONE" },
        FoldColumn = { bg = "NONE" },
        CursorLineNr = { fg = "gold", bg = "NONE", bold = true },
        ColorColumn = { bg = "surface" },
        WinBar = { fg = "subtle", bg = "NONE" },
        WinBarNC = { fg = "muted", bg = "NONE" },
      },
    },
    config = function(_, opts)
      require("rose-pine").setup(opts)
      vim.cmd.colorscheme("rose-pine")
    end,
  },
}
