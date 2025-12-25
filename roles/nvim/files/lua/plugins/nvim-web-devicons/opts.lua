local M = {
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
        sh = {
            icon = "",
            color = "#89e051",
            cterm_color = "113",
            name = "Shell",
        },
        [".yamllint"] = {
            icon = "",
            color = "#6d8086",
            name = "Yaml",
        },
	},
}

return M
