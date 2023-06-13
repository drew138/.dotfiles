local Plugin = {
    "L3MON4D3/LuaSnip",
    build = "make install_jsregexp",
    version = "1.*",
    opts = function()
        return require("plugins.luasnip.opts")
    end,
    init = function()
        local ls = require("luasnip")
        ls.add_snippets("go", require("plugins.luasnip.snippets.go"))
        ls.add_snippets("cpp", require("plugins.luasnip.snippets.cpp"))
    end,
    config = true,
    keys = function()
        return require("plugins.luasnip.keys")
    end,
}

return Plugin
