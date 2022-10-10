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
    'coc-docker',
    'coc-go',
    'coc-ltex',
    'coc-sql',
    'coc-yaml',
    'coc-rust-analyzer',
    'coc-sh',
    'coc-highlight',
    'coc-html',
    'coc-tabnine',
}

-- Use <leader>k to show documentation in preview window.
function _G.show_docs()
    local cw = vim.fn.expand('<cword>')
    if vim.fn.index({'vim', 'help'}, vim.bo.filetype) >= 0 then
        vim.api.nvim_command('h ' .. cw)
    elseif vim.api.nvim_eval('coc#rpc#ready()') then
        vim.fn.CocActionAsync('doHover')
    else
        vim.api.nvim_command('!' .. vim.o.keywordprg .. ' ' .. cw)
    end
end

vim.keymap.set("n", '<leader>k', '<CMD>lua _G.show_docs()<CR>', {silent = true})
vim.keymap.set('n', 'gd', '<Plug>(coc-definition)', { remap = true, silent = true })
vim.keymap.set('n', 'gy', '<Plug>(coc-type-definition)', { remap = true, silent = true })
vim.keymap.set('n', 'gi', '<Plug>(coc-implementation)', { remap = true, silent = true })
vim.keymap.set('n', 'gr', '<Plug>(coc-references)', { remap = true, silent = true })
vim.keymap.set('n', '<C-e>', '<Plug>(coc-rename)', { remap = true })
vim.keymap.set('i', '<Tab>', 'coc#pum#visible() ? coc#pum#confirm() : "<Tab>"', { silent = true, expr= true })
