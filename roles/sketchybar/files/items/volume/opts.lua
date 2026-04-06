local theme = require("theme")
local M = {}

M.popup_width = 250

M.items = {
	volume_percent = {
		name = "widgets.volume1",
		properties = {
			position = "right",
			icon = { drawing = false },
			label = {
				string = "??%",
				padding_left = -1,
				color = theme.colors.cyan,
				font = { family = theme.settings.font.numbers },
			},
		},
	},
	volume_icon = {
		name = "widgets.volume2",
		properties = {
			position = "right",
			padding_right = -1,
			icon = {
				string = theme.icons.volume._100,
				width = 0,
				align = "left",
				color = theme.colors.grey,
				font = {
					style = theme.settings.font.style_map["Regular"],
					size = 14.0,
				},
			},
			label = {
				width = 25,
				align = "left",
				color = theme.colors.blue,
				font = {
					style = theme.settings.font.style_map["Regular"],
					size = 14.0,
				},
			},
		},
	},
	volume_space_right = {
		name = "widgets.volume.padding",
		properties = {
			position = "right",
			width = theme.settings.group_paddings,
		},
	},
}

M.brackets = {
	bracket = {
		name = "widgets.volume.bracket",
		properties = {
			background = { color = theme.colors.bg1 },
			popup = { align = "center" },
		},
	},
}

M.sliders = {
	slider = {
		properties = {
			position = "popup." .. M.brackets.bracket.name,
			slider = {
				highlight_color = theme.colors.blue,
				background = {
					height = 6,
					corner_radius = 3,
					color = theme.colors.bg2,
				},
				knob = {
					string = "􀀁",
					drawing = true,
				},
			},
			background = { color = theme.colors.bg1, height = 2, y_offset = -20 },
			click_script = 'osascript -e "set volume output volume $PERCENTAGE"',
		},
	},
}

return M
