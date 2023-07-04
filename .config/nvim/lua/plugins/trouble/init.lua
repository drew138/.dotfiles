local Plugin = {
    "folke/trouble.nvim",
    init = function()
        local diagnostic = vim.diagnostic
        local signs = {
            Error = " ",
            Warn = " ",
            Hint = " ",
            Info = " ",
        }

        for type, icon in pairs(signs) do
            local hl = "DiagnosticSign" .. type
            vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
        end

        diagnostic.config({
            underline = {
                severity = vim.diagnostic.severity.ERROR,
            },
            virtual_text = {
                prefix = "",
            },
            signs = true,
            update_in_insert = false,
            severity_sort = true,
            float = {
                show_header = false,
                source = "if_many",
                border = "rounded",
                focusable = true,
            },
        })
    end,
    keys = function()
        return require("plugins.trouble.keys")
    end,
}

return Plugin
