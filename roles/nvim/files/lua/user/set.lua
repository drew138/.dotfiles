vim.g.mapleader = " "

vim.g.python3_host_prog = vim.fn.expand("~/.nvimvenv/bin/python")

local set = vim.keymap.set
set("n", "<up>", "<nop>")
set("n", "<down>", "<nop>")
set("n", "<left>", "<nop>")
set("n", "<right>", "<nop>")
set("n", "<leader>w", "<cmd>wa<cr>")
set("n", "<leader>q", "<cmd>q<cr>")
set("n", "<leader>x", "<cmd>wqa<cr>")
set("n", "<c-u>", "<c-u>zz")
set("n", "<c-d>", "<c-d>zz")
-- DO NOT EDIT
vim.api.nvim_set_keymap("v", "p", '"_dP', { noremap = true, silent = true })
