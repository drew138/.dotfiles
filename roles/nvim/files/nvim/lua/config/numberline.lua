local M = {}

function M.set_relative_numbers(enabled)
	if not vim.wo.number then
		return
	end

	if enabled and vim.api.nvim_get_mode().mode ~= "i" then
		vim.wo.relativenumber = true
	else
		vim.wo.relativenumber = false
	end
end

function M.setup_number_autocmds()
	local group = vim.api.nvim_create_augroup("NumberToggleSystem", { clear = true })

	vim.api.nvim_create_autocmd({ "BufEnter", "FocusGained", "InsertLeave", "WinEnter" }, {
		group = group,
		pattern = "*",
		callback = function()
			M.set_relative_numbers(true)
		end,
	})

	vim.api.nvim_create_autocmd({ "BufLeave", "FocusLost", "InsertEnter", "WinLeave" }, {
		group = group,
		pattern = "*",
		callback = function()
			M.set_relative_numbers(false)
		end,
	})
end

function M.setup()
	M.setup_number_autocmds()
end

M.setup()
