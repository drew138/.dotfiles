local sketchybar = require("sketchybar")
local opts = require("items.menus.opts")

local M = {}

M.menu_watcher = sketchybar.add("item", opts.items.menu_watcher.properties)
M.space_menu_swap = sketchybar.add("item", opts.items.space_menu_swap.properties)

M.menu_items = {}
for i = 1, opts.max_menu_items, 1 do
	M.menu_items[i] = sketchybar.add("item", opts.items["menu_" .. i].name, opts.items["menu_" .. i].properties)
end

M.menus_bracket =
	sketchybar.add("bracket", opts.brackets.menus_bracket.item_names, opts.brackets.menus_bracket.properties)

M.menu_padding = sketchybar.add("item", opts.items.menu_padding.name, opts.items.menu_padding.properties)

return M
