local M = {
	"folke/trouble.nvim",
	init = function()
		vim.diagnostic.config({
			underline = {
				severity = vim.diagnostic.severity.ERROR,
			},
			virtual_text = {
				prefix = "",
			},
			signs = {
				text = {
					[vim.diagnostic.severity.ERROR] = " ",
					[vim.diagnostic.severity.WARN] = " ",
					[vim.diagnostic.severity.HINT] = " ",
					[vim.diagnostic.severity.INFO] = " ",
				},
			},
			update_in_insert = false,
			severity_sort = true,
			float = {
				show_header = false,
				source = "if_many",
				border = "rounded",
				focusable = true,
			},
		})
	end,
	keys = function()
		return require("plugins.trouble.keys")
	end,
}

return M
