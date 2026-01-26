return function(config, wezterm)
	config.font = wezterm.font("JetBrains Mono")
	config.font_size = 14.0
	config.color_scheme = "nightfox"
	config.font_size = 15.0
	config.enable_tab_bar = true
	config.hide_tab_bar_if_only_one_tab = false
	config.window_close_confirmation = "NeverPrompt"
	config.use_fancy_tab_bar = false
	config.tab_bar_at_bottom = true
	config.window_decorations = "RESIZE"
end
