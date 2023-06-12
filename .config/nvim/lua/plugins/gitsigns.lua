local Plugin = {
    "lewis6991/gitsigns.nvim",
    dependencies = { { "EdenEast/nightfox.nvim" } },
    opts = function()
        return require("options.gitsigns")
    end,
    config = true,
}

return Plugin
