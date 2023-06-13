local builtin = require("telescope.builtin")

local Keys = {
	{ "<leader>ff", builtin.find_files, desc = "open files picker" },
	{ "<leader>fg", builtin.live_grep, desc = "open grep picker" },
	{ "<leader>fb", builtin.buffers, desc = "open active buffers picker" },
	{ "<leader>fh", builtin.help_tags, desc = "open help tags picker" },
	{ "<leader>fd", builtin.diagnostics, desc = "open diagnostics finder" }, --[[ TODO apply picker config to this ]]
}

return Keys
