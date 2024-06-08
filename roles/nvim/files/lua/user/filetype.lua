vim.filetype.add({
	extension = {
		gitconfig = "gitconfig",
	},
	pattern = {
		["[Dd]ockerfile.*"] = "dockerfile",
		[".gitignore.*"] = "gitignore",
	},
})
