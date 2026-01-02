local M = {}

function M.set_diagnostics()
	vim.diagnostic.config({
		underline = {
			severity = vim.diagnostic.severity.ERROR,
		},
		virtual_text = {
			prefix = "",
		},
		signs = {
			text = {
				[vim.diagnostic.severity.ERROR] = " ",
				[vim.diagnostic.severity.WARN] = " ",
				[vim.diagnostic.severity.HINT] = " ",
				[vim.diagnostic.severity.INFO] = " ",
			},
		},
		update_in_insert = false,
		severity_sort = true,
		float = {
			show_header = false,
			source = "if_many",
			border = "rounded",
			focusable = true,
		},
	})
end

function M.setup_editor_keys()
	local set = vim.keymap.set
	local diagnostic = vim.diagnostic
	local maps = {
		-- { mode, lhs, rhs, description }
		{ "n", "<c-s>", diagnostic.open_float, "Show diagnostic" },
		{ "n", "K", diagnostic.goto_prev, "Go to previous diagnostic" },
		{ "n", "J", diagnostic.goto_next, "Go to next diagnostic" },
	}

	for _, map in ipairs(maps) do
		set(map[1], map[2], map[3], { desc = map[4], silent = true })
	end
end

function M.setup()
	M.set_diagnostics()
	M.setup_editor_keys()
end

M.setup()
