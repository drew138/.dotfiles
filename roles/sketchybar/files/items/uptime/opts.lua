local theme = require("theme")

local M = {}

M.name = "uptime"
M.ram_name = "uptime.ram"
M.swap_name = "uptime.swap"
M.gap_name = "uptime.gap"
M.gap_width = 7

M.boot_command = "sysctl -n kern.boottime"
M.swap_command = "sysctl -n vm.swapusage"
M.ram_total_command = "sysctl -n hw.memsize"
M.ram_command = "vm_stat"

M.ram_warning = 0.5
M.ram_critical = 0.9
M.swap_warning = 0.001
M.swap_critical = 0.2

M.icon_font = {
	family = theme.settings.font.nerd,
	style = theme.settings.font.style_map["Regular"],
	size = 18.0,
}

M.label_font = {
	family = theme.settings.font.numbers,
	style = theme.settings.font.style_map["Semibold"],
	size = 14.0,
}

M.glyphs = {
	uptime = utf8.char(0xf05f6),
	ram = utf8.char(0xf035b),
	swap = utf8.char(0xf04e1),
}

local function stat_properties(glyph, icon_color)
	return {
		position = "right",
		icon = {
			string = glyph,
			color = icon_color,
			padding_left = 7,
			padding_right = 4,
			font = M.icon_font,
		},
		label = {
			string = "",
			color = icon_color,
			padding_left = 1,
			padding_right = 4,
			font = M.label_font,
		},
		padding_left = 0,
		padding_right = 0,
		background = {
			color = theme.colors.bg1,
			border_color = theme.colors.bg1,
			height = 30,
		},
	}
end

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

	uptime = {
		properties = (function()
			local properties = stat_properties(M.glyphs.uptime, theme.colors.blue)
			properties.update_freq = 60
			properties.padding_left = 1
			return properties
		end)(),
	},

	ram = {
		properties = stat_properties(M.glyphs.ram, theme.colors.green),
	},

	swap = {
		properties = (function()
			local properties = stat_properties(M.glyphs.swap, theme.colors.green)
			properties.label.padding_right = 8
			properties.padding_right = 1
			return properties
		end)(),
	},
}

function M.create_bracket_opts()
	return {
		item_names = { M.name, M.ram_name, M.swap_name },
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
