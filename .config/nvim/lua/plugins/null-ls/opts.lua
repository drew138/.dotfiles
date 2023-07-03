local null_ls = require("null-ls")
local formatting_augroup = vim.api.nvim_create_augroup("LspFormatting", {})

local Opts = {
    sources = {
        -- completion
        null_ls.builtins.completion.luasnip,

        -- diagnostics
        null_ls.builtins.diagnostics.actionlint,
        null_ls.builtins.diagnostics.buf,
        null_ls.builtins.diagnostics.commitlint,

        null_ls.builtins.diagnostics.flake8,
        null_ls.builtins.diagnostics.jsonlint,
        null_ls.builtins.diagnostics.yamllint,
        null_ls.builtins.diagnostics.hadolint,
        null_ls.builtins.diagnostics.selene,
        null_ls.builtins.diagnostics.markdownlint,
        null_ls.builtins.diagnostics.shellcheck,

        -- formatting
        null_ls.builtins.formatting.beautysh,
        null_ls.builtins.formatting.stylua,
        null_ls.builtins.formatting.black,
        null_ls.builtins.formatting.buf,
        null_ls.builtins.formatting.clang_format,
        null_ls.builtins.formatting.gofmt,
        null_ls.builtins.formatting.goimports,
        null_ls.builtins.formatting.goimports_reviser,
        null_ls.builtins.formatting.golines,
        null_ls.builtins.formatting.rustfmt,
        null_ls.builtins.formatting.trim_whitespace,
        null_ls.builtins.formatting.prettier,
    },
    on_attach = function(client, bufnr)
        if client.supports_method("textDocument/formatting") then
            vim.api.nvim_clear_autocmds({
                group = formatting_augroup,
                buffer = bufnr,
            })
            vim.api.nvim_create_autocmd("BufWritePre", {
                group = formatting_augroup,
                buffer = bufnr,
                callback = function()
                    vim.lsp.buf.format({ bufnr = bufnr })
                end,
            })
        end
    end,
}

return Opts
