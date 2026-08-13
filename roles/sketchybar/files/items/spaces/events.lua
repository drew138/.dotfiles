local sketchybar = require("sketchybar")
local theme = require("theme")
local opts = require("items.spaces.opts")

local aerospace_workspace_change_event = "aerospace_workspace_change"

local M = {}

M.app_is_open = {}
M.focused_workspace = nil

local function paint(workspace_name)
	local workspace = M.workspace_by_name[workspace_name]
	if not workspace then
		return
	end

	local is_focused = workspace_name == M.focused_workspace
	local background_color = is_focused and theme.colors.bg2 or theme.colors.bg1

	local label_color = theme.colors.grey
	if M.app_is_open[workspace_name] then
		label_color = is_focused and theme.colors.orange or theme.colors.blue
	end

	workspace:set({
		background = { color = background_color, border_color = background_color },
		label = { color = label_color },
	})
end

local function paint_all()
	for _, workspace_name in ipairs(opts.aerospace_workspaces_names) do
		paint(workspace_name)
	end
end

function M.refresh_open_state()
	sketchybar.exec("aerospace list-windows --all --format '%{workspace}|%{app-name}'", function(result)
		local apps_present = {}

		for line in string.gmatch(result or "", "[^\r\n]+") do
			local workspace_name, app_name = line:match("^%s*(.-)%s*|%s*(.-)%s*$")
			if workspace_name and app_name and app_name ~= "" then
				apps_present[workspace_name] = apps_present[workspace_name] or {}
				apps_present[workspace_name][app_name] = true
			end
		end

		for _, workspace_name in ipairs(opts.aerospace_workspaces_names) do
			local present = apps_present[workspace_name]
			local main_app = opts.workspace_apps[workspace_name]

			if main_app then
				M.app_is_open[workspace_name] = (present and present[main_app]) == true
			else
				M.app_is_open[workspace_name] = present ~= nil
			end
		end

		paint_all()
	end)
end

function M.configure_workspaces()
	for workspace_name, workspace in pairs(M.workspace_by_name) do
		workspace:subscribe("mouse.clicked", function(_)
			sketchybar.exec("aerospace workspace " .. workspace_name)
		end)
	end
end

function M.configure_observer()
	M.workspace_window_observer:subscribe(aerospace_workspace_change_event, function(env)
		if env.FOCUSED_WORKSPACE and env.FOCUSED_WORKSPACE ~= "" then
			M.focused_workspace = env.FOCUSED_WORKSPACE
		end
		M.refresh_open_state()
	end)

	M.workspace_window_observer:subscribe("front_app_switched", function(_)
		M.refresh_open_state()
	end)
end

function M.define_initial_workspace()
	sketchybar.delay(0.05, function()
		sketchybar.exec("aerospace list-workspaces --focused", function(result)
			M.focused_workspace = result:match("^%s*(.-)%s*$") -- remove trailing spaces/returns
			M.refresh_open_state()
		end)
	end)
end

function M.setup(components)
	sketchybar.add("event", aerospace_workspace_change_event)

	M.workspaces = components.workspaces
	M.workspace_by_name = components.workspace_by_name
	M.workspace_window_observer = components.workspace_window_observer

	M.configure_workspaces()
	M.configure_observer()
	M.define_initial_workspace()
end

return M
