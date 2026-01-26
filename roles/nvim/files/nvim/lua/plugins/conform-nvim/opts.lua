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
		go = {
			"gofumpt",
			"goimports",
			"goimports-reviser",
			"golines",
		},
		sh = { "beautysh" },
		rust = { "rustfmt" },
		proto = { "buf" },
		cpp = { "clang_format" },
		sql = { "sqlfmt" },
		terraform = { "hcl" },
		toml = { "tombi" },
		["*"] = { "trim_whitespace" },
	},

	formatters = {
		prettier = {
			prepend_args = function(_, ctx)
				-- Only force yaml parser for files without extension like .yamllint
				if vim.fn.fnamemodify(ctx.filename, ":t") == ".yamllint" then
					return { "--parser", "yaml" }
				end
				return {}
			end,
		},
		tombi = {
			command = "/Users/andres.salazar/.local/share/nvim/mason/bin/tombi",
			args = { "format", "--stdin-filename", "$FILENAME", "-" },
			stdin = true,
		},
		beautysh = {
			command = "beautysh",
			args = {
				"--force-function-style",
				"paronly",
				"--variable-style",
				"braces",
				"-",
			},
			stdin = true,
		},
	},
	-- format_on_save = false,
	format_on_save = {
		lsp_format = "fallback",
		async = false,
		timeout_ms = 500,
	},
}

return M
