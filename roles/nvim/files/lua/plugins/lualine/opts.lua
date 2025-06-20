local function get_icon()
	if vim.fn.has("macunix") then
		return ""
	elseif vim.fn.has("unix") then
		return ""
	elseif vim.fn.has("win32") or vim.fn.has("win64") then
		return ""
	else
		return ""
	end
end

local M = {
	sections = {
		lualine_c = {
			{
				"filename",
				path = 1,
			},
		},
		lualine_x = {
			"encoding",
			{
				"fileformat",
				symbols = {
					unix = get_icon(),
				},
			},
			"filetype",
		},
	},
	options = {
		disabled_filetypes = {
			statusline = { "NvimTree" },
		},
	},
}

return M
