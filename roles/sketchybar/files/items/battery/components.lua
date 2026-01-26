local sketchybar = require("sketchybar")
local opts = require("items.battery.opts")

local M = {
	battery = sketchybar.add("item", opts.items.battery.name, opts.items.battery.properties),
	remaining_time = sketchybar.add("item", opts.items.remaining_time.properties),
	battery_bracket = sketchybar.add(
		"bracket",
		opts.brackets.battery_bracket.name,
		opts.brackets.battery_bracket.item_names,
		opts.brackets.battery_bracket.properties
	),
	padding_left = sketchybar.add("item", opts.items.battery_space_left.name, opts.items.battery_space_left.properties),
}

return M
