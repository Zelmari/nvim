return {
  {
    "nvim-tree/nvim-web-devicons",
    lazy = true,
  },

  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = function()
      local p = require("rose-pine.palette")
      local transparent_theme = {
        normal = {
          a = { bg = p.rose, fg = p.base, gui = "bold" },
          b = { bg = p.overlay, fg = p.rose },
          c = { bg = "NONE", fg = p.text },
        },
        insert = {
          a = { bg = p.foam, fg = p.base, gui = "bold" },
          b = { bg = p.overlay, fg = p.foam },
          c = { bg = "NONE", fg = p.text },
        },
        visual = {
          a = { bg = p.iris, fg = p.base, gui = "bold" },
          b = { bg = p.overlay, fg = p.iris },
          c = { bg = "NONE", fg = p.text },
        },
        replace = {
          a = { bg = p.pine, fg = p.base, gui = "bold" },
          b = { bg = p.overlay, fg = p.pine },
          c = { bg = "NONE", fg = p.text },
        },
        command = {
          a = { bg = p.love, fg = p.base, gui = "bold" },
          b = { bg = p.overlay, fg = p.love },
          c = { bg = "NONE", fg = p.text },
        },
        inactive = {
          a = { bg = "NONE", fg = p.muted, gui = "bold" },
          b = { bg = "NONE", fg = p.muted },
          c = { bg = "NONE", fg = p.muted },
        },
      }

      return {
        options = {
          theme = transparent_theme,
          globalstatus = true,
          component_separators = { left = "|", right = "|" },
          section_separators = { left = "", right = "" },
        },
        sections = {
          lualine_a = { "mode" },
          lualine_b = { "branch", "diff", "diagnostics" },
          lualine_c = { { "filename", path = 1 } },
          lualine_x = {
            {
              function()
                local clients = vim.lsp.get_clients({ bufnr = 0 })
                if #clients == 0 then
                  return ""
                end
                local names = {}
                for _, client in ipairs(clients) do
                  if client.name ~= "copilot" then
                    table.insert(names, client.name)
                  end
                end
                return #names > 0 and ("LSP: " .. table.concat(names, ", ")) or ""
              end,
            },
            "filetype",
          },
          lualine_y = { "progress" },
          lualine_z = { "location" },
        },
      }
    end,
  },

  {
    "akinsho/toggleterm.nvim",
    version = "*",
    keys = {
      { [[<C-\>]], desc = "Toggle floating terminal" },
    },
    cmd = { "ToggleTerm", "TermExec" },
    opts = {
      open_mapping = [[<C-\>]],
      direction = "float",
      shade_terminals = false, -- Keep terminal background genuinely transparent
      shell = vim.o.shell,
      float_opts = {
        border = "curved", -- Rounded border in toggleterm
        width = function()
          return math.floor(vim.o.columns * 0.85)
        end,
        height = function()
          return math.floor(vim.o.lines * 0.80)
        end,
        winblend = 0,
      },
    },
  },
}
