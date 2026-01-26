local sketchybar = require("sketchybar")
local opts = require("items.calendar.opts")

local M = {}

M.calendar_space_right = sketchybar.add("item", opts.items.calendar_space_right.properties)

M.calendar = sketchybar.add("item", opts.items.calendar.name, opts.items.calendar.properties)

M.calendar_space_left =
	sketchybar.add("bracket", opts.brackets.calendar_bracket.item_names, opts.brackets.calendar_bracket.properties)

M.calendar_space_left = sketchybar.add("item", opts.items.calendar_space_left.properties)

return M
