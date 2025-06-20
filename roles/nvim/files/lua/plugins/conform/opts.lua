local M = {
	formatters_by_ft = {
		javascript = { "prettier" },
		typescript = { "prettier" },
		javascriptreact = { "prettier" },
		typescriptreact = { "prettier" },
		svelte = { "prettier" },
		css = { "prettier" },
		html = { "prettier" },
		json = { "prettier" },
		yaml = { "prettier" },
		markdown = { "prettier" },
		graphql = { "prettier" },
		lua = { "stylua" },
		python = { "black" },
		-- go = {
		-- 	"gofumpt",
		-- 	"goimports",
		-- 	"goimports-reviser",
		-- 	"golines",
		-- },
		sh = { "beautysh" },
		rust = { "rustfmt" },
		proto = { "buf" },
		cpp = { "clang_format" },
		sql = { "sqlfmt" },
		terraform = { "hclfmt" },
		["*"] = { "trim_whitespace" },
	},
	format_on_save = {
		lsp_fallback = true,
		async = false,
		timeout_ms = 500,
	},
}

return M
