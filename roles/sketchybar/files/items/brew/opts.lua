local theme = require("theme")

local M = {}

M.name = "brew"
M.update_event = "brew_update"
M.started_event = "brew_upgrade_started"
M.finished_event = "brew_upgrade_finished"
M.spinner_interval = 0.12

M.icon_font = {
	family = "SF Pro",
	style = "Regular",
	size = 20.0,
}

M.spinner_font = {
	family = "JetBrainsMono Nerd Font",
	style = "Regular",
	size = 20.0,
}

M.spinner_frames = {
	"\u{f0a9e}",
	"\u{f0a9f}",
	"\u{f0aa0}",
	"\u{f0aa1}",
	"\u{f0aa2}",
	"\u{f0aa3}",
	"\u{f0aa4}",
	"\u{f0aa5}",
}

local helpers_directory = (os.getenv("HOME") or "") .. "/.config/sketchybar/helpers/"

M.outdated_cache = "/tmp/sketchybar-brew-outdated.txt"
M.outdated_command = helpers_directory .. "brew_outdated.sh &"

M.upgrade_all_command = table.concat({
	"/opt/homebrew/bin/sketchybar --trigger",
	M.started_event,
	"; " .. helpers_directory .. "brew_upgrade.sh &",
}, " ")

M.items = {
	brew = {
		properties = {
			position = "right",
			update_freq = 1800,
			icon = {
				string = theme.icons.brew,
				color = theme.colors.grey,
				padding_left = 8,
				padding_right = 6,
				font = M.icon_font,
			},
			label = {
				string = "0",
				color = theme.colors.grey,
				padding_left = 1,
				padding_right = 8,
			},
			padding_left = 1,
			padding_right = 1,
			background = {
				color = theme.colors.bg1,
				border_color = theme.colors.bg1,
				height = 30,
			},
		},
	},

}

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
