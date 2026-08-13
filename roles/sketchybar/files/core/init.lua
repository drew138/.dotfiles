local M = {}

function M.start()
	local sketchybar = require("sketchybar")

	sketchybar.begin_config()
	sketchybar.hotload(true)
	require("appearance")
	require("items")

	sketchybar.end_config()
	sketchybar.event_loop()
end

function M.setup()
	M.start()
end

return M
