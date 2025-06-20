local M = {
	"nvim-tree/nvim-web-devicons",
	opts = function()
		return require("plugins.nvim-web-devicons.opts")
	end,
	config = true,
}

return M
