#!/usr/bin/env lua

local home = os.getenv("HOME") or ""
local cache_directory = home .. "/.cache/sketchybar"
local cache_path = cache_directory .. "/herdr.txt"
local lock_directory = cache_directory .. "/herdr_poll.lock"
local lock_pid_path = lock_directory .. "/pid"
local interval = tonumber(os.getenv("HERDR_POLL_INTERVAL") or "") or 2
local sketchybar = "/opt/homebrew/bin/sketchybar"
local environment = "env PATH=/opt/homebrew/bin:" .. home .. "/.local/bin:/usr/bin:/bin "
local herdr = environment .. "herdr"
local room_margin = 16
local screen_every = 60

local function read(command)
	local handle = io.popen(command)

	if not handle then
		return ""
	end

	local output = handle:read("a") or ""
	handle:close()

	return output
end

local function write(path, contents)
	local file = io.open(path, "w")

	if not file then
		return false
	end

	file:write(contents)
	file:close()

	return true
end

local function process_alive(pid)
	if not pid then
		return false
	end

	return os.execute("kill -0 " .. pid .. " 2>/dev/null") == true
end

local function claim_lock()
	os.execute("mkdir -p '" .. cache_directory .. "'")

	if os.execute("mkdir '" .. lock_directory .. "' 2>/dev/null") == true then
		return true
	end

	local holder = read("cat '" .. lock_pid_path .. "' 2>/dev/null"):match("%d+")

	if process_alive(holder) then
		return false
	end

	os.execute("rm -rf '" .. lock_directory .. "'")

	return os.execute("mkdir '" .. lock_directory .. "' 2>/dev/null") == true
end

local function own_pid()
	return read("echo $PPID"):match("%d+") or read("sh -c 'echo $PPID'"):match("%d+")
end

local function screen_width()
	local report = read("system_profiler SPDisplaysDataType 2>/dev/null")
	local scaled = report:match("UI Looks like:%s*(%d+)%s*x%s*%d+")

	if scaled then
		return tonumber(scaled)
	end

	local native, trailing = report:match("Resolution:%s*(%d+)%s*x%s*%d+([^\n]*)")

	if not native then
		return nil
	end

	local width = tonumber(native)

	if trailing:find("Retina") then
		width = math.floor(width / 2)
	end

	return width
end

local function bar_items()
	local bar = read(sketchybar .. " --query bar 2>/dev/null")
	local names = {}
	local payload = bar:match('"items"%s*:%s*%[(.-)%]')

	for name in string.gmatch(payload or "", '"(.-)"') do
		if not name:match("^herdr%.slot%.") then
			table.insert(names, name)
		end
	end

	local padding = (tonumber(bar:match('"padding_left"%s*:%s*(%d+)')) or 0)
		+ (tonumber(bar:match('"padding_right"%s*:%s*(%d+)')) or 0)

	return names, padding
end

local function bar_is_running()
	return os.execute("pgrep -x sketchybar >/dev/null 2>&1") == true
end

local function occupied_width(names)
	if #names == 0 then
		return nil
	end

	local command = { sketchybar }

	for _, name in ipairs(names) do
		table.insert(command, "--query")
		table.insert(command, name)
	end

	table.insert(command, "2>/dev/null")

	local total = 0

	for object in string.gmatch(read(table.concat(command, " ")), "%b{}") do
		local geometry = object:match('"geometry"%s*:%s*(%b{})') or ""
		local drawing = geometry:match('"drawing"%s*:%s*"(.-)"')
		local position = geometry:match('"position"%s*:%s*"(.-)"') or ""
		local kind = object:match('"type"%s*:%s*"(.-)"') or ""

		if drawing == "on" and kind ~= "bracket" and not position:match("^popup") then
			local rects = object:match('"bounding_rects"%s*:%s*(%b{})') or ""
			local display = rects:match('"display%-1"%s*:%s*(%b{})') or ""
			local width = tonumber(display:match('"size"%s*:%s*%[%s*([%-%d%.]+)'))

			if width then
				total = total + width
			end
		end
	end

	return total
end

if not claim_lock() then
	os.exit(0)
end

write(lock_pid_path, (own_pid() or "") .. "\n")

local previous = nil
local screen = nil
local ticks = 0

while true do
	if ticks % screen_every == 0 then
		screen = screen_width() or screen
	end

	ticks = ticks + 1

	local room = ""

	if screen then
		local names, padding = bar_items()
		local occupied = occupied_width(names)

		if occupied then
			room = tostring(math.floor(screen - padding - occupied - room_margin))
		end
	end

	local current = table.concat({
		"AGENTS " .. read(herdr .. " agent list 2>/dev/null"),
		"WORKSPACES " .. read(herdr .. " workspace list 2>/dev/null"),
		"TABS " .. read(herdr .. " tab list 2>/dev/null"),
		"ROOM " .. room,
	}, "\n")

	if current ~= previous then
		if write(cache_path .. ".tmp", current .. "\n") then
			os.execute("mv '" .. cache_path .. ".tmp' '" .. cache_path .. "'")
			os.execute(sketchybar .. " --trigger herdr_update >/dev/null 2>&1")
			previous = current
		end
	end

	os.execute("sleep " .. interval)

	if not bar_is_running() then
		os.exit(0)
	end
end
