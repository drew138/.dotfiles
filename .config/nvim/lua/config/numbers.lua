local toggle_normal = 'if &nu && mode() != "i" | set rnu   | endif'
local toggle_insert = 'if &nu                  | set nornu | endif'
local numbertoggle = vim.api.nvim_create_augroup('numbertoggle', { clear = true })
vim.api.nvim_create_autocmd('BufEnter', { pattern = '*', command = toggle_normal, group = numbertoggle})
vim.api.nvim_create_autocmd('FocusGained', { pattern = '*', command = toggle_normal, group = numbertoggle})
vim.api.nvim_create_autocmd('InsertLeave', { pattern = '*', command = toggle_normal, group = numbertoggle})
vim.api.nvim_create_autocmd('WinEnter', { pattern = '*', command = toggle_normal, group = numbertoggle})
vim.api.nvim_create_autocmd('BufLeave', { pattern = '*', command = toggle_insert, group = numbertoggle})
vim.api.nvim_create_autocmd('FocusLost', { pattern = '*', command = toggle_insert, group = numbertoggle})
vim.api.nvim_create_autocmd('InsertEnter', { pattern = '*', command = toggle_insert, group = numbertoggle})
vim.api.nvim_create_autocmd('WinLeave', { pattern = '*', command = toggle_insert, group = numbertoggle})