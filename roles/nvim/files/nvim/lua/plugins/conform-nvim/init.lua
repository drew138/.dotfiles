local M = {
	"stevearc/conform.nvim",
	event = { "BufReadPre", "BufNewFile" },
	opts = function()
		return require("plugins.conform-nvim.opts")
	end,
	config = true,
}

return M
