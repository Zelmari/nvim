---Resolve active Python interpreter from $VIRTUAL_ENV or project .venv/venv (OS-agnostic)
local function find_python_path(workspace)
  if vim.env.VIRTUAL_ENV then
    local venv_py = vim.env.VIRTUAL_ENV .. "/bin/python"
    if vim.fn.executable(venv_py) == 1 then
      return venv_py
    end
  end
  if workspace then
    for _, dir in ipairs({ ".venv", "venv" }) do
      local candidate = workspace .. "/" .. dir .. "/bin/python"
      if vim.fn.executable(candidate) == 1 then
        return candidate
      end
    end
  end
  return vim.fn.exepath("python3") ~= "" and vim.fn.exepath("python3") or "python"
end

---Check whether python3 on PATH is >= 3.10 (required by Mason's pip-based basedpyright & debugpy)
local function has_python_310()
  if vim.fn.executable("python3") == 0 then
    return false
  end
  local out = vim.fn.system({
    "python3",
    "-c",
    "import sys; sys.exit(0 if sys.version_info >= (3, 10) else 1)",
  })
  local _ = out
  return vim.v.shell_error == 0
end

local py310_available = has_python_310()

return {
  {
    "mason-org/mason.nvim",
    cmd = "Mason",
    build = ":MasonUpdate",
    opts = {
      ui = {
        border = "rounded",
        backdrop = 100,
      },
    },
  },

  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    lazy = false,
    dependencies = {
      "mason-org/mason.nvim",
      "mason-org/mason-lspconfig.nvim",
    },
    opts = function()
      local tools = {
        -- LSP servers
        "clangd",
        "neocmake",
        "jdtls",
        "lua_ls",
        -- Formatters & linters
        "clang-format",
        "ruff",
        "google-java-format",
        "stylua",
        -- Debug adapters
        "codelldb",
        "java-debug-adapter",
        "java-test",
      }
      if py310_available then
        table.insert(tools, "basedpyright")
        table.insert(tools, "debugpy")
      end
      return {
        ensure_installed = tools,
        auto_update = false,
        run_on_start = true,
      }
    end,
  },

  {
    "mfussenegger/nvim-jdtls",
    ft = "java",
  },

  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "mason-org/mason.nvim",
      "mason-org/mason-lspconfig.nvim",
      "WhoIsSethDaniel/mason-tool-installer.nvim",
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
      -- Diagnostics appearance (inline virtual_text ON, gutter signs ON, rounded hover floats)
      vim.diagnostic.config({
        virtual_text = {
          spacing = 4,
          prefix = "●",
        },
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = "✘",
            [vim.diagnostic.severity.WARN] = "▲",
            [vim.diagnostic.severity.HINT] = "⚑",
            [vim.diagnostic.severity.INFO] = "»",
          },
        },
        underline = true,
        update_in_insert = false,
        severity_sort = true,
        float = {
          border = "rounded",
          source = true,
        },
      })

      -- Buffer-local LSP keymaps attached whenever any server connects
      -- Note: Neovim 0.12 already provides standard `grn` (rename), `gra` (code action),
      -- `grr` (references), `gri` (implementation), `gO` (outline), `K` (hover), `<C-s>` (sig help).
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("user_lsp_attach", { clear = true }),
        callback = function(event)
          local client = vim.lsp.get_client_by_id(event.data.client_id)
          local map = function(mode, lhs, rhs, desc)
            vim.keymap.set(mode, lhs, rhs, { buffer = event.buf, desc = "LSP: " .. desc })
          end

          map("n", "gd", vim.lsp.buf.definition, "Go to definition")
          map("n", "gD", vim.lsp.buf.declaration, "Go to declaration")
          map("n", "gy", vim.lsp.buf.type_definition, "Go to type definition")

          if client and client.name == "clangd" then
            map("n", "<leader>ch", "<cmd>LspClangdSwitchSourceHeader<CR>", "Switch C/C++ header/source")
          end

          -- Inlay hints remain OFF by default, toggleable per-buffer via <leader>th
          if client and client:supports_method("textDocument/inlayHint") then
            map("n", "<leader>th", function()
              local enabled = vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf })
              vim.lsp.inlay_hint.enable(not enabled, { bufnr = event.buf })
            end, "Toggle inlay hints")
          end
        end,
      })

      -- Capabilities shared across all servers via Neovim 0.12 `vim.lsp.config`
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      local ok_cmp, cmp_lsp = pcall(require, "cmp_nvim_lsp")
      if ok_cmp then
        capabilities = vim.tbl_deep_extend("force", capabilities, cmp_lsp.default_capabilities())
      end
      vim.lsp.config("*", {
        capabilities = capabilities,
      })

      -- C / C++: clangd (background indexing + clang-tidy ON, auto-header-insertion OFF)
      vim.lsp.config("clangd", {
        cmd = {
          "clangd",
          "--background-index",
          "--clang-tidy",
          "--header-insertion=never",
          "--completion-style=detailed",
          "--function-arg-placeholders=1",
        },
        init_options = {
          usePlaceholders = true,
          completeUnimported = true,
          clangdFileStatus = true,
        },
      })

      -- CMake: neocmake
      vim.lsp.config("neocmake", {})

      -- Python: basedpyright (standard type-checking mode + automatic venv detection)
      vim.lsp.config("basedpyright", {
        before_init = function(_, config)
          config.settings = config.settings or {}
          config.settings.python = config.settings.python or {}
          config.settings.python.pythonPath = find_python_path(config.root_dir)
        end,
        settings = {
          basedpyright = {
            analysis = {
              typeCheckingMode = "standard",
              autoSearchPaths = true,
              useLibraryCodeForTypes = true,
              diagnosticMode = "openFilesOnly",
            },
          },
        },
      })

      -- Lua: lua_ls configured cleanly for Neovim config development
      vim.lsp.config("lua_ls", {
        settings = {
          Lua = {
            runtime = { version = "LuaJIT" },
            workspace = {
              checkThirdParty = false,
              library = {
                vim.env.VIMRUNTIME,
              },
            },
            diagnostics = {
              globals = { "vim" },
            },
            telemetry = { enable = false },
          },
        },
      })

      -- Auto-enable installed LSP servers (installations managed by mason-tool-installer; jdtls managed by nvim-jdtls)
      require("mason-lspconfig").setup({
        ensure_installed = {},
        automatic_enable = {
          exclude = { "jdtls" },
        },
      })

      -- Notify once on Python buffers if system python3 < 3.10 prevented Mason from installing basedpyright/debugpy
      if not py310_available then
        local warned_py = false
        vim.api.nvim_create_autocmd("FileType", {
          group = vim.api.nvim_create_augroup("user_python_version_warn", { clear = true }),
          pattern = "python",
          callback = function()
            if not warned_py and vim.fn.executable("basedpyright-langserver") == 0 then
              warned_py = true
              vim.notify(
                "Python 3.10+ on PATH is required for Mason to install basedpyright & debugpy (install Python 3.10+ and restart Neovim).",
                vim.log.levels.WARN
              )
            end
          end,
        })
      end

      -- Attach nvim-jdtls on Java buffers
      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("user_java_jdtls", { clear = true }),
        pattern = "java",
        callback = function()
          require("config.jdtls").setup()
        end,
      })
    end,
  },
}
