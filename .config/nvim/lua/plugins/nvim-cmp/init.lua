local Plugin = {
    "hrsh7th/nvim-cmp",
    dependencies = {
        { "neovim/nvim-lspconfig" },
        { "hrsh7th/cmp-nvim-lsp" },
        { "hrsh7th/cmp-buffer" },
        { "hrsh7th/cmp-path" },
        { "hrsh7th/cmp-cmdline" },
        { "hrsh7th/cmp-nvim-lua" },
        { "onsails/lspkind.nvim" },
        {
            "L3MON4D3/LuaSnip",
            build = "make install_jsregexp",
            version = "1.*",
        },
        { "saadparwaiz1/cmp_luasnip" },
    },
    opts = function()
        return require("plugins.nvim-cmp.opts")
    end,
    init = function()
        vim.opt.completeopt = { "menu", "menuone", "noselect" }
    end,
    config = true,
    event = "InsertEnter",
}

return Plugin
