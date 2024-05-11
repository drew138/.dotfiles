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
			recursive_run = true,
		}),
		require("neotest-rust")({
			args = { "--no-capture" },
		}),
	},
	quickfix = {
		open = false,
	},
}

return Opts
