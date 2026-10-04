local sketchybar = require("sketchybar")
local theme = require("theme")
local opts = require("items.uptime.opts")

local M = {}

M.boot_time = nil
M.ram_total = nil

local function format_uptime(seconds)
	local days = math.floor(seconds / 86400)
	local hours = math.floor((seconds % 86400) / 3600)
	local minutes = math.floor((seconds % 3600) / 60)

	if days > 0 then
		return string.format("%dd %dh", days, hours)
	end

	if hours > 0 then
		return string.format("%dh %dm", hours, minutes)
	end

	return string.format("%dm", minutes)
end

local function color_for(ratio, warning, critical)
	if ratio >= critical then
		return theme.colors.red
	end

	if ratio >= warning then
		return theme.colors.orange
	end

	return theme.colors.green
end

local function set_ratio(item, ratio, warning, critical)
	local color = color_for(ratio, warning, critical)

	item:set({
		icon = { color = color },
		label = {
			string = string.format("%d%%", math.floor(ratio * 100 + 0.5)),
			color = color,
		},
	})
end

local function refresh_uptime()
	if not M.boot_time then
		return
	end

	M.uptime:set({ label = { string = format_uptime(os.time() - M.boot_time) } })
end

local function format_size(megabytes)
	if megabytes >= 1024 then
		return string.format("%.1fG", megabytes / 1024)
	end

	return string.format("%dM", math.floor(megabytes + 0.5))
end

local function refresh_swap()
	sketchybar.exec(opts.swap_command, function(result)
		local total = tonumber((result or ""):match("total%s*=%s*([%d%.]+)M"))
		local used = tonumber((result or ""):match("used%s*=%s*([%d%.]+)M"))

		if total and used then
			local color = color_for(total > 0 and used / total or 0, opts.swap_warning, opts.swap_critical)

			M.swap:set({
				icon = { color = color },
				label = { string = format_size(used), color = color },
			})
		end
	end)
end

local function refresh_ram()
	if not M.ram_total then
		return
	end

	sketchybar.exec(opts.ram_command, function(result)
		result = result or ""

		local page_size = tonumber(result:match("page size of (%d+) bytes"))
		local active = tonumber(result:match("Pages active:%s+(%d+)"))
		local wired = tonumber(result:match("Pages wired down:%s+(%d+)"))
		local compressed = tonumber(result:match("Pages occupied by compressor:%s+(%d+)"))

		if page_size and active and wired and compressed then
			local used = (active + wired + compressed) * page_size
			set_ratio(M.ram, used / M.ram_total, opts.ram_warning, opts.ram_critical)
		end
	end)
end

function M.refresh()
	refresh_uptime()
	refresh_ram()
	refresh_swap()
end

function M.setup(components)
	M.uptime = components.uptime
	M.ram = components.ram
	M.swap = components.swap

	sketchybar.exec(opts.boot_command, function(result)
		M.boot_time = tonumber((result or ""):match("sec%s*=%s*(%d+)"))
		refresh_uptime()
	end)

	sketchybar.exec(opts.ram_total_command, function(result)
		M.ram_total = tonumber((result or ""):match("(%d+)"))
		refresh_ram()
	end)

	refresh_swap()

	M.uptime:subscribe({ "routine", "forced", "system_woke" }, function(_)
		M.refresh()
	end)
end

return M
