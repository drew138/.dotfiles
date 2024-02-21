local Plugin = {
	"danymat/neogen",
	dependencies = {
		{ "nvim-treesitter/nvim-treesitter" },
	},
	keys = function()
		return require("plugins.neogen.keys")
	end,
	opts = function()
		return require("plugins.neogen.opts")
	end,
	config = true,
}

return Plugin
