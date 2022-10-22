local toggle_normal = 'if &nu && mode() != "i" | set rnu   | endif'
local toggle_insert = 'if &nu                  | set nornu | endif'
local numbertoggle = vim.api.nvim_create_augroup('numbertoggle', { clear = true })
local create_autocmd = vim.api.nvim_create_autocmd
local opts_enter = { pattern = '*', command = toggle_normal, group = numbertoggle }
local opts_leave = { pattern = '*', command = toggle_insert, group = numbertoggle }

create_autocmd('BufEnter', opts_enter)
create_autocmd('FocusGained', opts_enter)
create_autocmd('InsertLeave', opts_enter)
create_autocmd('WinEnter', opts_enter)
create_autocmd('BufLeave', opts_leave)
create_autocmd('FocusLost', opts_leave)
create_autocmd('InsertEnter', opts_leave)
create_autocmd('WinLeave', opts_leave)

