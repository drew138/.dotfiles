local M = {
	"drew138/git-conflict.nvim",
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
