local Plugin = {
    "nvim-telescope/telescope.nvim",
    branch = "0.1.x",
    dependencies = {
        { "nvim-lua/plenary.nvim" },
        { "EdenEast/nightfox.nvim" },
        { "kyazdani42/nvim-web-devicons" },
        { "nvim-telescope/telescope-dap.nvim" },
        { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    },
    opts = function()
        return require("plugins.telescope.opts")
    end,

    keys = function()
        return require("plugins.telescope.keys")
    end,

    config = function(_, opts)
        local telescope = require("telescope")
        telescope.setup(opts)
        telescope.load_extension("fzf")
    end,
}
return Plugin
