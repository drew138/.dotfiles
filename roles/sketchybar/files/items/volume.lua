local sketchybar = require("sketchybar")
local theme = require("theme")

local popup_width = 250

local volume_percent = sketchybar.add("item", "widgets.volume1", {
	position = "right",
	icon = { drawing = false },
	label = {
		string = "??%",
		padding_left = -1,
		color = theme.colors.cyan,
		font = { family = theme.settings.font.numbers },
	},
})

local volume_icon = sketchybar.add("item", "widgets.volume2", {
	position = "right",
	padding_right = -1,
	icon = {
		string = theme.icons.volume._100,
		width = 0,
		align = "left",
		color = theme.colors.grey,
		font = {
			style = theme.settings.font.style_map["Regular"],
			size = 14.0,
		},
	},
	label = {
		width = 25,
		align = "left",
		color = theme.colors.blue,
		font = {
			style = theme.settings.font.style_map["Regular"],
			size = 14.0,
		},
	},
})

local volume_bracket = sketchybar.add("bracket", "widgets.volume.bracket", {
	volume_icon.name,
	volume_percent.name,
}, {
	background = { color = theme.colors.bg1 },
	popup = { align = "center" },
})

sketchybar.add("item", "widgets.volume.padding", {
	position = "right",
	width = theme.settings.group_paddings,
})

local volume_slider = sketchybar.add("slider", popup_width, {
	position = "popup." .. volume_bracket.name,
	slider = {
		highlight_color = theme.colors.blue,
		background = {
			height = 6,
			corner_radius = 3,
			color = theme.colors.bg2,
		},
		knob = {
			string = "􀀁",
			drawing = true,
		},
	},
	background = { color = theme.colors.bg1, height = 2, y_offset = -20 },
	click_script = 'osascript -e "set volume output volume $PERCENTAGE"',
})

volume_percent:subscribe("volume_change", function(env)
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

	volume_icon:set({ label = icon })
	volume_percent:set({ label = lead .. volume .. "%" })
	volume_slider:set({ slider = { percentage = volume } })
end)

local function volume_collapse_details()
	local drawing = volume_bracket:query().popup.drawing == "on"
	if not drawing then
		return
	end
	volume_bracket:set({ popup = { drawing = false } })
	sketchybar.remove("/volume.device\\.*/")
end

local current_audio_device = "None"
local function volume_toggle_details(env)
	if env.BUTTON == "right" then
		sketchybar.exec("open /System/Library/PreferencePanes/Sound.prefpane")
		return
	end

	local should_draw = volume_bracket:query().popup.drawing == "off"
	if should_draw then
		volume_bracket:set({ popup = { drawing = true } })
		sketchybar.exec("SwitchAudioSource -t output -c", function(result)
			current_audio_device = result:sub(1, -2)
			sketchybar.exec("SwitchAudioSource -a -t output", function(available)
				current = current_audio_device
				local color = theme.colors.grey
				local counter = 0

				for device in string.gmatch(available, "[^\r\n]+") do
					local color = theme.colors.grey
					if current == device then
						color = theme.colors.white
					end
					sketchybar.add("item", "volume.device." .. counter, {
						position = "popup." .. volume_bracket.name,
						width = popup_width,
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
		volume_collapse_details()
	end
end

local function volume_scroll(env)
	local delta = env.INFO.delta
	if not (env.INFO.modifier == "ctrl") then
		delta = delta * 10.0
	end

	sketchybar.exec(
		'osascript -e "set volume output volume (output volume of (get volume settings) + ' .. delta .. ')"'
	)
end

volume_icon:subscribe("mouse.clicked", volume_toggle_details)
volume_icon:subscribe("mouse.scrolled", volume_scroll)
volume_percent:subscribe("mouse.clicked", volume_toggle_details)
volume_percent:subscribe("mouse.exited.global", volume_collapse_details)
volume_percent:subscribe("mouse.scrolled", volume_scroll)
