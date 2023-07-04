local Plugin = {
    "nvim-treesitter/nvim-treesitter",
    dependencies = {
        { "EdenEast/nightfox.nvim" },
        { "nvim-treesitter/playground" },
        { "nvim-treesitter/nvim-treesitter-context" },
    },
    opts = function()
        return require("plugins.nvim-treesitter.opts")
    end,

    config = function(_, opts)
        require("nvim-treesitter.configs").setup(opts)
    end,

    build = function()
        require("nvim-treesitter.install").update({ with_sync = true })
    end,
}

return Plugin
