local theme = require("theme")

local M = {}

local home = os.getenv("HOME") or ""

M.name = "clipboard"
M.base_row_name = "clipboard.row."
M.gap_name = "clipboard.gap"
M.gap_width = 7
M.update_event = "clipboard_update"

M.maximum_rows = 15
M.row_max_length = 20
M.popup_close_delay = 0.15

M.store_path = home .. "/.cache/sketchybar/clipboard.tsv"
M.copy_command = home .. "/.config/sketchybar/helpers/clipboard_copy.lua "

-- Must not go through os.execute: that blocks the config before its items are registered.
M.watcher_command = home .. "/.local/bin/clipwatch >/dev/null 2>&1 &"

M.items = {
	gap = {
		properties = {
			position = "right",
			width = M.gap_width,
			padding_left = 0,
			padding_right = 0,
			icon = { drawing = false },
			label = { drawing = false },
			background = { drawing = false },
		},
	},

	clipboard = {
		properties = {
			position = "right",
			icon = {
				string = theme.icons.clipboard,
				color = theme.colors.blue,
				padding_left = 8,
				padding_right = 8,
				font = {
					family = theme.settings.font.text,
					style = theme.settings.font.style_map["Regular"],
					size = 16.0,
				},
			},
			label = { drawing = false },
			padding_left = 1,
			padding_right = 1,
			background = {
				color = theme.colors.bg1,
				border_color = theme.colors.bg1,
				height = 30,
			},
			popup = {
				background = {
					color = theme.colors.bg1,
					border_color = theme.colors.bg2,
					border_width = 2,
					corner_radius = 6,
				},
				align = "right",
				horizontal = false,
			},
		},
	},
}

function M.create_row_opts(index)
	return {
		name = M.base_row_name .. index,
		properties = {
			position = "popup." .. M.name,
			drawing = false,
			click_script = M.copy_command .. index,
			icon = {
				string = tostring(index),
				color = theme.colors.blue,
				padding_left = 10,
				padding_right = 8,
				font = {
					family = theme.settings.font.nerd,
					style = theme.settings.font.style_map["Bold"],
					size = 12.5,
				},
			},
			label = {
				string = "",
				color = theme.colors.white or theme.colors.grey,
				padding_right = 12,
				font = {
					family = theme.settings.font.text,
					style = theme.settings.font.style_map["Regular"],
					size = 14.0,
				},
			},
			background = { drawing = false },
		},
	}
end

function M.create_bracket_opts()
	return {
		item_names = { M.name },
		properties = {
			position = "right",
			background = {
				color = theme.colors.bg1,
				border_color = theme.colors.bg2,
				height = 34,
				border_width = 2,
			},
		},
	}
end

return M
