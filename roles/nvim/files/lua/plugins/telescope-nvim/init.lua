local M = {
	"nvim-telescope/telescope.nvim",
	branch = "0.1.x",
	dependencies = {
		{ "nvim-lua/plenary.nvim" },
		{ "EdenEast/nightfox.nvim" },
		{ "nvim-tree/nvim-web-devicons" },
		{ "nvim-telescope/telescope-dap.nvim" },
		{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
	},
	opts = function()
		return require("plugins.telescope-nvim.opts")
	end,

	keys = function()
		return require("plugins.telescope-nvim.keys")
	end,

	config = function(_, opts)
		local telescope = require("telescope")
		telescope.setup(opts)
		telescope.load_extension("fzf")

		local hl = vim.api.nvim_set_hl
		hl(0, "TelescopeBorder", { link = "FloatBorder" })
		hl(0, "TelescopePromptBorder", { link = "FloatBorder" })
		hl(0, "TelescopeResultsBorder", { link = "FloatBorder" })
		hl(0, "TelescopePreviewBorder", { link = "FloatBorder" })
		hl(0, "TelescopeNormal", { link = "NormalFloat" })
	end,
}
return M
