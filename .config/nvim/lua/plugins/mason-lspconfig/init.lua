local Plugin = {
    "williamboman/mason-lspconfig.nvim",
    dependencies = {
        { "williamboman/mason.nvim" },
        { "neovim/nvim-lspconfig" },
    },
    opts = function()
        return require("plugins.mason-lspconfig.opts")
    end,
    config = true,
}

return Plugin
