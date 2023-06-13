local Plugin = {
	"jose-elias-alvarez/null-ls.nvim",
	opts = function()
		return require("plugins.null-ls.opts")
	end,
}

return Plugin
