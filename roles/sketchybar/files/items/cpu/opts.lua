local theme = require("theme")
local M = {}

M.items = {
	cpu_padding_left = {
		name = "widgets.cpu.padding",
		properties = {
			position = "right",
			width = theme.settings.group_paddings,
		},
	},

	cpu = {
		name = "widgets.cpu",
		length = 42,
		properties = {
			position = "right",
			icon = {
				string = theme.icons.cpu,
				color = theme.colors.blue,
			},
			label = {

				string = "??%",
				font = {
					family = theme.settings.font.numbers,
					style = theme.settings.font.style_map["Bold"],
					size = 13.0,
				},
				align = "right",
				padding_right = 0,
			},
			padding_right = theme.settings.paddings + 6,
		},
	},
}

M.brackets = {
	cpu_bracket = {
		name = M.items.cpu.name .. ".bracket",
		item_names = { M.items.cpu.name },
		properties = {
			background = { color = theme.colors.bg1 },
		},
	},
}

return M
