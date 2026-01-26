local theme = require("theme")

local M = {}

M.popup_width = 250

M.items = {
	wifi_up = {
		name = "widgets.wifi_up",
		properties = {
			position = "right",
			padding_left = -5,
			-- width = 0,
			icon = {
				padding_right = 0,
				font = {
					style = theme.settings.font.style_map["Bold"],
					size = 9.0,
				},
				string = theme.icons.wifi.upload,
			},
			label = {
				font = {
					family = theme.settings.font.numbers,
					style = theme.settings.font.style_map["Bold"],
					size = 12.0,
				},
				color = theme.colors.red,
				string = "??? Bps",
			},
		},
	},
	wifi_down = {
		name = "widgets.wifi_down",
		properties = {
			position = "right",
			padding_left = -5,
			icon = {
				padding_right = 0,
				font = {
					style = theme.settings.font.style_map["Bold"],
					size = 9.0,
				},
				string = theme.icons.wifi.download,
			},
			label = {
				font = {
					family = theme.settings.font.numbers,
					style = theme.settings.font.style_map["Bold"],
					size = 12.0,
				},
				color = theme.colors.blue,
				string = "??? Bps",
			},
		},
	},
	wifi_space_right = {
		name = "widgets.wifi.padding",
		properties = {
			position = "right",
			label = { drawing = false },
		},
	},
}

M.brackets = {
	wifi_bracket = {
		name = "widgets.wifi.bracket",
		item_names = { M.items.wifi_space_right.name, M.items.wifi_up.name, M.items.wifi_down.name },
		properties = {
			background = { color = theme.colors.bg1 },
			popup = { align = "center", height = 30 },
		},
	},
}

M.items.ssid = {
	properties = {
		position = "popup." .. M.brackets.wifi_bracket.name,
		icon = {
			font = {
				style = theme.settings.font.style_map["Bold"],
			},
			string = theme.icons.wifi.router,
		},
		width = M.popup_width,
		align = "center",
		label = {
			font = {
				size = 15,
				style = theme.settings.font.style_map["Bold"],
			},
			max_chars = 18,
			string = "????????????",
		},
		background = {
			height = 2,
			color = theme.colors.grey,
			y_offset = -15,
		},
	},
}

M.items.hostname = {
	properties = {
		position = "popup." .. M.brackets.wifi_bracket.name,
		icon = {
			align = "left",
			string = "Hostname:",
			width = M.popup_width / 2,
		},
		label = {
			max_chars = 20,
			string = "????????????",
			width = M.popup_width / 2,
			align = "right",
		},
	},
}

M.items.ip = {
	properties = {
		position = "popup." .. M.brackets.wifi_bracket.name,
		icon = {
			align = "left",
			string = "IP:",
			width = M.popup_width / 2,
		},
		label = {
			string = "???.???.???.???",
			width = M.popup_width / 2,
			align = "right",
		},
	},
}

M.items.mask = {
	properties = {
		position = "popup." .. M.brackets.wifi_bracket.name,
		icon = {
			align = "left",
			string = "Subnet mask:",
			width = M.popup_width / 2,
		},
		label = {
			string = "???.???.???.???",
			width = M.popup_width / 2,
			align = "right",
		},
	},
}

M.items.router = {
	properties = {
		position = "popup." .. M.brackets.wifi_bracket.name,
		icon = {
			align = "left",
			string = "Router:",
			width = M.popup_width / 2,
		},
		label = {
			string = "???.???.???.???",
			width = M.popup_width / 2,
			align = "right",
		},
	},
}

M.items.wifi_space_left = {
	properties = { position = "right", width = theme.settings.group_paddings },
}

return M
