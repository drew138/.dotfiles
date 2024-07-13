local Plugin = {
	"akinsho/git-conflict.nvim",
	version = "*",
	opts = function()
		return require("plugins.git-conflict.opts")
	end,
	config = true,
	keys = function()
		return require("plugins.git-conflict.keys")
	end,
}

return Plugin
