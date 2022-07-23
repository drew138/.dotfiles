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

" onedark conf
set termguicolors 

colorscheme onedark

" coc syntax highlighting
autocmd FileType json syntax match Comment +\/\/.\+$+

inoremap <silent><expr> <TAB>
	  \ pumvisible() ? coc#_select_confirm() :
	  \ coc#expandableOrJumpable() ?
	  \ "\<C-r>=coc#rpc#request('doKeymap', ['snippets-expand-jump',''])\<CR>" :
	  \ <SID>check_back_space() ? "\<TAB>" :
	  \ coc#refresh()
	function! s:check_back_space() abort
	  let col = col('.') - 1
	  return !col || getline('.')[col - 1]  =~# '\s'
	endfunction
	let g:coc_snippet_next = '<tab>'

nnoremap <leader>ff <cmd>Telescope find_files<cr>
nnoremap <leader>fg <cmd>Telescope live_grep<cr>
nnoremap <leader>fb <cmd>Telescope buffers<cr>
nnoremap <leader>fh <cmd>Telescope help_tags<cr>
nnoremap <leader>b :ls<cr>:b<space>
