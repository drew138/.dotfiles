local ok, _ = pcall(require, "dap")
if not ok then return end

local keyset = vim.keymap.set
local sign_define = vim.fn.sign_define

require('dap-go').setup()
require("dapui").setup()
require("nvim-dap-virtual-text").setup()

keyset("n", "<leader>5", ":lua require'dap'.step_over()<CR>")
keyset("n", "<leader>6", ":lua require'dap'.continue()<CR>")
keyset("n", "<leader>7", ":lua require'dap'.step_into()<CR>")
keyset("n", "<leader>8", ":lua require'dap'.step_out()<CR>")
keyset("n", "<leader>b", ":lua require'dap'.toggle_breakpoint()<CR>")
keyset("n", "<leader>lp", ":lua require'dap'.set_breakpoint(nil, nil, vim.fn.input('Log point message: '))<CR>")
keyset("n", "<leader>dr", ":lua require'dap'.repl.open()<CR>")
keyset("n", "<leader>dt", ":lua require'dap-go'.debug_test()<CR>")
keyset('n', '<leader>di', function() require "dap.ui.widgets".hover() end)

sign_define('DapBreakpoint', {
    text = '',
    texthl = 'DapUIStop',
    linehl = 'DapUIStop',
    numhl = 'DapUIStop'
})

sign_define('DapStopped', {
    text = '',
    texthl = 'DapUIPlayPause',
    linehl = 'DapUIPlayPause',
    numhl = 'DapUIPlayPause'
})
