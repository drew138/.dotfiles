local Plugin = {
    "tpope/vim-fugitive",
    dependencies = { { "EdenEast/nightfox.nvim" } },
    keys = function()
        return require("plugins.vim-fugitive.keys")
    end,
}

return Plugin
