local M = {}

function M.load_globals()
	-- Global Variables (vim.g)
	vim.g.mapleader = " "
	vim.g.python3_host_prog = vim.fn.expand("~/.nvimvenv/bin/python")
end

function M.load_opt_settings()
	-- General Options (vim.opt)
	local opt = vim.opt
	opt.number = true
	opt.expandtab = true
	opt.smartindent = true
	opt.hlsearch = false
	opt.hidden = true
	opt.wrap = false
	opt.incsearch = true
	opt.termguicolors = true
	opt.cursorline = true
	opt.scrolloff = 8
	opt.tabstop = 4
	opt.softtabstop = 4
	opt.shiftwidth = 4
	opt.cmdheight = 2
	opt.guicursor = ""
	opt.swapfile = false
	opt.backup = false
	opt.colorcolumn = "100"
	opt.updatetime = 500
end

function M.load_wo_settings()
	-- Window-local Options (vim.wo)
	vim.wo.signcolumn = "yes"
end

function M.load_o_settings()
	-- Global Options (vim.o)
	vim.o.pumheight = 10
end

function M.setup()
	M.load_globals()
	M.load_opt_settings()
	M.load_wo_settings()
	M.load_o_settings()
end

M.setup()

return M
