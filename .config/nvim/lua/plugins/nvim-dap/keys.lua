local function debug_test()
	local filetype = vim.bo.filetype
	if filetype == "go" then
		require("dap-go").debug_test()
	elseif filetype == "python" then
		require("dap-python").test_method()
	end
end

local Keys = {
	{ "<leader>dt", debug_test, desc = "debug current test selection" },
	{ "<leader>di", "<cmd>lua require'dap.ui.widgets'.hover()<cr>", desc = "see object current value" },
	{ "<leader>dr", "<cmd>lua require'dap'.repl.open()<cr>", desc = "open repl window" },
	{ "<leader>5", "<cmd>lua require'dap'.step_over()<cr>", desc = "step over" },
	{ "<leader>6", "<cmd>lua require'dap'.continue()<cr>", desc = "continue" },
	{ "<leader>7", "<cmd>lua require'dap'.step_into()<cr>", desc = "step into" },
	{ "<leader>8", "<cmd>lua require'dap'.step_out()<cr>", desc = "step out" },
	{ "<leader>b", "<cmd>lua require'dap'.toggle_breakpoint()<cr>", desc = "toggle breakpoint" },
}

return Keys
