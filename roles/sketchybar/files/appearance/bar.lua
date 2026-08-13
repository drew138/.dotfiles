local sketchybar = require("sketchybar")
local theme = require("theme")

-- Equivalent to the --bar domain
sketchybar.bar({
	height = 36,
	color = theme.colors.transparent,
	padding_right = 11,
	padding_left = 11,
	topmost = false,
	y_offset = 0,
})
