local M = {
	adapters = {
		require("neotest-python")({
			dap = { justMyCode = false },
			args = { "--log-level", "DEBUG" },
			runner = "pytest",
		}),
		require("neotest-golang")({
			go_test_args = { "-count=1", "-timeout=60s" },
		}),
		require("neotest-rust")({
			args = { "--no-capture" },
		}),
	},
	quickfix = {
		open = false,
	},
}

return M
