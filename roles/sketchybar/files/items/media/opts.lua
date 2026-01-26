local theme = require("theme")

local M = {}

M.items = {
	media_cover = {
		name = "media_cover",
		properties = {
			position = "right",
			background = {
				image = {
					string = "media.artwork",
					scale = 0.85,
				},
				color = theme.colors.transparent,
			},
			label = { drawing = false },
			icon = { drawing = false },
			drawing = false,
			updates = true,
			popup = {
				align = "center",
				horizontal = true,
			},
		},
	},
	media_artist = {
		name = "media_artist",
		properties = {
			position = "right",
			drawing = false,
			padding_left = 3,
			padding_right = 0,
			width = 0,
			icon = { drawing = false },
			label = {
				width = 0,
				font = { size = 9 },
				color = theme.colors.with_alpha(theme.colors.white, 0.6),
				max_chars = 18,
				y_offset = 6,
			},
		},
	},
	media_title = {
		name = "media_title",
		properties = {
			position = "right",
			drawing = false,
			padding_left = 3,
			padding_right = 0,
			icon = { drawing = false },
			label = {
				font = { size = 11 },
				width = 0,
				-- max_chars = 18,
				y_offset = -5,
			},
		},
	},
}

M.items.media_cover_back = {
	properties = {
		position = "popup." .. M.items.media_cover.name,
		icon = { string = theme.icons.media.back },
		label = { drawing = false },
		click_script = "nowplaying-cli previous",
	},
}

M.items.media_cover_play_pause = {
	properties = {
		position = "popup." .. M.items.media_cover.name,
		icon = { string = theme.icons.media.play_pause },
		label = { drawing = false },
		click_script = "nowplaying-cli togglePlayPause",
	},
}

M.items.media_cover_forward = {
	properties = {
		position = "popup." .. M.items.media_cover.name,
		icon = { string = theme.icons.media.forward },
		label = { drawing = false },
		click_script = "nowplaying-cli next",
	},
}

return M
