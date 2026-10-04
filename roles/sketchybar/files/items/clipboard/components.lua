local sketchybar = require("sketchybar")
local opts = require("items.clipboard.opts")

local M = {
	rows = {},
}

M.gap = sketchybar.add("item", opts.gap_name, opts.items.gap.properties)
M.clipboard = sketchybar.add("item", opts.name, opts.items.clipboard.properties)

for index = 1, opts.maximum_rows do
	local row_opts = opts.create_row_opts(index)

	table.insert(M.rows, sketchybar.add("item", row_opts.name, row_opts.properties))
end

local bracket_opts = opts.create_bracket_opts()

M.bracket = sketchybar.add("bracket", bracket_opts.item_names, bracket_opts.properties)

return M
