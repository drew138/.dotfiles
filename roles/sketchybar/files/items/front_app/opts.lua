local theme = require("theme")

local M = {}

M.items = {
	front_app = {
		name = "front_app",
		properties = {
			display = "active",
			icon = { drawing = false },
			label = {
				font = {
					style = theme.settings.font.style_map["Black"],
					size = 12.0,
				},
			},
			updates = true,
		},
	},
}

return M
