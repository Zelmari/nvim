return {
  "nvim-treesitter/nvim-treesitter",
  lazy = false,
  build = ":TSUpdate",
  config = function()
    -- nvim-treesitter `main` ignores the old `ensure_install` option; the
    -- current API is install(). Non-blocking by default, so this doesn't
    -- stall startup on a fresh clone. Remove entries you don't need to
    -- keep first-run installs small.
    require("nvim-treesitter").install({
      "lua",
      "vim",
      "vimdoc",
      "query",
      "bash",
      "json",
      "toml",
      "yaml",
      "markdown",
      "markdown_inline",
      "diff",
      "gitcommit",
      "regex",
      "c",
      "python",
      "javascript",
      "typescript",
      "tsx",
      "html",
      "css",
      "swift",
    })

    vim.api.nvim_create_autocmd("FileType", {
      group = vim.api.nvim_create_augroup("treesitter-highlight", { clear = true }),
      callback = function(args)
        pcall(vim.treesitter.start, args.buf)
      end,
    })
  end,
}
