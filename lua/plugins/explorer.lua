return {
  "nvim-tree/nvim-tree.lua",
  cmd = { "NvimTreeToggle", "NvimTreeFocus", "NvimTreeFindFile" },
  keys = {
    { "<leader>e", "<cmd>NvimTreeToggle<CR>", desc = "Explorer" },
    { "<leader>E", "<cmd>NvimTreeFindFile<CR>", desc = "Reveal current file" },
  },
  dependencies = { "nvim-tree/nvim-web-devicons" },
  opts = {
    hijack_netrw = false,
    view = { width = 34 },
    renderer = { group_empty = true },
    filters = { dotfiles = false },
  },
}
