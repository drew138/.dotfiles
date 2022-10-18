local Plug = vim.fn['plug#']

vim.call('plug#begin', '~/.local/share/nvim/plugged')
-- color theme
Plug 'EdenEast/nightfox.nvim'
-- dev icons
Plug 'kyazdani42/nvim-web-devicons'
-- telescope
Plug 'nvim-lua/plenary.nvim'
Plug('nvim-telescope/telescope.nvim', { tag = '0.1.0' })
-- syntax highlighter treesitter
Plug('nvim-treesitter/nvim-treesitter', { ['do'] = ':TSUpdate' })
-- show current code context
Plug 'neovim/nvim-lspconfig'
Plug 'SmiteshP/nvim-navic'
-- spell checker
Plug 'lewis6991/spellsitter.nvim'
-- coc - autocomplete
Plug('neoclide/coc.nvim', { branch = 'release' })
-- comments
Plug 'numToStr/Comment.nvim'
-- tmux navigator
Plug 'christoomey/vim-tmux-navigator'
-- indentation
Plug 'lukas-reineke/indent-blankline.nvim'
-- file system
Plug 'preservim/nerdtree'
-- git
Plug 'airblade/vim-gitgutter'
Plug 'tpope/vim-fugitive'
vim.call('plug#end')
