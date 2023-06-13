local lspconfig = require("lspconfig")
local capabilities = require("cmp_nvim_lsp").default_capabilities()

lspconfig.docker_compose_language_service.setup({
	capabilities = capabilities,
})
