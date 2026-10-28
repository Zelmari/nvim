local opt = vim.opt

-- Line numbers (hybrid: absolute on current line, relative elsewhere)
opt.number = true
opt.relativenumber = true

-- Indentation (4 spaces default for C++, Python, Java; 2-space overrides in autocmds.lua)
opt.expandtab = true
opt.tabstop = 4
opt.softtabstop = 4
opt.shiftwidth = 4
opt.smartindent = true

-- Clipboard (kept separate from OS clipboard unless "+ register is used explicitly)
opt.clipboard = ""

-- Line wrapping, sign column, and 80-column ruler
opt.wrap = false
opt.signcolumn = "yes"
opt.colorcolumn = "80"

-- Persistent undo (cross-platform XDG state path), no swap/backup files
opt.undofile = true
opt.undodir = vim.fn.stdpath("state") .. "/undo"
opt.swapfile = false
opt.backup = false
opt.writebackup = false

-- Window splits & mouse
opt.splitright = true
opt.splitbelow = true
opt.mouse = ""

-- Search & live substitution preview
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = true
opt.incsearch = true
opt.inccommand = "split"

-- Scroll margin, cursorline (number-only highlight for clean transparent bg), whitespace markers
opt.scrolloff = 8
opt.sidescrolloff = 8
opt.cursorline = true
opt.cursorlineopt = "number"
opt.list = true
opt.listchars = {
  tab = "» ",
  trail = "·",
  nbsp = "␣",
}

-- Appearance, global statusline, and native rounded float borders (Neovim 0.11+)
opt.termguicolors = true
opt.laststatus = 3
opt.winborder = "rounded"
opt.showmode = false
opt.pumblend = 0
opt.winblend = 0

-- Code folding defaults (Treesitter foldexpr is attached per-buffer in autocmds.lua)
opt.foldenable = true
opt.foldlevel = 99
opt.foldlevelstart = 99

-- Responsiveness & completion behavior
opt.updatetime = 250
opt.timeoutlen = 400
opt.completeopt = { "menu", "menuone", "noselect" }
opt.shortmess:append("c")
