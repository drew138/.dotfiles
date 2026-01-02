local M = {
	"akinsho/toggleterm.nvim",
	version = "*",
	keys = function()
		return require("plugins.toggleterm-nvim.keys")
	end,
	opts = function()
		return require("plugins.toggleterm-nvim.opts")
	end,
	config = true,
}

return M
