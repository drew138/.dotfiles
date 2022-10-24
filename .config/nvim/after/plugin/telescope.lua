-- telescope
local ignore_patterns = {
    'node_modules/.*',
    '.git/*',
    '.cache',
    '%.o',
    '%.a',
    '%.out',
    '%.class',
    '%.pdf',
    '%.mkv',
    '%.mp4',
    '%.zip'
}

local picker_config = {
    previewer = false,
    hidden = true,
    file_ignore_patterns = ignore_patterns
}

require('telescope').setup {
    pickers = {
        find_files = picker_config,
        live_grep = picker_config,
        buffers = picker_config
    },
    extensions = {
        fzf = {
            fuzzy = true,
            override_generic_sorter = true,
            override_file_sorter = true,
            case_mode = "smart_case",
        }
    },
}
require('telescope').load_extension('fzf')
local builtin = require('telescope.builtin')
local keymap = vim.keymap.set
keymap('n', '<leader>ff', builtin.find_files)
keymap('n', '<leader>fg', builtin.live_grep)
keymap('n', '<leader>fb', builtin.buffers)
keymap('n', '<leader>fh', builtin.help_tags)
