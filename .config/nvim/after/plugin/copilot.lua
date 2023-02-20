vim.g.copilot_no_tab_map = true
local keymap = vim.keymap.set
keymap("i", '<leader><Tab>', 'copilot#Accept("")', { silent = true, expr = true })
