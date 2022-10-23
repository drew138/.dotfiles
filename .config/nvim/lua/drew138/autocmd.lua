-- toggle numbers
local toggle_normal = 'if &nu && mode() != "i" | set rnu   | endif'
local toggle_insert = 'if &nu                  | set nornu | endif'
local number_toggle = vim.api.nvim_create_augroup('numbertoggle', { clear = true })
local create_autocmd = vim.api.nvim_create_autocmd
local opts_enter = { pattern = '*', command = toggle_normal, group = number_toggle }
local opts_leave = { pattern = '*', command = toggle_insert, group = number_toggle }

create_autocmd('BufEnter', opts_enter)
create_autocmd('FocusGained', opts_enter)
create_autocmd('InsertLeave', opts_enter)
create_autocmd('WinEnter', opts_enter)
create_autocmd('BufLeave', opts_leave)
create_autocmd('FocusLost', opts_leave)
create_autocmd('InsertEnter', opts_leave)
create_autocmd('WinLeave', opts_leave)

-- packer
local packer_user_config = vim.api.nvim_create_augroup('packer_user_config', { clear = true })
local opts = {
    pattern = 'packer.lua',
    command = 'source <afile> | PackerCompile',
    group = packer_user_config
}
create_autocmd('BufWritePost', opts)
-- vim.cmd([[
--   augroup packer_user_config
--     autocmd!
--     autocmd BufWritePost packer.lua source <afile> | PackerCompile
--   augroup end
-- ]])
