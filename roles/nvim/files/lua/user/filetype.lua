vim.filetype.add({
	filename = {
		[".yamllint"] = "yaml",
		sketchybarrc = "bash",
		bordersrc = "bash",
	},
	extension = {
		gitconfig = "gitconfig",
	},
	pattern = {
		["[Dd]ockerfile.*"] = "dockerfile",
		[".gitignore.*"] = "gitignore",
	},
})
