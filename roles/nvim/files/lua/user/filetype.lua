vim.filetype.add({
    filename = {
        [".yamllint"] = "yaml",
        sketchybarrc = "bash",
    },
	extension = {
		gitconfig = "gitconfig",
	},
	pattern = {
		["[Dd]ockerfile.*"] = "dockerfile",
		[".gitignore.*"] = "gitignore",
        ["sketchybarrc"] = "bash",
	},
})
