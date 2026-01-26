local theme = require("theme")
local sketchybar = require("sketchybar")

local M = {}

function M.configure_battery()
	M.battery:subscribe("mouse.exited.global", M.hide_details)
	M.battery:subscribe({ "routine", "power_source_change", "system_woke" }, function()
		sketchybar.exec("pmset -g batt", function(batt_info)
			local icon = "!"
			local label = "?"

			local found, _, charge = batt_info:find("(%d+)%%")
			if found then
				charge = tonumber(charge)
				label = charge .. "%"
			end

			local color = theme.colors.green
			local charging, _, _ = batt_info:find("AC Power")

			if charging then
				icon = theme.icons.battery.charging
			else
				if found and charge > 80 then
					icon = theme.icons.battery._100
				elseif found and charge > 60 then
					icon = theme.icons.battery._75
				elseif found and charge > 40 then
					icon = theme.icons.battery._50
				elseif found and charge > 20 then
					icon = theme.icons.battery._25
					color = theme.colors.orange
				else
					icon = theme.icons.battery._0
					color = theme.colors.red
				end
			end

			local lead = ""
			if found and charge < 10 then
				lead = "0"
			end

			M.battery:set({
				icon = {
					string = icon,
					color = color,
				},
				label = { string = lead .. label },
			})
		end)
	end)

	M.battery:subscribe("mouse.clicked", function(_)
		local drawing = M.battery:query().popup.drawing
		M.battery:set({ popup = { drawing = "toggle" } })

		if drawing == "off" then
			sketchybar.exec("pmset -g batt", function(batt_info)
				local found, _, remaining = batt_info:find(" (%d+:%d+) remaining")
				local label = found and remaining .. "h" or "No estimate"
				M.remaining_time:set({ label = label })
			end)
		end
	end)
end

function M.hide_details()
	M.battery:set({ popup = { drawing = false } })
end

function M.setup(components)
	M.battery = components.battery
	M.remaining_time = components.remaining_time
	M.configure_battery()
end

return M
