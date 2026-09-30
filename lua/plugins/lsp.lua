return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = { "mason-org/mason.nvim", "saghen/blink.cmp" },
  config = function()
    vim.lsp.config("*", {
      capabilities = require("blink.cmp").get_lsp_capabilities(),
    })

    vim.lsp.config("lua_ls", {
      settings = {
        Lua = {
          diagnostics = { globals = { "vim" } },
          workspace = { checkThirdParty = false },
          telemetry = { enable = false },
        },
      },
    })

    vim.lsp.config("pyright", {
      settings = {
        python = {
          analysis = { typeCheckingMode = "basic" },
        },
      },
    })

    -- Portable: only set fallbackPath if the dir actually exists.
    -- macOS manual install, mason's bundled TS, or global npm all work.
    -- Otherwise leave empty so ts_ls resolves typescript itself.
    local ts_fallback = vim.fn.expand("~/.local/share/ts/node_modules/typescript")
    if vim.fn.isdirectory(ts_fallback) ~= 1 then
      ts_fallback = nil
    end
    if ts_fallback then
      vim.lsp.config("ts_ls", {
        init_options = {
          tsserver = { fallbackPath = ts_fallback },
        },
      })
    end

    -- Swift: sourcekit-lsp ships with Xcode CLT at /usr/bin/sourcekit-lsp and
    -- is on PATH, so no mason package (mason dropped sourcekit-lsp from its
    -- registry). pcall below keeps it quiet if CLT is missing.
    -- filetypes narrowed from the default (swift,c,cpp,objc,objcpp) so it does
    -- not double up with clangd on C/C++/ObjC.
    vim.lsp.config("sourcekit", {
      filetypes = { "swift" },
      settings = {
        textDocument = {
          swift = {
            -- Add buildSettings / target.sdk here if a project needs a
            -- specific toolchain.
          },
        },
      },
    })

    -- Hybrid: system binaries win (mason PATH=append), mason fills gaps.
    -- pcall so a fresh clone with nothing installed stays silent.
    pcall(vim.lsp.enable, {
      "lua_ls",
      "pyright",
      "ts_ls",
      "clangd",
      "gopls",
      "rust_analyzer",
      "bashls",
      "intelephense",
      "ruby_lsp",
      "sourcekit",
    })

    vim.diagnostic.config({
      severity_sort = true,
      float = { border = "rounded" },
      virtual_text = { current_line = true },
    })

    vim.api.nvim_create_autocmd("LspAttach", {
      group = vim.api.nvim_create_augroup("lsp-attach", { clear = true }),
      callback = function(args)
        local function map(mode, lhs, rhs, desc)
          vim.keymap.set(mode, lhs, rhs, { buffer = args.buf, desc = "LSP: " .. desc })
        end

        map("n", "gd", vim.lsp.buf.definition, "Goto definition")
        map("n", "gD", vim.lsp.buf.declaration, "Goto declaration")
        map("n", "gr", vim.lsp.buf.references, "References")
        map("n", "gi", vim.lsp.buf.implementation, "Implementation")
        map("n", "K", vim.lsp.buf.hover, "Hover docs")
        map("n", "<leader>rn", vim.lsp.buf.rename, "Rename symbol")
        map("n", "<leader>ca", vim.lsp.buf.code_action, "Code action")
        map("n", "]d", function()
          vim.diagnostic.jump({ count = 1, float = true })
        end, "Next diagnostic")
        map("n", "[d", function()
          vim.diagnostic.jump({ count = -1, float = true })
        end, "Previous diagnostic")
        map("n", "<leader>d", vim.diagnostic.open_float, "Line diagnostics")
      end,
    })
  end,
}
