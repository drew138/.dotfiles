local Plugin = {
    "jay-babu/mason-nvim-dap.nvim",
    dependencies = {
        { "williamboman/mason.nvim" },
        { "mfussenegger/nvim-dap" },
    },
    opts = function()
        return require("plugins.mason-nvim-dap.opts")
    end,
    config = true,
}

return Plugin
