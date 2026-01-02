local M = {
	"WhoIsSethDaniel/mason-tool-installer.nvim",
	dependencies = {
		{ "williamboman/mason.nvim" },
		{ "neovim/nvim-lspconfig" },
		{ "stevearc/conform.nvim" },
		{ "mfussenegger/nvim-dap" },
		{ "mfussenegger/nvim-lint" },
	},
	opts = function()
		return require("plugins.mason-tool-installer-nvim.opts")
	end,
	config = true,
}

return M
