-- nvim tree
require("nvim-tree").setup()
local keymap = vim.keymap.set
keymap('n', '<C-n>', ':NvimTreeToggle<CR>', { remap = true })
