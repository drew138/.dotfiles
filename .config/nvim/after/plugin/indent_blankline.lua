-- set colorscheme for indentation
vim.cmd("colorscheme nightfox")
-- indent_blankline config
vim.opt.list = true
vim.opt.termguicolors = false
vim.opt.listchars:append "eol:↴"

require("indent_blankline").setup {
    show_end_of_line = true,
}
