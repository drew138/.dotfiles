local M = {
	ensure_installed = {
		-- lsps required by lspconfig
		"ansible-language-server",
		"bash-language-server",
		"clangd",
		"docker-compose-language-service",
		"dockerfile-language-server",
		"gopls",
		"json-lsp",
		"lua-language-server",
		"marksman",
		"pyright",
		"rust-analyzer",
		"sqlls",
		"terraform-ls",
		"typescript-language-server",
		"yaml-language-server",
		"ruff",
		"gh-actions-language-server",

		-- debuggers used by nvim dap
		"delve",
		"debugpy",
		"cpptools",
		"bash-debug-adapter",
		"node-debug2-adapter",

		-- linters used by nvim-lint
		"ansible-lint",
		"eslint_d",
		"flake8",
		"markdownlint",
		"hadolint",
		"jsonlint",
		-- "selene", -- TODO: add it once mason devs fix wrong architechture installation
		"shellcheck",
		"sqlfluff",
		"buf",
		"protolint",
		"stylelint",

		-- formatters used by conform.nvim
		"prettier",
		"stylua",
		"black",
		"gofumpt",
		"goimports",
		"goimports-reviser",
		"golines",
		"beautysh",
		"buf",
		"clang-format",
		"sqlfmt",
		"hclfmt",
	},
	auto_update = false,
	run_on_start = true,
	start_delay = 3000,
	debounce_hours = 5,
}

return M
