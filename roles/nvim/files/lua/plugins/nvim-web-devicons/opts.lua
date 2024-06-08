local Opts = {
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
	},
}

return Opts
