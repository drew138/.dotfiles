local sketchybar = require("sketchybar")
local theme = require("theme")

-- Equivalent to the --bar domain
sketchybar.bar({
	height = 45,
	-- color = theme.colors.bar.bg,
	color = theme.colors.transparent,
	padding_right = 2,
	padding_left = 2,
})
