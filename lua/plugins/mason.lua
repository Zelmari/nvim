-- Hybrid system-first + mason fallback.
-- mason/bin is appended (not prepended) so brew/pacman binaries win when present.
return {
  {
    "mason-org/mason.nvim",
    cmd = "Mason",
    build = ":MasonUpdate",
    opts = {
      PATH = "append",
      ui = { border = "rounded" },
    },
  },
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = { "mason-org/mason.nvim" },
    event = "VeryLazy",
    opts = {
      auto_update = false,
      run_on_start = true,
      ensure_installed = {
        -- LSP (mirrors lsp.lua)
        "lua-language-server",
        "pyright",
        "typescript-language-server",
        "clangd",
        "gopls",
        "rust-analyzer",
        "bash-language-server",
        "intelephense",
        -- formatters (mirrors format.lua)
        "stylua",
        "ruff",
        "prettier",
        "clang-format",
        "shfmt",
        "php-cs-fixer",
        "rubocop",
        "swiftformat",
        -- NOTE: gofmt/rustfmt ship with go/rust, ruby-lsp via `gem install ruby-lsp`,
        -- swift LSP via Xcode CLT (/usr/bin/sourcekit-lsp) — not in mason's registry.
      },
    },
  },
}
