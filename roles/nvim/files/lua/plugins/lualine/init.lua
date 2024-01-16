local Plugin = {
	"nvim-lualine/lualine.nvim",
	dependencies = {
		{ "EdenEast/nightfox.nvim" },
	},
	opts = function()
		return require("plugins.lualine.opts")
	end,
	config = true,
}

return Plugin
