local M = {
	"williamboman/mason.nvim",
	opts = function()
		return require("plugins.mason.opts")
	end,
	build = ":MasonUpdate",
	config = true,
}

return M
