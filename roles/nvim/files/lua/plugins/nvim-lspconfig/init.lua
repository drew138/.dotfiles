local M = {
	"neovim/nvim-lspconfig",
	dependencies = { { "filipdutescu/renamer.nvim" } },
	config = function()
		-- Force LSP to use 'rounded' borders (Nvim 0.11 way)
		local orig_util_open_floating_preview = vim.lsp.util.open_floating_preview
		function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
			opts = opts or {}
			opts.border = "rounded"
			return orig_util_open_floating_preview(contents, syntax, opts, ...)
		end

		-- Close quickfix window after entering a file
		vim.api.nvim_create_autocmd("FileType", {
			pattern = "qf",
			callback = function()
				-- Map 'Enter' to jump and close the window immediately
				local opts = { buffer = true, silent = true }
				vim.keymap.set("n", "<CR>", "<CR>:cclose<CR>", opts)
			end,
		})

		-- Keymaps via Autocmd
		vim.api.nvim_create_autocmd("LspAttach", {
			group = vim.api.nvim_create_augroup("UserLspConfig", {}),
			callback = function(ev)
				local set = vim.keymap.set
				local buf = vim.lsp.buf
				local opts = { buffer = ev.buf, silent = true }

				set("n", "<c-t>", buf.hover, opts)
				set("n", "gd", buf.definition, opts)
				set("n", "gi", buf.implementation, opts)
				set("n", "gt", buf.type_definition, opts)
				set("n", "gr", buf.references, opts)
				set({ "n", "v" }, "<leader>ca", buf.code_action, opts)
				set("n", "<c-e>", require("renamer").rename, { noremap = true, silent = true })
			end,
		})

		-- TODO: check this video to migrate
		-- https://www.youtube.com/watch?v=IZnhl121yo0&t=336s
		-- https://github.com/adibhanna/nvim

		require("plugins.nvim-lspconfig.lsp")
	end,
}

return M
