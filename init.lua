-- Must be set before lazy.nvim loads so plugin mappings pick up Leader/LocalLeader
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Disable built-in netrw early so oil.nvim handles directory buffers cleanly
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

require("config.options")
require("config.keymaps")
require("config.autocmds")
require("config.lazy")
