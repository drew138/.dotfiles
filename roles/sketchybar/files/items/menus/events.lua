local sketchybar = require("sketchybar")
local opts = require("items.menus.opts")

local M = {}

function M.update_menus(_)
	sketchybar.exec("$CONFIG_DIR/helpers/menus/bin/menus -l", function(menus)
		sketchybar.set("/menu\\..*/", { drawing = false })
		M.menu_padding:set({ drawing = true })
		local id = 1
		for menu in string.gmatch(menus, "[^\r\n]+") do
			if id < opts.max_menu_items then
				M.menu_items[id]:set({ label = menu, drawing = true })
			else
				break
			end
			id = id + 1
		end
	end)
end

function M.configure_menu_watcher()
	M.menu_watcher:subscribe("front_app_switched", M.update_menus)
end

function M.configure_space_menu_swap()
	M.space_menu_swap:subscribe("swap_menus_and_spaces", function(_)
		local drawing = M.menu_items[1]:query().geometry.drawing == "on"
		if drawing then
			M.menu_watcher:set({ updates = false })
			sketchybar.set("/menu\\..*/", { drawing = false })
			sketchybar.set("/space\\..*/", { drawing = true })
			sketchybar.set("front_app", { drawing = true })
		else
			M.menu_watcher:set({ updates = true })
			sketchybar.set("/space\\..*/", { drawing = false })
			sketchybar.set("front_app", { drawing = false })
			M.update_menus()
		end
	end)
end

function M.setup(components)
	sketchybar.add("event", "swap_menus_and_spaces")
	M.menu_watcher = components.menu_watcher
	M.menu_padding = components.menu_padding
	M.menu_items = components.menu_items
	M.space_menu_swap = components.space_menu_swap
	M.configure_space_menu_swap()
	M.configure_menu_watcher()
end

return M
