local sketchybar = require("sketchybar")
local opts = require("items.cpu.opts")

-- Execute the event provider binary which provides the event "cpu_update" for
-- the cpu load data, which is fired every 2.0 seconds.
sketchybar.exec("killall cpu_load >/dev/null; $CONFIG_DIR/helpers/event_providers/cpu_load/bin/cpu_load cpu_update 2.0")

local M = {
	cpu = sketchybar.add("item", opts.items.cpu.name, opts.items.cpu.length, opts.items.cpu.properties),
	cpu_bracket = sketchybar.add(
		"bracket",
		opts.brackets.cpu_bracket.name,
		opts.brackets.cpu_bracket.item_names,
		opts.brackets.cpu_bracket.properties
	),
	cpu_padding_left = sketchybar.add("item", opts.items.cpu_padding_left.name, opts.items.cpu_padding_left.properties),
}

return M
