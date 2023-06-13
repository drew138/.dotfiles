vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

local Plugin = {
    "nvim-tree/nvim-tree.lua",
    dependencies = {
        { "EdenEast/nightfox.nvim" },
        { "kyazdani42/nvim-web-devicons" },
    },
    opts = function()
        return require("plugins.nvim-tree.opts")
    end,
    cmd = { "NvimTreeToggle" },
    keys = function()
        return require("plugins.nvim-tree.keys")
    end,
    config = true,
}

return Plugin
