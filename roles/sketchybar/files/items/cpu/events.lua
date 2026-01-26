local sketchybar = require("sketchybar")
local theme = require("theme")

local M = {}

function M.configure_cpu()
	M.cpu:subscribe("cpu_update", function(env)
		-- Also available: env.user_load, env.sys_load
		local raw_load = tonumber(env.total_load) or 0
		local load = math.min(math.abs(raw_load), 99)

		local color = theme.colors.cyan
		if load > 50 then
			if load < 80 then
				color = theme.colors.orange
			else
				color = theme.colors.red
			end
		end

		M.cpu:set({
			label = { string = load .. "%", color = color },
		})
	end)

	M.cpu:subscribe("mouse.clicked", function(_)
		sketchybar.exec("open -a 'Activity Monitor'")
	end)
end

function M.setup(components)
	M.cpu = components.cpu
	M.configure_cpu()
end

return M
