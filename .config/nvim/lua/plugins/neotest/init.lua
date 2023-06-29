local Plugin = {
	"nvim-neotest/neotest",
	dependencies = {
		{ "nvim-lua/plenary.nvim" },
		{ "nvim-treesitter/nvim-treesitter" },
		{ "antoinemadec/FixCursorHold.nvim" },
		{ "nvim-neotest/neotest-go" },
		{ "nvim-neotest/neotest-python" },
		{ "rouge8/neotest-rust" },
	},
	opts = function()
		return require("plugins.neotest.opts")
	end,
	init = function()
		local neotest_ns = vim.api.nvim_create_namespace("neotest")
		vim.diagnostic.config({
			virtual_text = {
				prefix = "",
				format = function(diagnostic)
					return diagnostic.message:gsub("\n", " "):gsub("\t", " "):gsub("%s+", " "):gsub("^%s+", "")
				end,
			},
		}, neotest_ns)
		local neotest = require("neotest")
		vim.keymap.set("n", "<c-b>", neotest.summary.toggle, { remap = false, silent = true })
	end,
	config = true,
}

return Plugin
