vim.opt.list = true
vim.opt.termguicolors = false
-- vim.opt.listchars:append "space:⋅"
vim.opt.listchars:append "eol:↴"

require("indent_blankline").setup {
    show_end_of_line = true,

    -- space_char_blankline = " ",
}
