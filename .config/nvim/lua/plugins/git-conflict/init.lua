local Plugin = {
    "akinsho/git-conflict.nvim",
    version = "*",
    opts = function()
        return require("plugins.git-conflict.opts")
    end,
    config = true,
}

return Plugin
