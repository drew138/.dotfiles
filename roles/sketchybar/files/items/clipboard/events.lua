local sketchybar = require("sketchybar")
local theme = require("theme")
local opts = require("items.clipboard.opts")

local M = {}

M.popup_token = 0

local function read_entries()
	local file = io.open(opts.store_path, "r")

	if not file then
		return {}
	end

	local entries = {}

	for line in file:lines() do
		if line ~= "" then
			table.insert(entries, line)
		end
	end

	file:close()

	return entries
end

local function display(entry)
	local text = entry:gsub("\\\\", "\1"):gsub("\\n", " ⏎ "):gsub("\\t", "  "):gsub("\1", "\\")

	text = text:gsub("^%s+", ""):gsub("%s+$", ""):gsub("%s%s+", " ")

	if #text > opts.row_max_length then
		text = text:sub(1, opts.row_max_length - 1) .. "…"
	end

	return text
end

local function close_popup()
	M.clipboard:set({ popup = { drawing = false } })
end

local function cancel_close()
	M.popup_token = M.popup_token + 1
end

local function schedule_close()
	M.popup_token = M.popup_token + 1

	local token = M.popup_token

	sketchybar.delay(opts.popup_close_delay, function()
		if token == M.popup_token then
			close_popup()
		end
	end)
end

function M.refresh()
	local entries = read_entries()

	for index = 1, opts.maximum_rows do
		local entry = entries[index]

		M.rows[index]:set({
			drawing = entry ~= nil,
			label = { string = entry and display(entry) or "" },
		})
	end

	local has_entries = #entries > 0

	M.has_entries = has_entries

	M.clipboard:set({
		icon = { color = has_entries and theme.colors.blue or theme.colors.bg2 },
		click_script = "",
	})

	if not has_entries then
		M.clipboard:set({ popup = { drawing = false } })
	end
end

function M.setup(components)
	sketchybar.add("event", opts.update_event)

	M.clipboard = components.clipboard
	M.rows = components.rows

	M.clipboard:subscribe({ opts.update_event, "forced" }, function(_)
		M.refresh()
	end)

	M.clipboard:subscribe("mouse.clicked", function(_)
		if M.has_entries then
			M.clipboard:set({ popup = { drawing = "toggle" } })
			cancel_close()
		end
	end)

	M.clipboard:subscribe("mouse.entered", cancel_close)
	M.clipboard:subscribe("mouse.exited", schedule_close)

	for _, row in ipairs(M.rows) do
		row:subscribe("mouse.entered", cancel_close)
		row:subscribe("mouse.exited", schedule_close)
	end

	M.clipboard:subscribe({ "front_app_switched", "aerospace_workspace_change" }, function(_)
		close_popup()
	end)

	M.clipboard:subscribe("mouse.exited.global", schedule_close)

	sketchybar.exec(opts.watcher_command)

	M.refresh()
end

return M
