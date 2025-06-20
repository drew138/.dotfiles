local M = {
	{
		"<c-b>",
		"<cmd>lua require'neotest'.summary.toggle()<cr>",
		silent = true,
		remap = false,
		desc = "open neotest summary",
	},
}

return M
