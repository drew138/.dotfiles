local sketchybar = require("sketchybar")
local opts = require("items.wifi.opts")

-- Execute the event provider binary which provides the event "network_update"
-- for the network interface "en0", which is fired every 2.0 seconds.
sketchybar.exec(
	"killall network_load >/dev/null; $CONFIG_DIR/helpers/event_providers/network_load/bin/network_load en0 network_update 2.0"
)

local M = {
	wifi_up = sketchybar.add("item", opts.items.wifi_up.name, opts.items.wifi_up.properties),
	wifi_down = sketchybar.add("item", opts.items.wifi_down.name, opts.items.wifi_down.properties),
	wifi = sketchybar.add("item", opts.items.wifi_space_right.name, opts.items.wifi_space_right.properties),
	wifi_bracket = sketchybar.add(
		"bracket",
		opts.brackets.wifi_bracket.name,
		opts.brackets.wifi_bracket.item_names,
		opts.brackets.wifi_bracket.properties
	),
	ssid = sketchybar.add("item", opts.items.ssid.properties),
	hostname = sketchybar.add("item", opts.items.hostname.properties),
	ip = sketchybar.add("item", opts.items.ip.properties),
	mask = sketchybar.add("item", opts.items.mask.properties),
	router = sketchybar.add("item", opts.items.router.properties),
	wifi_space_left = sketchybar.add("item", opts.items.wifi_space_left.properties),
}

return M
