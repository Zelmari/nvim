local M = {}

local jdk_checked = nil
local warned_missing_jdk = false

---Check whether an actual Java runtime is available without triggering macOS GUI stub popups.
local function has_java_runtime()
  if jdk_checked ~= nil then
    return jdk_checked
  end

  if vim.env.JAVA_HOME and vim.fn.executable(vim.env.JAVA_HOME .. "/bin/java") == 1 then
    jdk_checked = true
    return true
  end

  if vim.uv.os_uname().sysname == "Darwin" and vim.fn.executable("/usr/libexec/java_home") == 1 then
    vim.fn.system({ "/usr/libexec/java_home" })
    jdk_checked = (vim.v.shell_error == 0)
    return jdk_checked
  end

  jdk_checked = (vim.fn.executable("java") == 1)
  return jdk_checked
end

function M.setup()
  if not has_java_runtime() then
    if not warned_missing_jdk then
      warned_missing_jdk = true
      vim.notify(
        "nvim-jdtls: No JDK detected (install JDK 21+ to enable Java LSP & debugging).",
        vim.log.levels.WARN
      )
    end
    return
  end

  local ok_jdtls, jdtls = pcall(require, "jdtls")
  if not ok_jdtls then
    return
  end

  local mason_path = vim.fn.stdpath("data") .. "/mason"
  local jdtls_bin = mason_path .. "/bin/" .. (vim.fn.has("win32") == 1 and "jdtls.cmd" or "jdtls")
  if vim.fn.executable(jdtls_bin) == 0 then
    jdtls_bin = vim.fn.exepath("jdtls")
  end
  if jdtls_bin == "" then
    return
  end

  local root_dir = jdtls.setup.find_root({
    ".git",
    "mvnw",
    "gradlew",
    "pom.xml",
    "build.gradle",
    "build.gradle.kts",
    "settings.gradle",
    "settings.gradle.kts",
  }) or vim.fn.getcwd()

  local project_name = vim.fn.fnamemodify(root_dir, ":p:h:t") .. "_" .. vim.fn.sha256(root_dir):sub(1, 8)
  local workspace_dir = vim.fn.stdpath("cache") .. "/jdtls/workspace/" .. project_name

  local cmd = { jdtls_bin, "-data", workspace_dir }

  -- Automatically wire Lombok if bundled by Mason
  local lombok_jar = mason_path .. "/packages/jdtls/lombok.jar"
  if (vim.uv or vim.loop).fs_stat(lombok_jar) then
    table.insert(cmd, "--jvm-arg=-javaagent:" .. lombok_jar)
  end

  -- Collect java-debug-adapter and java-test OSGi bundles for nvim-dap
  local bundles = {}
  local java_debug_glob = mason_path
    .. "/packages/java-debug-adapter/extension/server/com.microsoft.java.debug.plugin-*.jar"
  for _, jar in ipairs(vim.fn.glob(java_debug_glob, true, true)) do
    if jar ~= "" then
      table.insert(bundles, jar)
    end
  end

  local java_test_glob = mason_path .. "/packages/java-test/extension/server/*.jar"
  local excluded_jars = {
    ["com.microsoft.java.test.runner-jar-with-dependencies.jar"] = true,
    ["jacocoagent.jar"] = true,
  }
  for _, jar in ipairs(vim.fn.glob(java_test_glob, true, true)) do
    local name = vim.fn.fnamemodify(jar, ":t")
    if jar ~= "" and not excluded_jars[name] then
      table.insert(bundles, jar)
    end
  end

  local capabilities = vim.lsp.protocol.make_client_capabilities()
  local ok_cmp, cmp_lsp = pcall(require, "cmp_nvim_lsp")
  if ok_cmp then
    capabilities = vim.tbl_deep_extend("force", capabilities, cmp_lsp.default_capabilities())
  end

  local extended_capabilities = jdtls.extendedClientCapabilities
  extended_capabilities.resolveAdditionalTextEditsSupport = true

  jdtls.start_or_attach({
    cmd = cmd,
    root_dir = root_dir,
    capabilities = capabilities,
    init_options = {
      bundles = bundles,
      extendedClientCapabilities = extended_capabilities,
    },
    settings = {
      java = {
        eclipse = { downloadSources = true },
        maven = { downloadSources = true },
        configuration = { updateBuildConfiguration = "interactive" },
        implementationsCodeLens = { enabled = false },
        referencesCodeLens = { enabled = false },
        inlayHints = {
          parameterNames = { enabled = "all" },
        },
        signatureHelp = { enabled = true },
      },
    },
    on_attach = function(_, bufnr)
      if #bundles > 0 then
        pcall(jdtls.setup_dap, { hotcodereplace = "auto", config_overrides = {} })
        pcall(function()
          require("jdtls.dap").setup_dap_main_class_configs()
        end)
      end

      -- Standard nvim-jdtls buffer-local actions
      local map = function(mode, lhs, rhs, desc)
        vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = "Java: " .. desc })
      end
      map("n", "<leader>co", jdtls.organize_imports, "Organize imports")
      map("n", "<leader>crv", jdtls.extract_variable, "Extract variable")
      map("x", "<leader>crv", function()
        jdtls.extract_variable(true)
      end, "Extract variable")
      map("n", "<leader>crc", jdtls.extract_constant, "Extract constant")
      map("x", "<leader>crc", function()
        jdtls.extract_constant(true)
      end, "Extract constant")
      map("x", "<leader>crm", function()
        jdtls.extract_method(true)
      end, "Extract method")
      map("n", "<leader>dt", jdtls.test_nearest_method, "Debug nearest Java test")
      map("n", "<leader>dT", jdtls.test_class, "Debug Java test class")
    end,
  })
end

return M
