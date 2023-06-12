local Plugin = {
	"L3MON4D3/LuaSnip",
	build = "make install_jsregexp",
	version = "1.*",
	opts = function()
		return require("options.luasnip")
	end,
	config = true,
	keys = function()
		return require("keys.luasnip")
	end,
}

return Plugin
