local Plugin = {
	"akinsho/git-conflict.nvim",
	version = "*",
	opts = function()
		return require("options.git-conflict")
	end,
	config = true,
}

return Plugin
