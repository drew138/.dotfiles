local sketchybar = require("sketchybar")
local opts = require("items.spaces.opts")

local M = {
	workspaces = {},
	workspaces_popups = {},
}

for _, aerospace_workspace_name in ipairs(opts.aerospace_workspaces_names) do
	local workspace_opts = opts.create_default_workspace_opts(aerospace_workspace_name)
	local workspace = sketchybar.add("item", workspace_opts.name, workspace_opts.properties)

	table.insert(M.workspaces, workspace)
end

local workspace_bracket_opts = opts.create_default_workspace_bracket_opts()

M.workspace_bracket = sketchybar.add("bracket", workspace_bracket_opts.item_names, workspace_bracket_opts.properties)

M.workspace_window_observer = sketchybar.add("item", opts.items.workspace_window_observer.properties)
M.workspaces_indicator = sketchybar.add("item", opts.items.workspaces_indicator.properties)

return M
