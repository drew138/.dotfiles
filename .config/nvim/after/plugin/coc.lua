-- coc
vim.g.coc_global_extensions = {
    'coc-snippets',
    'coc-pairs',
    'coc-tsserver',
    'coc-eslint',
    'coc-prettier',
    'coc-json',
    'coc-word',
    'coc-pyright',
    'coc-clangd',
    'coc-solidity',
    'coc-sumneko-lua',
    'coc-docker',
    'coc-go',
    'coc-ltex',
    'coc-sql',
    'coc-yaml',
    'coc-rust-analyzer',
    'coc-sh',
    'coc-highlight',
    'coc-html',
}

-- Use <leader>k to show documentation in preview window.
function _G.show_docs()
    local cw = vim.fn.expand('<cword>')
    if vim.fn.index({ 'vim', 'help' }, vim.bo.filetype) >= 0 then
        vim.api.nvim_command('h ' .. cw)
    elseif vim.api.nvim_eval('coc#rpc#ready()') then
        vim.fn.CocActionAsync('doHover')
    else
        vim.api.nvim_command('!' .. vim.o.keywordprg .. ' ' .. cw)
    end
end

-- organize go imports
local organize_go_imports = ':silent call CocAction("runCommand", "editor.action.organizeImport")'
local go_imports_group = vim.api.nvim_create_augroup('go_imports_group', { clear = true })
local go_imports_options = { pattern = '*.go', command = organize_go_imports, group = go_imports_group }
vim.api.nvim_create_autocmd('BufWritePre', go_imports_options)

-- keymap
local keymap = vim.keymap.set
local opts = { silent = true, expr = true, replace_keycodes = false }
keymap("n", '<leader>k', '<CMD>lua _G.show_docs()<CR>', { silent = true })
keymap('n', 'gd', '<Plug>(coc-definition)', { remap = true, silent = true })
keymap('n', 'gy', '<Plug>(coc-type-definition)', { remap = true, silent = true })
keymap('n', 'gi', '<Plug>(coc-implementation)', { remap = true, silent = true })
keymap('n', 'gr', '<Plug>(coc-references)', { remap = true, silent = true })
keymap('n', '<C-e>', '<Plug>(coc-rename)', { remap = true })
keymap('i', '<Tab>', 'coc#pum#visible() ? coc#pum#confirm() : "<Tab>"', opts)
