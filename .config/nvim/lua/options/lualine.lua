local Opts = {
	sections = {
		lualine_c = {
			{
				"filename",
				path = 1,
			},
		},
	},
	options = {
		disabled_filetypes = {
			statusline = { "NvimTree" },
		},
	},
}

return Opts
