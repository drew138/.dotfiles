local Plugin = {
	"tpope/vim-fugitive",
	dependencies = { { "EdenEast/nightfox.nvim" } },
	keys = function()
		return require("keys.vim-fugitive")
	end,
}

return Plugin
