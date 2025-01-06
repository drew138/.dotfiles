local lspconfig = require("lspconfig")
local capabilities = require("cmp_nvim_lsp").default_capabilities()

lspconfig.nil_ls.setup({
	capabilities = capabilities,
})
