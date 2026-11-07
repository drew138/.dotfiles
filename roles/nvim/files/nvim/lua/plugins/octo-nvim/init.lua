local M = {
	"pwntester/octo.nvim",
	cmd = "Octo",
	dependencies = {
		{ "nvim-lua/plenary.nvim" },
		{ "nvim-telescope/telescope.nvim" },
		{ "nvim-tree/nvim-web-devicons" },
	},
	opts = function()
		return require("plugins.octo-nvim.opts")
	end,
	keys = function()
		return require("plugins.octo-nvim.keys")
	end,
}

return M
