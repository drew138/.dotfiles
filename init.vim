set number
set guicursor=
set tabstop=4 softtabstop=4
set shiftwidth=4
set expandtab
set smartindent
set nohlsearch
set hidden
set nowrap
set incsearch
set scrolloff=8
set signcolumn
set colorcolumn=100
set cmdheight=2
set termguicolors
" stop being lazy
noremap <Up> <NOP>
noremap <Down> <NOP>
noremap <Left> <NOP>
noremap <Right> <NOP>
call plug#begin('~/.local/share/nvim/plugged')

" color theme
Plug 'EdenEast/nightfox.nvim'
" dev icons
Plug 'kyazdani42/nvim-web-devicons'

" telescope
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim', { 'tag': '0.1.0' }

" syntax highlighter treesitter
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
" show current code context
Plug 'neovim/nvim-lspconfig'
Plug 'SmiteshP/nvim-navic'
" spell checker
Plug 'lewis6991/spellsitter.nvim'
" coc - autocomplete
Plug 'neoclide/coc.nvim', {'branch': 'release'}
" comments
Plug 'numToStr/Comment.nvim'
" tmux navigator
Plug 'christoomey/vim-tmux-navigator'

" indentation
Plug 'lukas-reineke/indent-blankline.nvim'
" file system
Plug 'preservim/nerdtree'
" markdown preview
Plug 'ellisonleao/glow.nvim'

" git
Plug 'airblade/vim-gitgutter'
call plug#end()

" set theme
colorscheme nightfox
" autocmd highlight Normal guibg=NONE # remove bg
let mapleader = " "

fun! TrimWhiteSpace()
    let l:save = winsaveview()
    keeppatterns %s/\s\+$//e
    call winrestview(l:save)
endfun

augroup FormatWhiteSpace
    autocmd!
    autocmd BufWritePre * : call TrimWhiteSpace()
augroup END
" reload files nerdtree
autocmd BufEnter NERD_tree_* | execute 'normal R'
" move lines up or down
vnoremap J :m '>+1<CR>gv=gv
vnoremap K :m '<-2<CR>gv=gv
" coc syntax highlighting
autocmd FileType json syntax match Comment +\/\/.\+$+

nnoremap <leader>ff <cmd>Telescope find_files<cr>
nnoremap <leader>fg <cmd>Telescope live_grep<cr>
nnoremap <leader>fb <cmd>Telescope buffers<cr>
nnoremap <leader>fh <cmd>Telescope help_tags<cr>
nnoremap <leader>b :ls<cr>:b<space>

" coc maps
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
 map <silent> gr <Plug>(coc-references)
" coc config
let g:coc_global_extensions = [
  \ 'coc-snippets',
  \ 'coc-pairs',
  \ 'coc-tsserver',
  \ 'coc-eslint',
  \ 'coc-prettier',
  \ 'coc-json',
  \ ]
" autocomplete coc
inoremap <silent><expr> <Tab> coc#pum#visible() ? coc#pum#confirm() : "<Tab>"
" Use K to show documentation in preview window
" noremap <silent> K :call <SID>show_documentation()<CR>

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction

" Highlight symbol under cursor on CursorHold
autocmd CursorHold * silent call CocActionAsync('highlight')
" Remap for rename current word
nmap <C-e> <Plug>(coc-rename)

" relative / non-relative numbers
augroup numbertoggle
  autocmd!
  autocmd BufEnter,FocusGained,InsertLeave,WinEnter * if &nu && mode() != "i" | set rnu   | endif
  autocmd BufLeave,FocusLost,InsertEnter,WinLeave   * if &nu                  | set nornu | endif
augroup END

" comments
lua require('Comment').setup()

" file explorer
nmap <C-n> :NERDTreeToggle<CR>
" git gutter
let g:gitgutter_enabled = 1
let g:gitgutter_map_keys = 0

highlight GitGutterChange guifg=#bbbb00 ctermfg=Yellow
highlight GitGutterDelete guifg=#ff2222 ctermfg=Red
nmap ) <Plug>(GitGutterNextHunk)
nmap ( <Plug>(GitGutterPrevHunk)
nmap <C-g> :GitGutterDiffOrig<CR>
lua << EOF
require('telescope').setup{
    pickers = {
        find_files = {
            previewer = false
        },
        live_grep = {
            previewer = false
        },
        buffers = {
            previewer = false
        }
    }
}
EOF
" markdown read
map <leader>g :Glow<CR>
