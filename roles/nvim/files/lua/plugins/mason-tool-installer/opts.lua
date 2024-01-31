local Opts = {
	ensure_installed = {
		-- lsps required by lspconfig
		"ansible-language-server",
		"awk-language-server",
		"bash-language-server",
		"clangd",
		"cssls",
		"docker_compose_language_service",
		"dockerls",
		"gopls",
		"jsonls",
		"lua_ls",
		"marksman",
		"pyright",
		"rust_analyzer",
		"sqlls",
		"tailwindcss",
		"terraformls",
		"tsserver",
		"yamlls",

		-- debuggers used by nvim dap
		"delve",
		"python",
		"cppdbg",
		"bash",
		"node2",

		-- linters used by nvim-lint
		"eslint_d",
		"flake8",
		"markdownlint",
		"hadolint",
		"jsonlint",
		"shellcheck",
		"selene",
		"yamllint",
		"sqlfluff",

		-- formatters used by conform.nvim
		"prettier",
		"stylua",
		"black",
		"gofmt",
		"goimports",
		"goimports-reviser",
		"golines",
		"beautysh",
		"rustfmt",
		"buf",
		"clang_format",
		"sqlfluff ",
		"trim_whitespace",
	},
	auto_update = false,
	run_on_start = true,
	start_delay = 3000,
	debounce_hours = 5,
}

return Opts
