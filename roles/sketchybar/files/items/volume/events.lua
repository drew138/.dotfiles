local sketchybar = require("sketchybar")
local opts = require("items.volume.opts")
local theme = require("theme")

local M = {}

function M.volume_collapse_details()
	local drawing = M.volume_bracket:query().popup.drawing == "on"
	if not drawing then
		return
	end
	M.volume_bracket:set({ popup = { drawing = false } })
	sketchybar.remove("/volume.device\\.*/")
end

M.current_audio_device = "None"

function M.volume_toggle_details(env)
	if env.BUTTON == "right" then
		sketchybar.exec("open /System/Library/PreferencePanes/Sound.prefpane")
		return
	end

	local should_draw = M.volume_bracket:query().popup.drawing == "off"
	if should_draw then
		M.volume_bracket:set({ popup = { drawing = true } })
		sketchybar.exec("SwitchAudioSource -t output -c", function(result)
			M.current_audio_device = result:sub(1, -2)
			sketchybar.exec("SwitchAudioSource -a -t output", function(available)
				local current = M.current_audio_device
				local counter = 0

				for device in string.gmatch(available, "[^\r\n]+") do
					local color = theme.colors.grey
					if current == device then
						color = theme.colors.white
					end
					sketchybar.add("item", "volume.device." .. counter, {
						position = "popup." .. opts.brackets.bracket.name,
						width = opts.popup_width,
						align = "center",
						label = { string = device, color = color },
						click_script = 'SwitchAudioSource -s "'
							.. device
							.. '" && sketchybar --set /volume.device\\.*/ label.color='
							.. theme.colors.grey
							.. " --set $NAME label.color="
							.. theme.colors.white,
					})
					counter = counter + 1
				end
			end)
		end)
	else
		M.volume_collapse_details()
	end
end

function M.volume_scroll(env)
	local delta = env.INFO.delta
	if not (env.INFO.modifier == "ctrl") then
		delta = delta * 10.0
	end

	sketchybar.exec(
		'osascript -e "set volume output volume (output volume of (get volume settings) + ' .. delta .. ')"'
	)
end

function M.setup_components()
	M.volume_percent:subscribe("volume_change", function(env)
		local volume = tonumber(env.INFO)
		local icon = theme.icons.volume._0
		if volume > 60 then
			icon = theme.icons.volume._100
		elseif volume > 30 then
			icon = theme.icons.volume._66
		elseif volume > 10 then
			icon = theme.icons.volume._33
		elseif volume > 0 then
			icon = theme.icons.volume._10
		end

		local lead = ""
		if volume < 10 then
			lead = "0"
		end

		M.volume_icon:set({ label = icon })
		M.volume_percent:set({ label = lead .. volume .. "%" })
		M.volume_slider:set({ slider = { percentage = volume } })
	end)
	M.volume_icon:subscribe("mouse.clicked", M.volume_toggle_details)
	M.volume_icon:subscribe("mouse.scrolled", M.volume_scroll)
	M.volume_percent:subscribe("mouse.clicked", M.volume_toggle_details)
	M.volume_percent:subscribe("mouse.exited.global", M.volume_collapse_details)
	M.volume_percent:subscribe("mouse.scrolled", M.volume_scroll)
end

function M.setup(components)
	M.volume_percent = components.volume_percent
	M.volume_icon = components.volume_icon
	M.volume_icon = components.volume_icon
	M.volume_slider = components.volume_slider
	M.volume_bracket = components.volume_bracket
	M.setup_components()
end
return M
