local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- Highlight briefly when yanking text
autocmd("TextYankPost", {
  group = augroup("user_highlight_yank", { clear = true }),
  callback = function()
    vim.hl.on_yank({ timeout = 150 })
  end,
})

-- 2-space indentation for Lua, JSON, and YAML (C++, Python, and Java inherit 4 spaces)
autocmd("FileType", {
  group = augroup("user_two_space_indent", { clear = true }),
  pattern = { "lua", "json", "jsonc", "yaml", "yml" },
  callback = function(args)
    vim.bo[args.buf].tabstop = 2
    vim.bo[args.buf].softtabstop = 2
    vim.bo[args.buf].shiftwidth = 2
  end,
})

-- Enable Treesitter syntax highlighting, indentation, and folding wherever a parser exists
autocmd("FileType", {
  group = augroup("user_treesitter_features", { clear = true }),
  callback = function(args)
    if vim.bo[args.buf].buftype ~= "" then
      return
    end

    local ok = pcall(vim.treesitter.start, args.buf)
    if not ok then
      return
    end

    -- Treesitter indentation (if nvim-treesitter is loaded)
    if package.loaded["nvim-treesitter"] then
      vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
    end

    -- Treesitter folding for all windows displaying this buffer (all folds remain open by default)
    for _, win in ipairs(vim.fn.win_findbuf(args.buf)) do
      vim.wo[win][0].foldmethod = "expr"
      vim.wo[win][0].foldexpr = "v:lua.vim.treesitter.foldexpr()"
    end
  end,
})
