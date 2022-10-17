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
vim.keymap.set('n', '<leader>ff', builtin.find_files)
vim.keymap.set('n', '<leader>fg', builtin.live_grep)
vim.keymap.set('n', '<leader>fb', builtin.buffers)
vim.keymap.set('n', '<leader>fh', builtin.help_tags)
