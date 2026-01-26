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
				color = theme.colors.white,
				padding_left = 8,
				font = {
					style = theme.settings.font.style_map["Black"],
					size = 12.0,
				},
			},
			label = {
				color = theme.colors.white,
				padding_right = 8,
				width = 49,
				align = "right",
				font = { family = theme.settings.font.numbers },
			},
			position = "right",
			update_freq = 30,
			padding_left = 1,
			padding_right = 1,
			background = {
				color = theme.colors.bg2,
				border_color = theme.colors.black,
				border_width = 1,
			},
			click_script = "open -a 'Notion Calendar'",
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
				border_color = theme.colors.grey,
			},
		},
	},
}

return M
