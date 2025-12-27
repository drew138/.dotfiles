local M = {
	"filipdutescu/renamer.nvim",
	dependencies = {
		{ "nvim-lua/plenary.nvim" },
	},
	branch = "master",
	config = true,
	init = function()
		local set = vim.keymap.set
		set("n", "<c-e>", require("renamer").rename, { noremap = true, silent = true })
	end,
}

return M
