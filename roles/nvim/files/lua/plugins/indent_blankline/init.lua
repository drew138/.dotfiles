local Plugin = {
	"lukas-reineke/indent-blankline.nvim",
	dependencies = { { "EdenEast/nightfox.nvim" } },
	main = "ibl",
	init = function()
		vim.opt.list = true
		vim.opt.termguicolors = false
		vim.opt.listchars:append("eol:↴")
	end,
	config = true,
}
return Plugin
