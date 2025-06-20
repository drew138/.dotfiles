local M = {
	{
		"<leader>co",
		"<cmd>GitConflictChooseOurs<cr>",
		desc = "choose ours",
	},
	{
		"<leader>ct",
		"<cmd>GitConflictChooseTheirs<cr>",
		desc = "choose theirs",
	},
	{
		"<leader>cb",
		"<cmd>GitConflictChooseBoth<cr>",
		desc = "choose both",
	},
}

return M
