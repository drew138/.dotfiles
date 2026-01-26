local M = {
	override_by_extension = {
		yml = {
			icon = "",
			color = "#ff69b4",
			name = "Yml",
		},
	},
	override_by_filename = {
		[".gitignore_global"] = {
			icon = "",
			color = "#f1502f",
			name = "GitignoreGlobal",
		},
		["sketchybarrc"] = {
			icon = "",
			color = "#81b29a",
			name = "sketchybarrc",
		},
		["bordersrc"] = {
			icon = "",
			color = "#81b29a",
			name = "bordersrc",
		},
		["work.zsh"] = {
			icon = "",
			color = "#81b29a",
			name = "ZshWork",
		},
		["work.gitconfig"] = {
			icon = "",
			color = "#F14C28",
			name = "WorkGitConfig",
		},
		[".gitconfig"] = {
			icon = "",
			color = "#F14C28",
			name = "GitConfig",
		},
		sh = {
			icon = "",
			color = "#81b29a",
			name = "Shell",
		},
		[".zshrc"] = {
			icon = "",
			color = "#81b29a",
			name = "Shell",
		},
		[".yamllint"] = {
			icon = "",
			color = "#1abc9c",
			name = "YamlLint",
		},
	},
}

return M
