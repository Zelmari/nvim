return {
  {
    "stevearc/conform.nvim",
    cmd = { "ConformInfo" },
    keys = {
      {
        "<leader>cf",
        function()
          require("conform").format({ async = true, lsp_format = "fallback" })
        end,
        mode = { "n", "x" },
        desc = "Format buffer / selection",
      },
    },
    opts = {
      -- Strictly NO format_on_save (manual shortcut only)
      formatters_by_ft = {
        c = { "clang-format" },
        cpp = { "clang-format" },
        python = { "ruff_organize_imports", "ruff_format" },
        java = { "google-java-format", lsp_format = "fallback" },
        lua = { "stylua" },
      },
      formatters = {
        ["clang-format"] = {
          -- Respects any project .clang-format; falls back to 4-space indent & 80-col limit when none exists
          prepend_args = function(_, ctx)
            local found = vim.fs.find({ ".clang-format", "_clang-format" }, { upward = true, path = ctx.dirname })
            if #found > 0 then
              return {}
            end
            return { "--style={BasedOnStyle: LLVM, IndentWidth: 4, ColumnLimit: 80}" }
          end,
        },
        ["google-java-format"] = {
          -- Use 4-space Java indentation matching editor shiftwidth = 4
          prepend_args = { "--aosp" },
        },
      },
      default_format_opts = {
        lsp_format = "fallback",
      },
    },
  },

  {
    "mfussenegger/nvim-lint",
    event = { "BufReadPost", "BufWritePost" },
    config = function()
      local lint = require("lint")

      -- C/C++ uses clangd's built-in clang-tidy; Java uses jdtls compiler diagnostics
      lint.linters_by_ft = {
        python = { "ruff" },
      }

      local lint_augroup = vim.api.nvim_create_augroup("user_nvim_lint", { clear = true })
      vim.api.nvim_create_autocmd({ "BufReadPost", "BufWritePost" }, {
        group = lint_augroup,
        callback = function(args)
          if vim.bo[args.buf].modifiable and vim.bo[args.buf].buftype == "" then
            lint.try_lint()
          end
        end,
      })

      vim.keymap.set("n", "<leader>cl", function()
        lint.try_lint()
      end, { desc = "Run linter on current buffer" })
    end,
  },
}
