local sketchybar = require("sketchybar")
local M = {}

function M.configure_front_app()
	M.front_app:subscribe("front_app_switched", function(env)
		M.front_app:set({ label = { string = env.INFO } })
	end)
	M.front_app:subscribe("mouse.clicked", function(_)
		sketchybar.trigger("swap_menus_and_spaces")
	end)
end

function M.setup(components)
	M.front_app = components.front_app
	M.configure_front_app()
end

return M
