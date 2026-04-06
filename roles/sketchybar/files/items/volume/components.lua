local sketchybar = require("sketchybar")
local opts = require("items.volume.opts")

local M = {
	volume_percent = sketchybar.add("item", opts.items.volume_percent.name, opts.items.volume_percent.properties),
	volume_icon = sketchybar.add("item", opts.items.volume_icon.name, opts.items.volume_icon.properties),
	volume_bracket = sketchybar.add("bracket", opts.brackets.bracket.name, {
		opts.items.volume_icon.name,
		opts.items.volume_percent.name,
	}, opts.brackets.bracket.properties),
	volume_space_right = sketchybar.add(
		"item",
		opts.items.volume_space_right.name,
		opts.items.volume_space_right.properties
	),
	volume_slider = sketchybar.add("slider", opts.popup_width, opts.sliders.slider.properties),
}

return M
