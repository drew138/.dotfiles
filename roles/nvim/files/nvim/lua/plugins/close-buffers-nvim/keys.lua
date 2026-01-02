local M = {
	{
		"<leader>kh",
		"<cmd>lua require('close_buffers').delete({type = 'hidden', force = true })<cr>",
		desc = "delete all non-visible buffers",
	},
	{
		"<leader>kt",
		"<cmd>lua require('close_buffers').delete({type = 'this'})<cr>",
		desc = "delete the current buffer",
	},
	{
		"<leader>ka",
		"<cmd>lua require('close_buffers').delete({type = 'all'})<cr>",
		desc = "delete all buffers",
	},
}

return M
