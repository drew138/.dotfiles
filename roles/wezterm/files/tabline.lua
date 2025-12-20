return function(config, wezterm)
	local tabline = wezterm.plugin.require("https://github.com/michaelbrusegard/tabline.wez")

	tabline.setup()
	tabline.apply_to_config(config)
end
