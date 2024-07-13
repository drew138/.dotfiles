local Keys = {
	{
		"<leader>co",
		"<Plug>(git-conflict-ours)",
		desc = "open files picker",
	},
	{
		"<leader>ct",
		"<Plug>(git-conflict-theirs)",
		desc = "open grep picker",
	},
	{
		"<leader>cb",
		"<Plug>(git-conflict-both)",
		desc = "open active buffers picker",
	},
}

return Keys
