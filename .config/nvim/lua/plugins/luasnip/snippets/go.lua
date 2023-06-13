local ls = require("luasnip")
local snippet = ls.s
local i = ls.insert_node
local fmt = require("luasnip.extras.fmt").fmt

local Snippets = {
    snippet(
        "gofunc",
        fmt(
            [[
                func {}({}) {} {{
                    {}
                }}
            ]],
            {
                i(1, "name"),
                i(2, "params"),
                i(3, "returns"),
                i(0),
            }
        )
    ),
    snippet(
        "gomethod",
        fmt(
            [[
                func ({}) {} ({}) {} {{
                    {}
                }}
            ]],
            {
                i(1, "struct"),
                i(2, "name"),
                i(3, "params"),
                i(4, "returns"),
                i(0),
            }
        )
    ),
}

return Snippets
