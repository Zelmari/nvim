return {
  "catppuccin/nvim",
  name = "catppuccin",
  lazy = false,
  priority = 1000,
  config = function()
    local groups = {
      "Normal",
      "NormalNC",
      "NormalFloat",
      "FloatBorder",
      "SignColumn",
      "EndOfBuffer",
    }

    local function apply_transparency()
      for _, group in ipairs(groups) do
        local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = group, link = false })
        if ok then
          hl.bg = nil
          hl.ctermbg = nil
          pcall(vim.api.nvim_set_hl, 0, group, hl)
        end
      end
    end

    vim.api.nvim_create_autocmd("ColorScheme", {
      pattern = "catppuccin*",
      callback = apply_transparency,
    })

    require("catppuccin").setup({
      flavour = "mocha",
      transparent_background = true,
    })

    vim.cmd.colorscheme("catppuccin-mocha")
    apply_transparency()
  end,
}
