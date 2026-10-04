local sketchybar = require("sketchybar")
local opts = require("items.uptime.opts")

local M = {}

M.swap = sketchybar.add("item", opts.swap_name, opts.items.swap.properties)
M.ram = sketchybar.add("item", opts.ram_name, opts.items.ram.properties)
M.uptime = sketchybar.add("item", opts.name, opts.items.uptime.properties)
M.gap = sketchybar.add("item", opts.gap_name, opts.items.gap.properties)

local bracket_opts = opts.create_bracket_opts()

M.bracket = sketchybar.add("bracket", bracket_opts.item_names, bracket_opts.properties)

return M
