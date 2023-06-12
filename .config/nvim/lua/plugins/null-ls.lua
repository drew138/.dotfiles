-- TODO review this
local Plugin = {
	"jose-elias-alvarez/null-ls.nvim",
	opts = function()
		return require("options.null-ls")
	end,
}

return Plugin
