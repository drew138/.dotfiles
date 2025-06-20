local diagnostic = vim.diagnostic

local M = {
	{
		"<c-s>",
		diagnostic.open_float,
		desc = "show diagnostic",
	},
	{
		"K",
		diagnostic.goto_prev,
		desc = "go to previous diagnostic",
	},
	{
		"J",
		diagnostic.goto_next,
		desc = "go to next diagnostic",
	},
}

return M
