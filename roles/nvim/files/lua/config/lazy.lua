local M = {}

function M.bootstrap_lazy()
	local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
	if not (vim.uv or vim.loop).fs_stat(lazypath) then
		vim.fn.system({
			"git",
			"clone",
			"--filter=blob:none",
			"https://github.com/folke/lazy.nvim.git",
			"--branch=stable",
			lazypath,
		})
	end
	vim.opt.rtp:prepend(lazypath)
end

function M.load_lazy()
	local ok, lazy = pcall(require, "lazy")
	if not ok then
		return
	end

	local opts = {
		ui = {
			border = "rounded",
		},
	}

	lazy.setup("plugins", opts)
end

function M.setup()
	M.bootstrap_lazy()
	M.load_lazy()
end

M.setup()
