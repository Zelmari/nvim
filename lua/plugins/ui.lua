return {
  "nvim-lualine/lualine.nvim",
  event = "VeryLazy",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  opts = {
    options = {
      theme = "catppuccin-mocha",
      icons_enabled = true,
      component_separators = { left = "", right = "" },
      section_separators = { left = "", right = "" },
      globalstatus = true,
    },
  },
  config = function(_, opts)
    local theme = require("lualine.themes.catppuccin-mocha")
    local palette = require("catppuccin.palettes").get_palette("mocha")
    for _, sections in pairs(theme) do
      for _, style in pairs(sections) do
        if type(style) == "table" and style.bg == "NONE" then
          style.bg = palette.mantle
        end
      end
    end
    opts.options.theme = theme
    require("lualine").setup(opts)
  end,
}
