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
		-- Add diagnostics for failed tests
		local neotest_ns = vim.api.nvim_create_namespace("neotest")
		vim.diagnostic.config({
			virtual_text = {
				prefix = "",
				format = function(diagnostic)
					return diagnostic.message:gsub("\n", " "):gsub("\t", " "):gsub("%s+", " "):gsub("^%s+", "")
				end,
			},
		}, neotest_ns)

		-- Run tests automatically when first
		-- starting neovim and after every save
		local augroup = vim.api.nvim_create_augroup("AutoTest", { clear = true })

		vim.api.nvim_create_autocmd({ "BufWritePost" }, {
			pattern = { "*.go", "*.py" },
			group = augroup,
			callback = function()
				require("neotest").run.run(vim.fn.getcwd())
			end,
		})

		vim.api.nvim_create_autocmd({ "BufReadPost" }, {
			pattern = { "*.go", "*.py" },
			group = augroup,
			callback = function()
				require("neotest").run.run(vim.fn.getcwd())
			end,
			once = true,
		})
	end,
	config = true,
	keys = function()
		return require("plugins.neotest.keys")
	end,
}

return Plugin
