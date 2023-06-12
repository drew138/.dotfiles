vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

local Plugin = {
    "nvim-tree/nvim-tree.lua",
    dependencies = {
        { "EdenEast/nightfox.nvim" },
        { "kyazdani42/nvim-web-devicons" },
    },
    opts = function()
        return require("options.nvim-tree")
    end,
    cmd = { "NvimTreeToggle" },
    keys = function()
        return require("keys.nvim-tree")
    end,
    config = true,
}

return Plugin
