local Opts = {
    ensure_installed = {
        -- completion
        "luasnip",

        -- diagnostics
        "actionlint",
        "buf",
        "commitlint",
        "hadolint",
        "jsonlint",
        "markdownlint",
        "flake8",
        "shellcheck",
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
        "rustfmt",
        "trim_whitespace",
    },
    automatic_installation = true,
}

return Opts
