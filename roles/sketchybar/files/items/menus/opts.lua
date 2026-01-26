local theme = require("theme")
local M = {}

M.max_menu_items = 15

M.items = {
	menu_watcher = {
		properties = {
			drawing = false,
			updates = false,
		},
	},
	space_menu_swap = {
		properties = {
			drawing = false,
			updates = true,
		},
	},
	menu_padding = {
		name = "menu.padding",
		properties = {
			drawing = false,
			width = 5,
		},
	},
}

function M.create_menu_items_properties()
	for i = 1, M.max_menu_items, 1 do
		M.items["menu_" .. i] = {
			name = "menu." .. i,
			properties = {
				padding_left = theme.settings.paddings,
				padding_right = theme.settings.paddings,
				drawing = false,
				icon = { drawing = false },
				label = {
					font = {
						style = theme.settings.font.style_map[i == 1 and "Heavy" or "Semibold"],
					},
					padding_left = 6,
					padding_right = 6,
				},
				click_script = "$CONFIG_DIR/helpers/menus/bin/menus -s " .. i,
			},
		}
	end
end

M.create_menu_items_properties()

M.brackets = {
	menus_bracket = {
		item_names = { "/menu\\..*/" },
		properties = {
			background = { color = theme.colors.bg1 },
		},
	},
}

return M
