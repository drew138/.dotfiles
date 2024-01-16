local ls = require("luasnip")
local snippet = ls.s
local i = ls.insert_node
local fmt = require("luasnip.extras.fmt").fmt

local Snippets = {
	snippet(
		"authfda",
		fmt(
			[[
               from melitk.fda2 import inventory
               inventory.init('{}')
               productive_model = inventory.get('{}')
               {}
             ]],
			{
				i(1, "token"),
				i(2, "model"),
				i(0),
			}
		)
	),
}

return Snippets
