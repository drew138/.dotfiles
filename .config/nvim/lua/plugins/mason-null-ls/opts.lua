local Opts = {
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
}

return Opts
