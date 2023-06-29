local Plugin = {
	"lewis6991/gitsigns.nvim",
	dependencies = { { "EdenEast/nightfox.nvim" } },
	opts = function()
		return require("plugins.gitsigns.opts")
	end,
	config = true,
}

return Plugin
