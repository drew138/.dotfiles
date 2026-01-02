local M = {
	"nvim-lualine/lualine.nvim",
	dependencies = {
		{ "EdenEast/nightfox.nvim" },
		{ "nvim-tree/nvim-web-devicons" },
	},
	opts = function()
		return require("plugins.lualine-nvim.opts")
	end,
	config = true,
}

return M
