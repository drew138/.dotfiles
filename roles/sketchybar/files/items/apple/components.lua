local sketchybar = require("sketchybar")
local opts = require("items.apple.opts")

local M = {}

M.apple_space_left = sketchybar.add("item", opts.items.apple_space_left.properties)
M.apple = sketchybar.add("item", opts.items.apple.name, opts.items.apple.properties)
M.apple_bracket =
	sketchybar.add("bracket", opts.brackets.apple_bracket.item_names, opts.brackets.apple_bracket.properties)
M.apple_space_right = sketchybar.add("item", opts.items.apple_space_right.properties)

return M
