local M = {
	"williamboman/mason.nvim",
	opts = function()
		return require("plugins.mason-nvim.opts")
	end,
	build = ":MasonUpdate",
	config = true,
}

return M
