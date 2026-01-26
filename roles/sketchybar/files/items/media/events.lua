local sketchybar = require("sketchybar")

local M = {}

M.whitelist = { ["Spotify"] = true, ["Music"] = true, ["Google Chrome"] = true }
M.interrupt = 0

function M.animate_detail(detail)
	if not detail then
		M.interrupt = M.interrupt - 1
	end
	if M.interrupt > 0 and not detail then
		return
	end

	sketchybar.animate("tanh", 30, function()
		M.media_artist:set({ label = { width = detail and "dynamic" or 0 } })
		M.media_title:set({ label = { width = detail and "dynamic" or 0 } })
	end)
end

function M.configure_media_cover()
	M.media_cover:subscribe("media_change", function(env)
		if M.whitelist[env.INFO.app] then
			local drawing = (env.INFO.state == "playing")
			M.media_artist:set({ drawing = drawing, label = env.INFO.artist })
			M.media_title:set({ drawing = drawing, label = env.INFO.title })
			M.media_cover:set({ drawing = drawing })

			if drawing then
				M.animate_detail(true)
				M.interrupt = M.interrupt + 1
				sketchybar.delay(5, M.animate_detail)
			else
				M.media_cover:set({ popup = { drawing = false } })
			end
		end
	end)

	M.media_cover:subscribe("mouse.entered", function(_)
		M.interrupt = M.interrupt + 1
		M.animate_detail(true)
	end)

	M.media_cover:subscribe("mouse.exited", function(_)
		M.animate_detail(false)
	end)

	M.media_cover:subscribe("mouse.clicked", function(_)
		M.media_cover:set({ popup = { drawing = "toggle" } })
	end)
end

function M.configure_media_title()
	M.media_title:subscribe("mouse.exited.global", function(_)
		M.media_cover:set({ popup = { drawing = false } })
	end)
end

function M.setup(components)
	M.media_cover = components.media_cover
	M.media_artist = components.media_artist
	M.media_title = components.media_title
	M.configure_media_cover()
	M.configure_media_title()
end

return M
