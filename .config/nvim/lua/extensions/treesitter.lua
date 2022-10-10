-- treesitter
require'nvim-treesitter.configs'.setup {
    -- A list of parser names, or 'all'
    ensure_installed = { 
        'bash',
        'c', 
        'lua', 
        'css',
        'dockerfile',
        'gitignore',
        'go',
        'gomod', 
        'javascript', 
        'json', 
        'latex', 
        'proto',
        'python', 
        'rust', 
        'scss', 
        'solidity', 
        'tsx', 
        'typescript', 
        'vim',
        'yaml', 
        'html',
    },
    sync_install = false,
    auto_install = true,
    highlight={ enable = true }
}
