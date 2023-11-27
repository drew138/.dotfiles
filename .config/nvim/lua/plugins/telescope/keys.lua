local Keys = {
	{ "<leader>ff", "<cmd>lua require'telescope.builtin'.find_files()<cr>", desc = "open files picker" },
	{ "<leader>fg", "<cmd>lua require'telescope.builtin'.live_grep()<cr>", desc = "open grep picker" },
	{ "<leader>fb", "<cmd>lua require'telescope.builtin'.buffers()<cr>", desc = "open active buffers picker" },
	{ "<leader>fh", "<cmd>lua require'telescope.builtin'.help_tags()<cr>", desc = "open help tags picker" },
	{ "<leader>fd", "<cmd>lua require'telescope.builtin'.diagnostics()<cr>", desc = "open diagnostics finder" },
	{
		"<leader>/",
		function()
			require("telescope.builtin").current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
				winblend = 10,
				previewer = false,
			}))
		end,
		desc = "open grep picker in current file",
	},
}

return Keys
