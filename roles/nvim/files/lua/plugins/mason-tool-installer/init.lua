local Plugin = {
	"WhoIsSethDaniel/mason-tool-installer.nvim",
	dependencies = {
		{ "williamboman/mason.nvim" },
		{ "neovim/nvim-lspconfig" },
		{ "stevearc/conform.nvim" },
		{ "mfussenegger/nvim-dap" },
		{ "mfussenegger/nvim-lint" },
	},
	opts = function()
		return require("plugins.mason-tool-installer.opts")
	end,
	config = true,
}

return Plugin
