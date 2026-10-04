local sketchybar = require("sketchybar")
local theme = require("theme")
local opts = require("items.brew.opts")

local M = {}

M.packages = {}
M.upgrading = false
M.failed = false
M.spinner_index = 1

local function count_color(count)
	if M.failed then
		return theme.colors.red
	elseif count == 0 then
		return theme.colors.green
	end

	return theme.colors.orange
end

local function parse_packages(result)
	local packages = {}

	for line in string.gmatch(result or "", "[^\r\n]+") do
		local name, installed, available = line:match("^(%S+)%s+%((.-)%)%s+[<!=]+%s+(.+)$")
		if name then
			table.insert(packages, {
				name = name,
				installed = installed,
				available = available:match("^%s*(.-)%s*$"),
			})
		end
	end

	return packages
end

local function read_cache()
	local file = io.open(opts.outdated_cache, "r")

	if not file then
		return nil
	end

	local contents = file:read("a")
	file:close()

	return contents
end

local function spin()
	if not M.upgrading then
		return
	end

	M.brew:set({
		icon = {
			string = opts.spinner_frames[M.spinner_index],
			color = theme.colors.orange,
			font = opts.spinner_font,
		},
	})

	M.spinner_index = M.spinner_index % #opts.spinner_frames + 1

	sketchybar.delay(opts.spinner_interval, spin)
end

function M.poll()
	sketchybar.exec(opts.outdated_command)
end

function M.refresh()
	local result = read_cache()

	if result == nil or M.upgrading then
		return
	end

	M.packages = parse_packages(result)

	local count = #M.packages
	local color = count_color(count)

	M.brew:set({
		icon = {
			string = theme.icons.brew,
			color = color,
			font = opts.icon_font,
		},
		label = {
			string = M.failed and "!" or tostring(count),
			color = color,
			padding_left = 1,
			padding_right = 8,
		},
	})
end

function M.start_upgrade()
	M.failed = false
	M.spinner_index = 1
	M.upgrading = true

	M.brew:set({ label = { string = "" } })

	spin()
end

function M.finish_upgrade(status)
	M.upgrading = false
	M.failed = status ~= "0"

	M.poll()
end

function M.configure_clicks()
	M.brew:subscribe("mouse.clicked", function(env)
		if env.BUTTON == "right" then
			M.poll()
		elseif not M.upgrading and #M.packages > 0 then
			sketchybar.exec(opts.upgrade_all_command)
		end
	end)
end

function M.setup(components)
	sketchybar.add("event", opts.update_event)
	sketchybar.add("event", opts.started_event)
	sketchybar.add("event", opts.finished_event)

	M.brew = components.brew

	M.brew:subscribe({ "routine", "forced" }, function(_)
		M.poll()
	end)

	M.brew:subscribe(opts.update_event, function(_)
		M.refresh()
	end)

	M.brew:subscribe(opts.started_event, function(_)
		M.start_upgrade()
	end)

	M.brew:subscribe(opts.finished_event, function(env)
		M.finish_upgrade(env.STATUS)
	end)

	M.configure_clicks()

	M.refresh()
	M.poll()
end

return M
