local ls = require("luasnip")

local function next()
    if ls.expand_or_jumpable() then
        ls.expand_or_jump()
    end
end

local function prev()
    if ls.jumpable(-1) then
        ls.jump(-1)
    end
end

local Keys = {
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

return Keys
