local theme = require("theme")

local M = {}

M.items = {
	apple_space_left = {
		properties = { width = 5 },
	},

	apple = {
		name = "apple",
		properties = {
			icon = {
				font = { size = 16.0 },
				string = theme.icons.apple,
				padding_right = 8,
				padding_left = 8,
			},
			label = { drawing = false },
			background = {
				color = theme.colors.bg2,
				border_color = theme.colors.black,
				border_width = 1,
			},
			padding_left = 1,
			padding_right = 1,
			click_script = "$CONFIG_DIR/helpers/menus/bin/menus -s 0",
		},
	},
	apple_space_right = {
		properties = { width = 7 },
	},
}

M.brackets = {
	apple_bracket = {
		item_names = { M.items.apple.name },
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
