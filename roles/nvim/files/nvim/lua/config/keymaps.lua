local M = {}

function M.setup_disabled_keys()
	local set = vim.keymap.set
	local disabled_keys = { "<up>", "<down>", "<left>", "<right>" }

	for _, key in ipairs(disabled_keys) do
		set("n", key, "<nop>", { desc = "Arrow keys disabled" })
	end
end

function M.setup_editor_keys()
	local set = vim.keymap.set
	local maps = {
		-- { mode, lhs, rhs, description }
		{ "n", "<leader>w", "<cmd>wa<cr>", "Save all buffers" },
		{ "n", "<leader>q", "<cmd>q<cr>", "Quit current window" },
		{ "n", "<leader>x", "<cmd>wqa<cr>", "Save and quit all" },
		{ "n", "<c-u>", "<c-u>zz", "Scroll up and center" },
		{ "n", "<c-d>", "<c-d>zz", "Scroll down and center" },
	}

	for _, map in ipairs(maps) do
		set(map[1], map[2], map[3], { desc = map[4], silent = true })
	end
end

function M.setup_legacy_keys()
	-- DO NOT EDIT
	-- Kept separate as it uses a different API and specific logic
	vim.api.nvim_set_keymap("v", "p", "pgvy", {
		noremap = true,
		silent = true,
		desc = "Paste without overwriting register",
	})
end

function M.setup()
	M.setup_disabled_keys()
	M.setup_editor_keys()
	M.setup_legacy_keys()
end

M.setup()

return M
