set nocompatible              " be iMproved, required
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'

Plugin 'jelera/vim-javascript-syntax'
Plugin 'pangloss/vim-javascript'
Plugin 'nathanaelkane/vim-indent-guides'
Plugin 'Raimondi/delimitMate'
Plugin 'saltstack/salt-vim'
Plugin 'fatih/vim-go'
Plugin 'tyru/open-browser.vim'

"Plugin 'Valloric/YouCompleteMe'

" These are the tweaks I apply to YCM's config, you don't need them but they might help.
" YCM gives you popups and splits by default that some people might not like, so these should tidy it up a bit for you.
"let g:ycm_add_preview_to_completeopt=0
"let g:ycm_confirm_extra_conf=0
"set completeopt-=preview

"Plugin 'marijnh/tern_for_vim'

" The following are examples of different formats supported.
" Keep Plugin commands between vundle#begin/end.

" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required
" To ignore plugin indent changes, instead use:
"filetype plugin on
"
" Brief help
" :PluginList       - lists configured plugins
" :PluginInstall    - installs plugins; append `!` to update or just :PluginUpdate
" :PluginSearch foo - searches for foo; append `!` to refresh local cache
" :PluginClean      - confirms removal of unused plugins; append `!` to auto-approve removal
"
" see :h vundle for more details or wiki for FAQ
" Put your non-Plugin stuff after this line
imap <C-c> <CR><Esc>O

function! MySwapUp()
  if ( line( '.' ) > 1 )
    let cur_col = virtcol(".") - 1
    if ( line( '.' ) == line( '$' ) )
      normal ddP
    else
      normal ddkP
    endif
    execute "normal " . cur_col . "|"
  endif
endfunction

function! MySwapDown()
  if ( line( '.' ) < line( '$' ) )
    let cur_col = virtcol(".")
    normal ddp
    execute "normal " . cur_col . "|"
  endif
endfunction

noremap <silent> <C-Up> :call MySwapUp()<CR>
noremap <silent> <C-Down> :call MySwapDown()<CR>

set cindent
set hlsearch
set incsearch
set backupdir=~/.backup
set directory=~/.backup
set et
set cinoptions=:0,(s,u0,U1

" Smart Tab
set smarttab
set tabstop=4
set shiftwidth=4
set expandtab
" avoid tab2space expansion in Makefile, .mak etc.
au FileType make setlocal nosmarttab | setlocal noexpandtab

map <F6> :buffers<CR>:e #
map <C-tab> :b#<cr>
imap <C-tab> :b#<cr>

if !has('gui_running')
  colorscheme delek
else
  colorscheme peachpuff
endif
set guifont=Monospace\ 12
match ErrorMsg '\s\+$'

let g:netrw_nogx = 1 " disable netrw's gx mapping.
nmap gx <Plug>(openbrowser-smart-search)
vmap gx <Plug>(openbrowser-smart-search)
