call plug#begin('~/.local/share/nvim/plugged')

" color theme
Plug 'joshdick/onedark.vim'

" dev icons
Plug 'kyazdani42/nvim-web-devicons'

" telescope
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim', { 'tag': '0.1.0' }

" synxtax highlighter
Plug 'sheerun/vim-polyglot'

" coc - autocomplete
Plug 'neoclide/coc.nvim', {'branch': 'release'}

" git

if has('nvim') || has('patch-8.0.902')
  Plug 'mhinz/vim-signify'
else
  Plug 'mhinz/vim-signify', { 'branch': 'legacy' }
endif

" indentation
Plug 'lukas-reineke/indent-blankline.nvim'

call plug#end()

augroup user_colors
  autocmd!
  autocmd ColorScheme * highlight Normal ctermbg=NONE guibg=NONE
augroup END

" onedark conf
set termguicolors 

colorscheme onedark

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
nmap <silent> gr <Plug>(coc-references)

" autocomplete coc
inoremap <expr> <Tab> pumvisible() ? "\<C-n><Space>" : "<Tab>"

" relative / non-relative numbers 
set number

augroup numbertoggle
  autocmd!
  autocmd BufEnter,FocusGained,InsertLeave,WinEnter * if &nu && mode() != "i" | set rnu   | endif
  autocmd BufLeave,FocusLost,InsertEnter,WinLeave   * if &nu                  | set nornu | endif
augroup END
