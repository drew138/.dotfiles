return function(config, wezterm)
	config.leader = {
		key = "a",
		mods = "CTRL",
		timeout_milliseconds = 1000,
	}

	config.keys = {
		-- Splits
		{ key = "c", mods = "LEADER", action = wezterm.action.SpawnTab("CurrentPaneDomain") },
		{ key = "x", mods = "LEADER", action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }) },
		{ key = "s", mods = "LEADER", action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
		{ key = "d", mods = "LEADER", action = wezterm.action.CloseCurrentPane({ confirm = false }) },

		-- Navigation
		{ key = "h", mods = "CMD|SHIFT", action = wezterm.action.ActivatePaneDirection("Left") },
		{ key = "j", mods = "CMD|SHIFT", action = wezterm.action.ActivatePaneDirection("Down") },
		{ key = "k", mods = "CMD|SHIFT", action = wezterm.action.ActivatePaneDirection("Up") },
		{ key = "l", mods = "CMD|SHIFT", action = wezterm.action.ActivatePaneDirection("Right") },
		{ key = "m", mods = "CMD|SHIFT", action = wezterm.action.ActivateTabRelative(1) },
		{ key = "n", mods = "CMD|SHIFT", action = wezterm.action.ActivateTabRelative(-1) },

		-- Select mode
		{ key = "]", mods = "LEADER", action = wezterm.action.ActivateCopyMode },
		{ key = " ", mods = "LEADER", action = wezterm.action.QuickSelect },
	}
end
