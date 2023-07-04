local Plugin = {
    "lukas-reineke/indent-blankline.nvim",
    dependencies = { { "EdenEast/nightfox.nvim" } },
    init = function()
        vim.opt.list = true
        vim.opt.termguicolors = false
        vim.opt.listchars:append("eol:↴")
    end,
    opts = function()
        return require("plugins.indent_blankline.opts")
    end,
    config = true,
}
return Plugin
