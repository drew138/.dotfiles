local Plugin = {
	"akinsho/toggleterm.nvim",
	version = "*",
	keys = function()
		return require("plugins.toggleterm.keys")
	end,
	config = true,
}

return Plugin
