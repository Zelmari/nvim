-- Base keymaps (kept strictly minimal & standard; custom keybindings will be tuned in the final phase)
local map = vim.keymap.set

-- Clear search highlighting on <Esc> in Normal mode
map("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlights" })

-- Diagnostic float inspection (supplements Neovim 0.12 defaults [d / ]d)
map("n", "<leader>cd", vim.diagnostic.open_float, { desc = "Show line diagnostics" })
