local M = {
	{
		"<leader>ff",
		"<cmd>lua require'telescope.builtin'.find_files()<cr>",
		desc = "open files picker",
	},
	{
		"<leader>fg",
		"<cmd>lua require'telescope.builtin'.live_grep()<cr>",
		desc = "open grep picker",
	},
	{
		"<leader>fb",
		"<cmd>lua require'telescope.builtin'.buffers()<cr>",
		desc = "open active buffers picker",
	},
	{
		"<leader>fk",
		"<cmd>lua require'telescope.builtin'.keymaps()<cr>",
		desc = "open available keymaps finder",
	},
	{
		"<leader>fd",
		"<cmd>lua require'telescope.builtin'.diagnostics()<cr>",
		desc = "open diagnostics finder",
	},
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

return M
