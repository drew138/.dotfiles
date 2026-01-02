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
		["dockerfile.runtime"] = {
			icon = "󰡨",
			color = "#458ee6",
			cterm_color = "68",
			name = "Dockerfile",
		},
		["sketchybarrc"] = {
			icon = "",
			color = "#89e051",
			cterm_color = "113",
			name = "sketchybarrc",
		},
		["bordersrc"] = {
			icon = "",
			color = "#89e051",
			cterm_color = "113",
			name = "bordersrc",
		},
		["work.zsh"] = {
			icon = "",
			color = "#89E051",
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
			color = "#89e051",
			cterm_color = "113",
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
