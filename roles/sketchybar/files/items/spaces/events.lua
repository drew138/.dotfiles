local sketchybar = require("sketchybar")
local theme = require("theme")

local aerospace_workspace_change_event = "aerospace_workspace_change"

local M = {}

function M.configure_workspaces_indicator()
	M.workspaces_indicator:subscribe("swap_menus_and_spaces", function(_)
		local currently_on = M.workspaces_indicator:query().icon.value == theme.icons.switch.on
		M.workspaces_indicator:set({
			icon = currently_on and theme.icons.switch.off or theme.icons.switch.on,
		})
	end)

	M.workspaces_indicator:subscribe("mouse.entered", function(_)
		sketchybar.animate("tanh", 30, function()
			M.workspaces_indicator:set({
				background = {
					color = { alpha = 1.0 },
					border_color = { alpha = 1.0 },
				},
				icon = { color = theme.colors.bg1 },
				label = { width = "dynamic" },
			})
		end)
	end)

	M.workspaces_indicator:subscribe("mouse.exited", function(_)
		sketchybar.animate("tanh", 30, function()
			M.workspaces_indicator:set({
				background = {
					color = { alpha = 0.0 },
					border_color = { alpha = 0.0 },
				},
				icon = { color = theme.colors.magenta },
				label = { width = 0 },
			})
		end)
	end)

	M.workspaces_indicator:subscribe("mouse.clicked", function(_)
		sketchybar.trigger("swap_menus_and_spaces")
	end)
end

function M.configure_workspaces()
	for _, workspace in ipairs(M.workspaces) do
		workspace:subscribe("mouse.clicked", function(env)
			sketchybar.exec("aerospace " .. env.NAME:gsub("%.", " "))
		end)

		workspace:subscribe("mouse.exited", function(_)
			workspace:set({ popup = { drawing = false } })
		end)

		workspace:subscribe(aerospace_workspace_change_event, function(env)
			-- local color = theme.colors.bg1
			local color = theme.colors.bg1
			-- local label_color = theme.colors.grey
			local label_color = theme.colors.blue
			-- print(env.FOCUSED_WORKSPACE)
			if workspace.name == "workspace." .. env.FOCUSED_WORKSPACE then
				color = theme.colors.bg2
				-- label_color = theme.colors.blue
				-- label_color = 0xff5e81ac
				label_color = theme.colors.orange
				-- label_color = 0xff3fa7a1
				-- label_color = 0xff7a5fa1
				-- label_color = 0xffc89b3c
				-- label_color = theme.colors.white
			end
			workspace:set({
				background = { color = color, border_color = color },
				label = {
					color = label_color,
				},
			})
		end)
	end
end

function M.define_initial_workspace()
	sketchybar.delay(0.05, function()
		sketchybar.exec("aerospace list-workspaces --focused", function(result)
			sketchybar.trigger(aerospace_workspace_change_event, {
				FOCUSED_WORKSPACE = result:match("^%s*(.-)%s*$"), -- remove trailing spaces/returns
			})
		end)
	end)
end

function M.setup(components)
	sketchybar.add("event", aerospace_workspace_change_event)
	M.workspaces = components.workspaces
	M.workspaces_brackets = components.workspaces_brackets
	M.workspaces_spaces_right = components.workspaces_spaces_right
	M.workspaces_popups = components.workspaces_popups
	M.workspace_window_observer = components.workspace_window_observer
	M.workspaces_indicator = components.workspaces_indicator

	M.configure_workspaces_indicator()
	M.configure_workspaces()
	M.define_initial_workspace()
end

return M
