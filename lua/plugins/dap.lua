---Find active Python interpreter for target program debugging across macOS and Void Linux
local function resolve_target_python()
  if vim.env.VIRTUAL_ENV then
    local venv_py = vim.env.VIRTUAL_ENV .. "/bin/python"
    if vim.fn.executable(venv_py) == 1 then
      return venv_py
    end
  end
  local cwd = vim.fn.getcwd()
  for _, dir in ipairs({ ".venv", "venv" }) do
    local candidate = cwd .. "/" .. dir .. "/bin/python"
    if vim.fn.executable(candidate) == 1 then
      return candidate
    end
  end
  return vim.fn.exepath("python3") ~= "" and vim.fn.exepath("python3") or "python"
end

return {
  {
    "igorlfs/nvim-dap-view",
    version = "1.*",
    lazy = true,
    opts = {
      auto_toggle = true,
      virtual_text = {
        enabled = true,
      },
      winbar = {
        show = true,
        sections = {
          "watches",
          "scopes",
          "exceptions",
          "breakpoints",
          "threads",
          "repl",
          "console",
        },
        default_section = "scopes",
      },
    },
  },

  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "igorlfs/nvim-dap-view",
      "mason-org/mason.nvim",
      "jay-babu/mason-nvim-dap.nvim",
    },
    keys = {
      {
        "<F5>",
        function()
          require("dap").continue()
        end,
        desc = "DAP: Start / Continue",
      },
      {
        "<F10>",
        function()
          require("dap").step_over()
        end,
        desc = "DAP: Step Over",
      },
      {
        "<F11>",
        function()
          require("dap").step_into()
        end,
        desc = "DAP: Step Into",
      },
      {
        "<F12>",
        function()
          require("dap").step_out()
        end,
        desc = "DAP: Step Out",
      },
      {
        "<leader>db",
        function()
          require("dap").toggle_breakpoint()
        end,
        desc = "DAP: Toggle Breakpoint",
      },
      {
        "<leader>dB",
        function()
          require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: "))
        end,
        desc = "DAP: Conditional Breakpoint",
      },
      {
        "<leader>dr",
        function()
          require("dap").repl.toggle()
        end,
        desc = "DAP: Toggle REPL",
      },
      {
        "<leader>dl",
        function()
          require("dap").run_last()
        end,
        desc = "DAP: Run Last",
      },
      {
        "<leader>dq",
        function()
          require("dap").terminate()
        end,
        desc = "DAP: Terminate Session",
      },
      {
        "<leader>dv",
        "<cmd>DapViewToggle<CR>",
        desc = "DAP: Toggle DAP View",
      },
    },
    config = function()
      local dap = require("dap")

      -- Clean gutter signs for breakpoints & current stopped line
      vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DiagnosticError", linehl = "", numhl = "" })
      vim.fn.sign_define(
        "DapBreakpointCondition",
        { text = "◆", texthl = "DiagnosticWarn", linehl = "", numhl = "" }
      )
      vim.fn.sign_define(
        "DapBreakpointRejected",
        { text = "○", texthl = "DiagnosticInfo", linehl = "", numhl = "" }
      )
      vim.fn.sign_define("DapStopped", { text = "▶", texthl = "DiagnosticOk", linehl = "Visual", numhl = "" })

      require("mason-nvim-dap").setup({
        automatic_installation = false, -- Handled centrally by mason-tool-installer
        handlers = {
          function(config)
            require("mason-nvim-dap").default_setup(config)
          end,
          -- Java DAP is wired directly through nvim-jdtls bundles in lua/config/jdtls.lua
          javadbg = function() end,
          javatest = function() end,
        },
      })

      -- C / C++ launch configurations via codelldb (OS-agnostic across macOS & Void Linux)
      local cpp_configs = {
        {
          name = "Launch C/C++ executable (codelldb)",
          type = "codelldb",
          request = "launch",
          program = function()
            return vim.fn.input("Path to executable (compile with -g): ", vim.fn.getcwd() .. "/", "file")
          end,
          cwd = "${workspaceFolder}",
          stopOnEntry = false,
        },
        {
          name = "Launch C/C++ executable with arguments (codelldb)",
          type = "codelldb",
          request = "launch",
          program = function()
            return vim.fn.input("Path to executable (compile with -g): ", vim.fn.getcwd() .. "/", "file")
          end,
          args = function()
            local input = vim.fn.input("Program arguments: ")
            return vim.split(input, " ", { trimempty = true })
          end,
          cwd = "${workspaceFolder}",
          stopOnEntry = false,
        },
        {
          name = "Attach to running process (codelldb)",
          type = "codelldb",
          request = "attach",
          pid = require("dap.utils").pick_process,
          cwd = "${workspaceFolder}",
        },
      }
      dap.configurations.cpp = cpp_configs
      dap.configurations.c = cpp_configs

      -- Python launch configuration (uses project .venv / $VIRTUAL_ENV automatically)
      dap.configurations.python = {
        {
          type = "python",
          request = "launch",
          name = "Launch current Python file",
          program = "${file}",
          pythonPath = resolve_target_python,
          cwd = "${workspaceFolder}",
        },
        {
          type = "python",
          request = "launch",
          name = "Launch current Python file with arguments",
          program = "${file}",
          args = function()
            local input = vim.fn.input("Script arguments: ")
            return vim.split(input, " ", { trimempty = true })
          end,
          pythonPath = resolve_target_python,
          cwd = "${workspaceFolder}",
        },
      }

      -- Fallback remote attach configuration for Java (main/test launch configs are populated by nvim-jdtls)
      dap.configurations.java = dap.configurations.java or {}
      table.insert(dap.configurations.java, {
        type = "java",
        request = "attach",
        name = "Attach to remote JVM (port 5005)",
        hostName = "127.0.0.1",
        port = 5005,
      })
    end,
  },
}
