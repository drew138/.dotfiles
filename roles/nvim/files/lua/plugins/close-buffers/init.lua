local M = {
	"kazhala/close-buffers.nvim",
	keys = function()
		return require("plugins.close-buffers.keys")
	end,
	config = true,
}
return M
