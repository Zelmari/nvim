local function format()
	require("conform").format({
		async = true,
		lsp_format = "fallback",
		timeout_ms = 3000,
	})
end

return {
	"stevearc/conform.nvim",
	cmd = "ConformInfo",
	keys = {
		-- <S-C-f> rarely survives Linux terminals (Hyprland/kitty/alacritty
		-- often swallow it), so <leader>cf / <leader>f are canonical.
		-- <S-C-f> kept for macOS.
		{ "<leader>cf", format, mode = { "n", "x" }, desc = "Format" },
		{ "<leader>f", format, mode = { "n", "x" }, desc = "Format" },
		{ "<S-C-f>", format, mode = { "n", "x", "i" }, desc = "Format (Mac)" },
	},
	opts = {
		formatters_by_ft = {
			lua = { "stylua" },
			python = { "ruff_organize_imports", "ruff_format" },
			javascript = { "prettier" },
			javascriptreact = { "prettier" },
			typescript = { "prettier" },
			typescriptreact = { "prettier" },
			json = { "prettier" },
			jsonc = { "prettier" },
			yaml = { "prettier" },
			css = { "prettier" },
			html = { "prettier" },
			markdown = { "prettier" },
			c = { "clang_format" },
			cpp = { "clang_format" },
			go = { "gofmt" },
			rust = { "rustfmt" },
			sh = { "shfmt" },
			bash = { "shfmt" },
			php = { "php_cs_fixer" },
			ruby = { "rubocop" },
			swift = { "swiftformat" },
		},
		default_format_opts = {
			lsp_format = "fallback",
		},
		-- false on fresh clones: missing system/mason binaries stay silent
		-- and fall back to LSP instead of erroring.
		notify_on_error = false,
	},
}
