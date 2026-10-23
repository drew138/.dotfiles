vim.env.PATH = vim.fn.stdpath("data") .. "/python-shim:" .. vim.env.PATH

local M = {
	ui = {
		icons = {
			package_installed = "✓",
			package_pending = "➜",
			package_uninstalled = "✗",
		},
		border = "rounded",
	},
}

return M
