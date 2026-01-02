local function next()
	local ls = require("luasnip")
	if ls.expand_or_jumpable() then
		ls.expand_or_jump()
	end
end

local function prev()
	local ls = require("luasnip")
	if ls.jumpable(-1) then
		ls.jump(-1)
	end
end

-- TODO change these keybinds
local M = {
	{
		"<c-h>",
		prev,
		mode = { "i", "s" },
		silent = true,
		desc = "prev jumpable point",
	},
	{
		"<c-l>",
		next,
		mode = { "i", "s" },
		silent = true,
		desc = "next jumpable point",
	},
}

return M
