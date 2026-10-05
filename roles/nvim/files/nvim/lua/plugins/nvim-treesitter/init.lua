local M = {
	"nvim-treesitter/nvim-treesitter",
	branch = "main",
	lazy = false,
	build = ":TSUpdate",
	dependencies = {
		{ "EdenEast/nightfox.nvim" },
		{ "nvim-treesitter/nvim-treesitter-context" },
	},

	config = function()
		local opts = require("plugins.nvim-treesitter.opts")

		require("nvim-treesitter").install(opts.languages)

		vim.api.nvim_create_autocmd("FileType", {
			group = vim.api.nvim_create_augroup("treesitter_highlight", { clear = true }),
			callback = function(args)
				local language = vim.treesitter.language.get_lang(args.match)

				if not language or not vim.treesitter.language.add(language) then
					return
				end

				vim.treesitter.start(args.buf, language)
			end,
		})
	end,
}

return M
