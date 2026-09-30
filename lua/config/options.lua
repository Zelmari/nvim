local opt = vim.opt
local g = vim.g

g.mapleader = " "
g.maplocalleader = " "

opt.number = true
opt.signcolumn = "yes"
opt.termguicolors = true
opt.cursorline = true
opt.scrolloff = 5
opt.sidescrolloff = 5
opt.splitright = true
opt.splitbelow = true
opt.ignorecase = true
opt.smartcase = true
opt.inccommand = "split"
opt.updatetime = 250
opt.timeoutlen = 400
opt.undofile = true
opt.swapfile = false
opt.wrap = false
opt.mouse = "a"
-- Works on macOS (pbcopy) and Hyprland/Wayland (wl-copy/wl-paste from
-- wl-clipboard). No fork needed; see INSTALL.md if yanks don't reach system.
opt.clipboard = "unnamedplus"
opt.completeopt = { "menu", "menuone", "noselect" }
opt.showmode = false
opt.expandtab = true
opt.shiftwidth = 2
opt.tabstop = 2
opt.smartindent = true
opt.colorcolumn = "120"

vim.hl.priorities.treesitter = 100
vim.hl.priorities.syntax = 50

-- Block cursor in every mode, blinking. Default is ver25 in insert/cmdline,
-- so `a:block` forces block everywhere. Re-applied on ColorScheme since
-- colorschemes may overwrite 'guicursor'. Ghostty side also needs
-- `cursor-style = block` + `cursor-style-blink = true`.
local function block_cursor()
  opt.guicursor = "a:block-blinkwait0-blinkon500-blinkoff500"
end

block_cursor()
vim.api.nvim_create_autocmd("ColorScheme", {
  group = vim.api.nvim_create_augroup("cursor", { clear = true }),
  callback = block_cursor,
})
