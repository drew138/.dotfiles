local M = {
	"akinsho/git-conflict.nvim",
	version = "*",
	lazy = false,
	opts = function()
		return require("plugins.git-conflict-nvim.opts")
	end,
	config = true,
	keys = function()
		return require("plugins.git-conflict-nvim.keys")
	end,
}

return M
