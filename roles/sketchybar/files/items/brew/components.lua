local sketchybar = require("sketchybar")
local opts = require("items.brew.opts")

local M = {}

M.brew = sketchybar.add("item", opts.name, opts.items.brew.properties)

local bracket_opts = opts.create_bracket_opts()

M.bracket = sketchybar.add("bracket", bracket_opts.item_names, bracket_opts.properties)

return M
