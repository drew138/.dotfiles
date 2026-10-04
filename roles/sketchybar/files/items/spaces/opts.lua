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
	"a",
	"s",
	"d",
	"z",
}

M.workspace_apps = {
	["1"] = "WezTerm",
	["2"] = "Google Chrome",
	["3"] = "Slack",
	["4"] = "Postman",
	["q"] = "Notion",
	["w"] = "WhatsApp",
	["e"] = "Marta",
	["a"] = "Bitwarden",
	["s"] = "OBS",
	["d"] = "Discord",
}

M.workspace_icons = {
	["1"] = app_icons["WezTerm"],
	["2"] = app_icons["Google Chrome"],
	["3"] = app_icons["Slack"],
	["4"] = app_icons["Postman"],
	["q"] = app_icons["Notion"],
	["w"] = app_icons["WhatsApp"],
	["e"] = app_icons["Marta"],
	["a"] = app_icons["Bitwarden"],
	["s"] = app_icons["OBS"],
	["d"] = app_icons["Discord"],
	["z"] = app_icons["Desktop"],
}

M.items = {
	workspace_window_observer = {
		properties = {
			drawing = false,
			updates = true,
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
				color = theme.colors.grey,
				highlight_color = theme.colors.grey,
				font = "sketchybar-app-font:Regular:19.0",
			},
			padding_right = 1,
			padding_left = 1,
			background = {
				height = 30,
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
				height = 34,
				border_width = 2,
			},
		},
	}
end

return M
