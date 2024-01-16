local Plugin = {
	"stevearc/conform.nvim",
	event = { "BufReadPre", "BufNewFile" },
	opts = function()
		return require("plugins.conform.opts")
	end,
	config = true,
}

return Plugin
