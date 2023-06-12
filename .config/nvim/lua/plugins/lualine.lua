local Plugin = {
	"nvim-lualine/lualine.nvim",
	dependencies = { { "EdenEast/nightfox.nvim" } },
	opts = function()
		return require("options.lualine")
	end,
	config = true,
}

return Plugin
