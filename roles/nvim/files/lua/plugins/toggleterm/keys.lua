local function git_commit_toggle()
	local terminal = require("toggleterm.terminal").Terminal

	local git_commit = terminal:new({
		cmd = "~/.dotfiles/roles/scripts/files/conventional_commit.sh",
		dir = "git_dir",
		hidden = true,
		direction = "float",
		float_opts = {
			border = "curved",
			height = 15,
			width = 80,
		},
	})
	git_commit:toggle()
end

local M = {
	{
		"<leader>cc",
		git_commit_toggle,
		noremap = true,
		desc = "commit to git",
	},
}

return M
