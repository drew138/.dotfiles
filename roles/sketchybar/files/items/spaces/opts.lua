local theme = require("theme")
local app_icons = require("helpers.app_icons")

local M = {}

M.base_workspace_name = "workspace."

M.aerospace_workspaces_names = {
	"1",
	"2",
	"3",
	"4",
	"q",
	"w",
	"e",
}

M.workspace_icons = {
	["1"] = app_icons["WezTerm"],
	["2"] = app_icons["Vivaldi"],
	["3"] = app_icons["Slack"],
	["4"] = app_icons["Postman"],
	["q"] = app_icons["Notion"],
	["w"] = app_icons["Bitwarden"],
	["e"] = app_icons["Desktop"],
}

M.items = {
	workspace_window_observer = {
		properties = {
			drawing = false,
			updates = true,
		},
	},
	workspaces_indicator = {
		properties = {
			padding_left = -3,
			padding_right = 0,
			icon = {
				padding_left = 8,
				padding_right = 9,
				color = theme.colors.magenta,
				string = theme.icons.switch.on,
			},
			label = {
				width = 0,
				padding_left = 0,
				padding_right = 8,
				string = "Spaces",
				color = theme.colors.bg1,
			},
			background = {
				color = theme.colors.with_alpha(theme.colors.grey, 0.0),
				border_color = theme.colors.with_alpha(theme.colors.bg1, 0.0),
			},
		},
	},
}

function M.create_default_workspace_opts(i)
	return {
		name = M.base_workspace_name .. i,
		properties = {
			label = {
				string = M.workspace_icons[i],
				padding_right = 6,
				padding_left = 1,
				color = theme.colors.blue,
				highlight_color = theme.colors.grey,
				font = "sketchybar-app-font:Regular:16.0",
			},
			padding_right = 1,
			padding_left = 1,
			background = {
				height = 24,
			},
		},
	}
end

function M.create_default_workspace_bracket_opts()
	local workspace_item_names = {}
	for _, aerospace_workspace_name in ipairs(M.aerospace_workspaces_names) do
		table.insert(workspace_item_names, M.base_workspace_name .. aerospace_workspace_name)
	end
	return {
		item_names = workspace_item_names,
		properties = {
			background = {
				color = theme.colors.bg1,
				border_color = theme.colors.bg2,
				height = 28,
				border_width = 2,
			},
		},
	}
end

return M
