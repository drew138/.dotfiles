local ensure_packer = function()
    local fn = vim.fn
    local install_path = fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'
    if fn.empty(fn.glob(install_path)) > 0 then
        fn.system({ 'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path })
        vim.cmd [[packadd packer.nvim]]
        return true
    end
    return false
end

local packer_bootstrap = ensure_packer()

return require('packer').startup(function(use)
    -- packer
    use 'wbthomason/packer.nvim'
    -- lualine
    use 'nvim-lualine/lualine.nvim'
    -- color themes
    use 'EdenEast/nightfox.nvim'
    -- dev icons
    use 'kyazdani42/nvim-web-devicons'
    -- telescope
    use {
        'nvim-telescope/telescope.nvim', tag = '0.1.0',
        requires = { { 'nvim-lua/plenary.nvim' } }
    }
    -- telescope fzf
    use { 'nvim-telescope/telescope-fzf-native.nvim', run = 'make' }
    --  treesitter
    use {
        'nvim-treesitter/nvim-treesitter',
        run = function() require('nvim-treesitter.install').update({ with_sync = true }) end,
    }
    -- show current code context
    use 'neovim/nvim-lspconfig'
    use 'SmiteshP/nvim-navic'
    -- coc - autocomplete
    use { 'neoclide/coc.nvim', branch = 'release' }
    -- comments
    use 'numToStr/Comment.nvim'
    -- tmux navigator
    use 'christoomey/vim-tmux-navigator'
    -- indentation
    use 'lukas-reineke/indent-blankline.nvim'
    -- file system
    use 'nvim-tree/nvim-tree.lua'
    -- git
    use 'airblade/vim-gitgutter'
    use 'tpope/vim-fugitive'
    -- git worktrees
    use 'ThePrimeagen/git-worktree.nvim'


    if packer_bootstrap then
        require('packer').sync()
    end
end)
