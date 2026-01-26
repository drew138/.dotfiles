local theme = require("theme")

local M = {}

M.items = {
	battery = {
		name = "widgets.battery",
		properties = {
			position = "right",
			icon = {
				font = {
					style = theme.settings.font.style_map["Regular"],
					size = 19.0,
				},
			},
			label = {
				font = { family = theme.settings.font.numbers },
				color = theme.colors.cyan,
			},
			update_freq = 180,
			popup = { align = "center" },
		},
	},
}

M.items.remaining_time = {
	properties = {
		position = "popup." .. M.items.battery.name,
		icon = {
			string = "Time remaining:",
			width = 100,
			align = "left",
		},
		label = {
			string = "??:??h",
			width = 100,
			align = "right",
		},
	},
}

M.brackets = {
	battery_bracket = {
		name = "widgets.battery.bracket",
		item_names = { M.items.battery.name },
		properties = {
			background = { color = theme.colors.bg1 },
		},
	},
}

M.items.battery_space_left = {
	name = "widgets.battery.padding_left",
	properties = {
		position = "right",
		width = theme.settings.group_paddings,
	},
}

return M
