local M = {}

M.servers = {
	"ansiblels",
	"bashls",
	"clangd",
	"docker_compose_language_service",
	"dockerls",
	"gopls",
	"jsonls",
	"lua_ls",
	"marksman",
	"sqlls",
	"terraformls",
	"pyright",
	"ruff",
	"rust_analyzer",
	"ts_ls",
	"gh_actions_ls",
	"yamlls",
	"tombi",
}

function M.setup_ui()
	-- Force LSP to use 'rounded' borders
	local orig_util_open_floating_preview = vim.lsp.util.open_floating_preview
	vim.lsp.util.open_floating_preview = function(contents, syntax, opts, ...)
		opts = opts or {}
		opts.border = "rounded"
		return orig_util_open_floating_preview(contents, syntax, opts, ...)
	end

	-- Close quickfix window after entering a file
	vim.api.nvim_create_autocmd("FileType", {
		pattern = "qf",
		group = vim.api.nvim_create_augroup("QuickfixFormatting", { clear = true }),
		callback = function()
			local opts = { buffer = true, silent = true }
			vim.keymap.set("n", "<CR>", "<CR>:cclose<CR>", opts)
		end,
	})
end

function M.map_lsp_keys(bufnr)
	local set = vim.keymap.set
	local buf = vim.lsp.buf
	local opts = { buffer = bufnr, silent = true }

	set("n", "<c-t>", buf.hover, opts)
	set("n", "gd", buf.definition, opts)
	set("n", "gi", buf.implementation, opts)
	set("n", "gt", buf.type_definition, opts)
	set("n", "gr", buf.references, opts)
	set({ "n", "v" }, "<leader>ca", buf.code_action, opts)
	-- set("n", "<c-e>", buf.rename, { buffer = bufnr, noremap = true, silent = true })
end

-- Highlights: Symbol highlighting under cursor
function M.setup_document_highlights(client, bufnr)
	local method = vim.lsp.protocol.Methods.textDocument_documentHighlight
	if not client.supports_method(method, { bufnr = bufnr }) then
		return
	end

	local highlight_group = vim.api.nvim_create_augroup("LspHighlight", { clear = false })

	vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
		buffer = bufnr,
		group = highlight_group,
		callback = vim.lsp.buf.document_highlight,
	})

	vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
		buffer = bufnr,
		group = highlight_group,
		callback = vim.lsp.buf.clear_references,
	})

	vim.api.nvim_create_autocmd("LspDetach", {
		group = highlight_group,
		callback = function(event)
			vim.lsp.buf.clear_references()
			vim.api.nvim_clear_autocmds({ group = "LspHighlight", buffer = event.buf })
		end,
	})
end

function M.bootstrap_servers()
	for _, server in ipairs(M.servers) do
		vim.lsp.enable(server)
	end
end

function M.configure_attachments()
	vim.api.nvim_create_autocmd("LspAttach", {
		group = vim.api.nvim_create_augroup("UserLspConfig", { clear = true }),
		callback = function(event)
			local client = vim.lsp.get_client_by_id(event.data.client_id)
			if not client then
				return
			end

			M.map_lsp_keys(event.buf)
			M.setup_document_highlights(client, event.buf)
		end,
	})
end

function M.setup()
	M.setup_ui()
	M.bootstrap_servers()
	M.configure_attachments()
end

M.setup()
