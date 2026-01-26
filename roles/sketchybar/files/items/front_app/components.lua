local sketchybar = require("sketchybar")
local opts = require("items.front_app.opts")

local M = {}

M.front_app = sketchybar.add("item", opts.items.front_app.name, opts.items.front_app.properties)

return M
