return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    build = ":TSUpdate",
    config = function()
      local ts = require("nvim-treesitter")
      ts.setup({
        install_dir = vim.fn.stdpath("data") .. "/site",
      })

      local parsers = {
        "c",
        "cpp",
        "cmake",
        "make",
        "doxygen",
        "python",
        "java",
        "javadoc",
        "lua",
        "luadoc",
        "vim",
        "vimdoc",
        "query",
        "markdown",
        "markdown_inline",
        "bash",
        "json",
        "yaml",
        "toml",
        "xml",
        "diff",
        "gitcommit",
        "gitignore",
      }

      if vim.fn.executable("tree-sitter") == 1 and vim.fn.executable("cc") == 1 then
        ts.install(parsers)
      else
        vim.notify(
          "nvim-treesitter: install 'tree-sitter' CLI and a C compiler ('cc') to build missing parsers.",
          vim.log.levels.WARN
        )
      end
    end,
  },
}
