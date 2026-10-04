local theme = require("theme")

local M = {}

M.name = "herdr"
M.base_slot_name = "herdr.slot."
M.gap_name = "herdr.gap"
M.gap_width = 7
M.maximum_slots = 16
M.update_event = "herdr_update"
M.thinking_interval = 0.38
M.thinking_ticks = 9
M.thinking_dim_alpha = 0x80
M.bounce_interval = 0.2
M.bounce_offset = 3
M.bounce_ticks = 5
M.animation_phase = 0.19
M.animation_drift = 0.07
M.appear_ticks = 15
M.disappear_ticks = 14
M.appear_offset = 6
M.width_ticks = 14
M.width_seconds = 0.26
M.disappear_seconds = 0.26
M.icon_y_offset = 0

M.glyphs = {
	idle = "\u{f167a}",
	done = "\u{f1719}",
	blocked = "\u{f169f}",
	thinking = {
		"\u{f167a}",
		"\u{f06a9}",
	},
}

M.binary = table.concat({
	"env",
	"HOME=" .. (os.getenv("HOME") or ""),
	"PATH=/opt/homebrew/bin:" .. (os.getenv("HOME") or "") .. "/.local/bin:/usr/bin:/bin",
	"herdr",
}, " ")

M.cache_path = (os.getenv("HOME") or "") .. "/.cache/sketchybar/herdr.txt"
M.poll_command = (os.getenv("HOME") or "") .. "/.config/sketchybar/helpers/herdr_poll.lua >/dev/null 2>&1 &"
M.label_separator = " - "

-- sketchybar reports no usable geometry per item, so slot widths are measured from
-- rendered labels instead of queried.
M.slot_base_width = 30
M.slot_character_width = 7.1
M.overflow_width = 52
M.label_max_length = 14

M.state_colors = {
	done = theme.colors.green,
	blocked = theme.colors.orange,
	working = theme.colors.blue,
	idle = theme.colors.grey,
	unknown = theme.colors.grey,
}

M.items = {
	gap = {
		properties = {
			position = "right",
			update_freq = 30,
			width = M.gap_width,
			padding_left = 0,
			padding_right = 0,
			icon = {
				drawing = false,
			},
			label = {
				drawing = false,
			},
			background = {
				drawing = false,
			},
		},
	},

	herdr = {
		properties = {
			position = "right",
			update_freq = 30,
			icon = {
				string = M.glyphs.idle,
				color = theme.colors.grey,
				padding_left = 7,
				padding_right = 7,
				font = {
					family = theme.settings.font.nerd,
					style = theme.settings.font.style_map["Regular"],
					size = 17.0,
				},
			},
			label = {
				string = "",
				color = theme.colors.grey,
				padding_left = 0,
				padding_right = 0,
			},
			padding_left = 2,
			padding_right = 2,
			background = {
				color = theme.colors.bg1,
				border_color = theme.colors.bg1,
				height = 30,
			},
		},
	},
}

function M.create_bracket_opts()
	local names = { M.name }

	for index = 1, M.maximum_slots do
		table.insert(names, M.base_slot_name .. index)
	end

	return {
		item_names = names,
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

function M.create_slot_opts(index)
	return {
		name = M.base_slot_name .. index,
		properties = {
			position = "right",
			drawing = false,
			padding_left = 2,
			padding_right = 2,
			icon = {
				string = M.glyphs.idle,
				color = theme.colors.grey,
				y_offset = M.icon_y_offset,
				padding_left = 7,
				padding_right = 4,
				font = {
					family = theme.settings.font.nerd,
					style = theme.settings.font.style_map["Regular"],
					size = 17.0,
				},
			},
			label = {
				string = "",
				color = theme.colors.grey,
				padding_left = 0,
				padding_right = 7,
				font = {
					family = theme.settings.font.text,
					style = theme.settings.font.style_map["Bold"],
					size = 12.0,
				},
			},
			background = {
				color = theme.colors.bg1,
				border_color = theme.colors.bg1,
				height = 30,
			},
		},
	}
end

return M
