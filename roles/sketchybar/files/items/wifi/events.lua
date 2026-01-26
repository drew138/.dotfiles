local sketchybar = require("sketchybar")
local theme = require("theme")

local M = {}

function M.hide_details()
	M.wifi_bracket:set({ popup = { drawing = false } })
end

function M.toggle_details()
	local should_draw = M.wifi_bracket:query().popup.drawing == "off"
	if should_draw then
		M.wifi_bracket:set({ popup = { drawing = true } })
		sketchybar.exec("networksetup -getcomputername", function(result)
			M.hostname:set({ label = result })
		end)
		sketchybar.exec("ipconfig getifaddr en0", function(result)
			M.ip:set({ label = result })
		end)
		sketchybar.exec("ipconfig getsummary en0 | awk -F ' SSID : '  '/ SSID : / {print $2}'", function(result)
			M.ssid:set({ label = result })
		end)
		sketchybar.exec(
			"networksetup -getinfo Wi-Fi | awk -F 'Subnet mask: ' '/^Subnet mask: / {print $2}'",
			function(result)
				M.mask:set({ label = result })
			end
		)
		sketchybar.exec("networksetup -getinfo Wi-Fi | awk -F 'Router: ' '/^Router: / {print $2}'", function(result)
			M.router:set({ label = result })
		end)
	else
		M.hide_details()
	end
end

function M.copy_label_to_clipboard(env)
	local label = sketchybar.query(env.NAME).label.value
	sketchybar.exec('echo "' .. label .. '" | pbcopy')
	sketchybar.set(env.NAME, { label = { string = theme.icons.clipboard, align = "center" } })
	sketchybar.delay(1, function()
		sketchybar.set(env.NAME, { label = { string = label, align = "right" } })
	end)
end

function M.configure_wifi()
	M.wifi:subscribe({ "wifi_change", "system_woke" }, function(_)
		sketchybar.exec("ipconfig getifaddr en0", function(ip)
			local connected = not (ip == "")
			M.wifi:set({
				icon = {
					string = connected and theme.icons.wifi.connected or theme.icons.wifi.disconnected,
					color = connected and theme.colors.blue or theme.colors.red,
				},
			})
		end)
	end)
	M.wifi:subscribe("mouse.clicked", M.toggle_details)
	M.wifi:subscribe("mouse.exited.global", M.hide_details)
end

function M.configure_wifi_up()
	M.wifi_up:subscribe("network_update", function(env)
		local up_color = (env.upload == "000 Bps") and theme.colors.grey or theme.colors.red
		local down_color = (env.download == "000 Bps") and theme.colors.grey or theme.colors.cyan
		M.wifi_up:set({
			icon = { color = up_color },
			label = {
				string = env.upload,
				color = up_color,
			},
		})
		M.wifi_down:set({
			icon = { color = down_color },
			label = {
				string = env.download,
				color = down_color,
			},
		})
	end)
	M.wifi_up:subscribe("mouse.clicked", M.toggle_details)
end

function M.configure_wifi_down()
	M.wifi_down:subscribe("mouse.clicked", M.toggle_details)
end

function M.configure_popup()
	M.ssid:subscribe("mouse.clicked", M.copy_label_to_clipboard)
	M.hostname:subscribe("mouse.clicked", M.copy_label_to_clipboard)
	M.ip:subscribe("mouse.clicked", M.copy_label_to_clipboard)
	M.mask:subscribe("mouse.clicked", M.copy_label_to_clipboard)
	M.router:subscribe("mouse.clicked", M.copy_label_to_clipboard)
end

function M.setup(components)
	M.wifi_up = components.wifi_up
	M.wifi_down = components.wifi_down
	M.wifi = components.wifi
	M.wifi_bracket = components.wifi_bracket
	M.ssid = components.ssid
	M.hostname = components.hostname
	M.ip = components.ip
	M.mask = components.mask
	M.router = components.router
	M.configure_wifi()
	M.configure_wifi_up()
	M.configure_wifi_down()
	M.configure_popup()
end

return M
