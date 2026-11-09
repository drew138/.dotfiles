return function(config, wezterm)
	local tabline = wezterm.plugin.require("https://github.com/michaelbrusegard/tabline.wez")

	local nf = {
		bg0 = "#131a24",
		bg1 = "#192330",
		bg2 = "#212e3f",
		fg1 = "#cdcecf",
		fg2 = "#aeafb0",
		fg3 = "#71839b",
		red = "#c94f6d",
		blue = "#719cd6",
		green = "#81b29a",
		yellow = "#dbc074",
		orange = "#f4a261",
	}
	local mode = function(color)
		return {
			a = { fg = nf.bg0, bg = color },
			b = { fg = color, bg = nf.bg2 },
			c = { fg = nf.fg3, bg = nf.bg0 },
		}
	end
	local round_left = wezterm.nerdfonts.ple_right_half_circle_thick
	local round_right = wezterm.nerdfonts.ple_left_half_circle_thick

	local homelab_url_file = io.open(wezterm.home_dir .. "/.config/homelab-status-url")
	local homelab_url = homelab_url_file and homelab_url_file:read("*l")
	if homelab_url_file then
		homelab_url_file:close()
	end
	local homelab_color = function()
		local ok, out = wezterm.run_child_process({ "/usr/bin/curl", "-s", "-m", "3", "-w", "\n%{http_code}", homelab_url })
		if not ok then
			return nf.yellow
		end
		local body, code = out:match("^(.*)\n(%d+)$")
		if code ~= "200" then
			return nf.red
		end
		local parsed, data = pcall(wezterm.json_parse, body)
		if not parsed or not data.heartbeatList or next(data.heartbeatList) == nil then
			return nf.red
		end
		for _, beats in pairs(data.heartbeatList) do
			if beats[#beats] and beats[#beats].status == 0 then
				return nf.red
			end
		end
		return nf.green
	end
	local homelab_cache, homelab_checked = "", 0
	local homelab = function()
		if not homelab_url then
			return ""
		end
		if os.time() - homelab_checked >= 30 then
			homelab_checked = os.time()
			homelab_cache = wezterm.format({
				{ Foreground = { Color = homelab_color() } },
				{ Text = "● " },
				{ Foreground = { Color = nf.fg2 } },
				{ Text = wezterm.nerdfonts.md_server .. " homelab  " },
			})
		end
		return homelab_cache
	end

	tabline.setup({
		options = {
			theme = "nightfox",
			theme_overrides = {
				normal_mode = mode(nf.blue),
				copy_mode = mode(nf.yellow),
				search_mode = mode(nf.green),
				tab = {
					active = { fg = nf.orange, bg = nf.bg2 },
					inactive = { fg = nf.fg3, bg = nf.bg0 },
					inactive_hover = { fg = nf.fg1, bg = nf.bg1 },
				},
			},
			section_separators = { left = round_left, right = round_right },
			component_separators = { left = "", right = "" },
			tab_separators = { left = round_left, right = round_right },
		},
		sections = {
			tabline_x = { homelab },
			tabline_y = {},
			tabline_z = {},
		},
	})
	tabline.apply_to_config(config)
end
