local M = {
	"mfussenegger/nvim-dap",
	dependencies = {
		{ "nvim-telescope/telescope-dap.nvim" },
		{ "theHamsta/nvim-dap-virtual-text" },
		{ "EdenEast/nightfox.nvim" },
		{ "nvim-neotest/nvim-nio" },
		{ "rcarriga/nvim-dap-ui" },
		{ "leoluz/nvim-dap-go", ft = "go" },
		{
			"mfussenegger/nvim-dap-python",
			ft = "python",
			config = function()
				local dap_python = require("dap-python")
				dap_python.test_runner = "pytest"
				local path = vim.fn.expand("~/.local/share/nvim/mason/packages/debugpy/venv/bin/python")
				dap_python.setup(path)
			end,
		},
	},
	config = function()
		require("dap-go").setup()
		require("dapui").setup()
		require("nvim-dap-virtual-text").setup()

		local signs = {
			DapBreakpoint = { text = "◉", color = "DapUIStop" },
			DapStopped = { text = "➜", color = "DapUIPlayPause" },
		}

		for name, opts in pairs(signs) do
			vim.fn.sign_define(name, {
				text = opts.text,
				texthl = opts.color,
				linehl = opts.color,
				numhl = opts.color,
			})
		end
	end,
	keys = function()
		return require("plugins.nvim-dap.keys")
	end,
}

return M
