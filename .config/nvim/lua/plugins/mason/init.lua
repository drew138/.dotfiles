local Plugin = {
    "williamboman/mason.nvim",
    opts = function()
        return require("plugins.mason.opts")
    end,
    dependencies = {
        { "williamboman/mason-lspconfig.nvim" },
        { "jay-babu/mason-nvim-dap.nvim" },
        { "jay-babu/mason-null-ls.nvim" },
        { "mfussenegger/nvim-dap" },
    },
    build = ":MasonUpdate",

    config = true,
    init = function()
        require("mason-lspconfig").setup({
            ensure_installed = {
                "ansiblels",
                "awk_ls",
                "bashls",
                "clangd",
                "cssls",
                "docker_compose_language_service",
                "dockerls",
                "gopls",
                "jsonls",
                "lua_ls",
                "marksman",
                "pyright",
                "rust_analyzer",
                "sqlls",
                "tailwindcss",
                "terraformls",
                "tsserver",
                "yamlls",
            },
            automatic_installation = true,
        })

        require("mason-nvim-dap").setup({
            ensure_installed = {
                "delve",
                "python",
                "cppdbg",
                "bash",
                "node2",
            },
            automatic_installation = true,
        })

        require("mason-null-ls").setup({
            ensure_installed = {
                -- code actions
                "gomodifytags",
                "impl",

                -- completion
                "luasnip",

                -- diagnostics
                "stylelint",
                "actionlint",
                "ansible-lint",
                "buf",
                "commitlint",
                "hadolint",
                "jsonlint",
                "markdownlint",
                "misspell",
                "flake8",
                "shellcheck",
                "sqlfluff",
                "yamllint",
                "selene",

                -- formatting
                "stylua", -- lua
                "black", -- python
                "beautysh", -- shell
                "clang_format",
                "buf",
                "prettier",
                -- go
                "gofmt",
                "goimports",
                "goimports-reviser",
                "golines",
                --
                "protolint",
                "rustfmt",
                "shfmt",
                "trim_whitespace",

                -- "clang_check",

                -- "shellcheck",
                -- "dotenv_linter",
                -- "zsh",
                -- "gospel",

                -- flake8
            },
            automatic_installation = true,
        })
    end,
}

return Plugin
