local M = {
	"smjonas/inc-rename.nvim",
	opts = {},

	-- dependencies = {
	-- 	{ "nvim-lua/plenary.nvim" },
	-- },
	-- branch = "master",
	-- config = true,
	-- init = function()
	-- 	local set = vim.keymap.set
	-- 	set("n", "<c-e>", require("renamer").rename, { noremap = true, silent = true })
	-- end,
	keys = function()
		return require("plugins.inc-rename-nvim.keys")
	end,
}

return M
