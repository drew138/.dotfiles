local Plugin = {
    "L3MON4D3/LuaSnip",
    build = "make install_jsregexp",
    version = "1.*",
    opts = function()
        return require("plugins.luasnip.opts")
    end,
    config = true,
    keys = function()
        return require("plugins.luasnip.keys")
    end,
}

return Plugin
