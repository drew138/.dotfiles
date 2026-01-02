local M = {
	{
		"<leader>a",
		":lua require('neogen').generate()<cr>",
		silent = true,
		desc = "generate anotation",
	},
}

return M
