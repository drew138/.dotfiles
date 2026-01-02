local M = {
	"akinsho/toggleterm.nvim",
	version = "*",
	keys = function()
		return require("plugins.toggleterm-nvim.keys")
	end,
	config = true,
	init = function()
		-- Sync terminal highlights with editor
		vim.api.nvim_set_hl(0, "Terminal", { link = "Normal" })
		vim.api.nvim_set_hl(0, "TermCursor", { link = "Cursor" })
		vim.api.nvim_set_hl(0, "TermCursorNC", { link = "CursorLine" })

		-- Sync ToggleTerm floating window
		vim.api.nvim_set_hl(0, "ToggleTermNormal", { link = "Normal" })
		vim.api.nvim_set_hl(0, "ToggleTermBorder", { link = "FloatBorder" })
	end,
}

return M
