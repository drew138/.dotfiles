-- telescope
require('telescope').setup {
    pickers = {
        find_files = {
            previewer = false,
            hidden = true
        },
        live_grep = {
            previewer = false,
            hidden = true
        },
        buffers = {
            previewer = false,
            hidden = true
        }
    }
}

local builtin = require('telescope.builtin')
local keymap = vim.keymap.set
keymap('n', '<leader>ff', builtin.find_files)
keymap('n', '<leader>fg', builtin.live_grep)
keymap('n', '<leader>fb', builtin.buffers)
keymap('n', '<leader>fh', builtin.help_tags)
