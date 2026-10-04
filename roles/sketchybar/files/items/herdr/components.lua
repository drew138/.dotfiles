local sketchybar = require("sketchybar")
local opts = require("items.herdr.opts")

local M = {
	slots = {},
}

M.gap = sketchybar.add("item", opts.gap_name, opts.items.gap.properties)
M.herdr = sketchybar.add("item", opts.name, opts.items.herdr.properties)

for index = 1, opts.maximum_slots do
	local slot_opts = opts.create_slot_opts(index)

	table.insert(M.slots, sketchybar.add("item", slot_opts.name, slot_opts.properties))
end

local bracket_opts = opts.create_bracket_opts()

M.bracket = sketchybar.add("bracket", bracket_opts.item_names, bracket_opts.properties)

return M
