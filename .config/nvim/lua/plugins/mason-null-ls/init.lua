local Plugin = {
    "jay-babu/mason-null-ls.nvim",
    dependencies = {
        { "williamboman/mason.nvim" },
        { "jose-elias-alvarez/null-ls.nvim" },
    },
    opts = function()
        return require("plugins.mason-null-ls.opts")
    end,
    config = true,
}

return Plugin
