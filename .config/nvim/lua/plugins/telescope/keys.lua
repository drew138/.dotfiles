local Keys = {
	{ "<leader>ff", "<cmd>lua require'telescope.builtin'.find_files()<cr>", desc = "open files picker" },
	{ "<leader>fg", "<cmd>lua require'telescope.builtin'.live_grep()<cr>", desc = "open grep picker" },
	{ "<leader>fb", "<cmd>lua require'telescope.builtin'.buffers()<cr>", desc = "open active buffers picker" },
	{ "<leader>fh", "<cmd>lua require'telescope.builtin'.help_tags()<cr>", desc = "open help tags picker" },
	{ "<leader>fd", "<cmd>lua require'telescope.builtin'.diagnostics()<cr>", desc = "open diagnostics finder" },
}

return Keys
