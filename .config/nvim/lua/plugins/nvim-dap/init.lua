local Plugin = {
    "mfussenegger/nvim-dap",
    dependencies = {
        { "nvim-telescope/telescope-dap.nvim" },
        { "theHamsta/nvim-dap-virtual-text" },
        { "EdenEast/nightfox.nvim" },
        { "rcarriga/nvim-dap-ui" },
        {
            "leoluz/nvim-dap-go",
            ft = "go",
        },
        {
            "mfussenegger/nvim-dap-python",
            ft = "python",
            config = function()
                require("dap-python").test_runner = "pytest"
                local path = "/home/drew/.local/share/nvim/mason/packages/debugpy/venv/bin/python"
                require("dap-python").setup(path)
            end,
        },
    },
    init = function()
        require("dap-go").setup()
        require("dapui").setup()
        require("nvim-dap-virtual-text").setup()

        local sign_define = vim.fn.sign_define
        sign_define("DapBreakpoint", {
            text = "◉",
            texthl = "DapUIStop",
            linehl = "DapUIStop",
            numhl = "DapUIStop",
        })

        sign_define("DapStopped", {
            text = "➜",
            texthl = "DapUIPlayPause",
            linehl = "DapUIPlayPause",
            numhl = "DapUIPlayPause",
        })
    end,
    keys = function()
        return require("plugins.nvim-dap.keys")
    end,
}

return Plugin
