local sketchybar = require("sketchybar")
local opts = require("items.media.opts")

local M = {}

M.media_cover = sketchybar.add("item", opts.items.media_cover.name, opts.items.media_cover.properties)
M.media_artist = sketchybar.add("item", opts.items.media_artist.name, opts.items.media_artist.properties)
M.media_title = sketchybar.add("item", opts.items.media_title.name, opts.items.media_title.properties)
M.media_cover_back = sketchybar.add("item", opts.items.media_cover_back.properties)
M.media_cover_play_pause = sketchybar.add("item", opts.items.media_cover_play_pause.properties)
M.media_cover_forward = sketchybar.add("item", opts.items.media_cover_forward.properties)

return M
