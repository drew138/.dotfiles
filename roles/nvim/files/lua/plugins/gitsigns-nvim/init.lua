local M = {
	"lewis6991/gitsigns.nvim",
	dependencies = { { "EdenEast/nightfox.nvim" } },
	opts = function()
		return require("plugins.gitsigns-nvim.opts")
	end,
	config = true,
}

return M
