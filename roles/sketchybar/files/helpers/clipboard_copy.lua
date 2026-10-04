#!/usr/bin/env lua

local home = os.getenv("HOME") or ""
local store_path = home .. "/.cache/sketchybar/clipboard.tsv"
local sketchybar = "/opt/homebrew/bin/sketchybar"

local function unescape(text)
	return (text:gsub("\\(.)", function(character)
		if character == "n" then
			return "\n"
		elseif character == "t" then
			return "\t"
		elseif character == "\\" then
			return "\\"
		end

		return "\\" .. character
	end))
end

local function entry(index)
	local file = io.open(store_path, "r")

	if not file then
		return nil
	end

	local number = 0
	local found = nil

	for line in file:lines() do
		number = number + 1

		if number == index then
			found = line
			break
		end
	end

	file:close()

	return found
end

os.execute(sketchybar .. " --set clipboard popup.drawing=off >/dev/null 2>&1")

local index = tonumber(arg[1] or "")

if not index or index < 1 then
	return
end

local line = entry(index)

if not line then
	return
end

local pasteboard = io.popen("/usr/bin/pbcopy", "w")

if not pasteboard then
	return
end

pasteboard:write(unescape(line))
pasteboard:close()
