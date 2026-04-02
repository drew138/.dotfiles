local theme = require("theme")

local M = {}

M.items = {
	calendar_space_right = {
		properties = { position = "right", width = theme.settings.group_paddings },
	},
	calendar = {
		name = "calendar",
		properties = {
			icon = {
				color = theme.colors.cyan,
				padding_left = 8,
				font = {
					style = theme.settings.font.style_map["Black"],
					size = 12.0,
				},
			},
			label = {
				color = theme.colors.cyan,
				padding_right = 8,
				width = 49,
				align = "right",
				font = {
					style = theme.settings.font.style_map["Black"],
					size = 12.0,
				},
			},
			position = "right",
			update_freq = 30,
			padding_left = 1,
			padding_right = 1,
			background = {
				color = theme.colors.bg1,
				border_color = theme.colors.transparent,
				border_width = 2,
			},
		},
	},
	calendar_space_left = {
		properties = { position = "right", width = theme.settings.group_paddings },
	},
}

M.brackets = {
	calendar_bracket = {
		item_names = { M.items.calendar.name },
		properties = {
			background = {
				color = theme.colors.transparent,
				height = 30,
				border_color = theme.colors.bg2,
			},
		},
	},
}

return M
