return {
	black = 0xff393b44,
	white = 0xffdfdfe0,
	red = 0xffc94f6d,
	green = 0xff81b29a,
	blue = 0xff719cd6,
	yellow = 0xffdbc074,
	orange = 0xfff4a261,
	magenta = 0xff9d79d6,
	grey = 0xff7f8490,
	transparent = 0x00000000,
	pink = 0xffd67ad2,
	cyan = 0xff63cdcf,

	bar = {
		bg = 0xff131a24,
		border = 0xff2b3b51,
	},
	popup = {
		bg = 0xff212e3f,
		border = 0xff3c5372,
	},
	bg1 = 0xff212e3f,
	bg2 = 0xff3c5372,

	with_alpha = function(color, alpha)
		if alpha > 1.0 or alpha < 0.0 then
			return color
		end
		return (color & 0x00ffffff) | (math.floor(alpha * 255.0) << 24)
	end,
}
