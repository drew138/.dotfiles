local Opts = {
    adapters = {
        require("neotest-python")({
            dap = { justMyCode = false },
            args = { "--log-level", "DEBUG" },
            runner = "pytest",
        }),
        require("neotest-go")({
            experimental = {
                test_table = true,
            },
            args = { "-count=1", "-timeout=60s" },
        }),
    },
    quickfix = {
        enabled = false, -- disable annoying popping split
    },
}

local augroup = vim.api.nvim_create_augroup("AutoTest", { clear = true })

vim.api.nvim_create_autocmd({ "BufWritePost" }, {
    pattern = { "*.go", "*.py" },
    group = augroup,
    callback = function()
        require("neotest").run.run(vim.fn.getcwd())
    end,
})

vim.api.nvim_create_autocmd({ "BufReadPost" }, {
    pattern = { "*.go", "*.py" },
    group = augroup,
    callback = function()
        require("neotest").run.run(vim.fn.getcwd())
    end,
    once = true,
})

return Opts
