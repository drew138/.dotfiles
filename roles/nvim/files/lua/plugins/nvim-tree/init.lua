local M = {
	"nvim-tree/nvim-tree.lua",
	dependencies = {
		{ "EdenEast/nightfox.nvim" },
		{ "nvim-tree/nvim-web-devicons" },
	},
	opts = function()
		return require("plugins.nvim-tree.opts")
	end,
	cmd = { "NvimTreeToggle" },
	keys = function()
		return require("plugins.nvim-tree.keys")
	end,
	config = true,
}

return M
