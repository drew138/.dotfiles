local M = {}

function M.configure_calendar()
	M.calendar:subscribe({ "forced", "routine", "system_woke" }, function(_)
		M.calendar:set({ icon = os.date("%a. %d %b."), label = os.date("%H:%M") })
	end)
end

function M.setup(components)
	M.calendar = components.calendar
	M.configure_calendar()
end

return M
