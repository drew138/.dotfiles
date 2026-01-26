local sketchybar = require("sketchybar")
local theme = require("theme")

-- Equivalent to the --bar domain
sketchybar.bar({
	height = 45,
	color = theme.colors.bar.bg,
	padding_right = 2,
	padding_left = 2,
})
