vim.opt.number = true
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.hlsearch = false
vim.opt.hidden = true
vim.opt.wrap = false
vim.opt.incsearch = true
vim.opt.termguicolors = true
vim.opt.cursorline = true
vim.opt.scrolloff = 8
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.cmdheight = 2
vim.opt.guicursor = ''
vim.wo.signcolumn = 'yes'
vim.opt.colorcolumn = '100'
vim.g.mapleader = ' '

local keyset = vim.keymap.set
keyset('n', '<Up>', '<NOP>')
keyset('n', '<Down>', '<NOP>')
keyset('n', '<Left>', '<NOP>')
keyset('n', '<Right>', '<NOP>')
