
" Normal Mode
nnoremap <M-k> <CMD>m .-2<CR>
nnoremap <M-j> <CMD>m .+1<CR>
nnoremap <M-h> <<
nnoremap <M-l> >>  

" Visual Mode
vnoremap <M-k> :m '<-2<CR>gv
vnoremap <M-j> :m '>+1<CR>gv
vnoremap <M-h> <gv
vnoremap <M-l> >gv 


" NEOVIM DEFAULTS:

" Filetype detection is enabled by default.
" filetype off
" Syntax highlighting is enabled by default.
" syntax off

set nocompatible
set encoding=utf-8
set background=dark
set backupdir=.,~/.local/state/nvim/backup//
set directory=~/.local/state/nvim/swap//
set undodir=~/.local/state/nvim/undo//
set tags=./tags;,tags
set ruler
set laststatus=2
set display=lastline,msgsep
set backspace=indent,eol,start
set fillchars=vert:│,fold:·,sep:|
set listchars=tab:> ,trail:-,nbsp:+
set history=10000
set tabpagemax=50
set switchbuf=uselast
set hidden
set hlsearch
set incsearch
set nojoinspaces
set nostartofline
set wildmenu
set sidescroll=1
set autoindent
set smarttab
set langnoremap
set nolangremap
set autoread
set complete-=i
set shortmess+=F
set shortmess-=S
set showcmd
set nofsync
set ttyfast
set cscopeverbose
set ttimeoutlen=50
set viminfo+=!
set nrformats=bin,hex
set formatoptions=tcqj
set mouse=nvi
set mousemodel=popup_setpos
set belloff=all
set wildoptions=pum,tagfile
set viewoptions+=unix,slash
set viewoptions-=options
set sessionoptions+=unix,slash
set sessionoptions-=options

" 'man.lua' plugin is enabled, so ':Man' is available by default.
" 'matchit' plugin is enabled. To disable it in your config:
let loaded_matchit = 1

" g:vimsyn_embed defaults to "l" to enable Lua highlighting
let g:vimsys_embed = "l"

" to ignore mouse completely
set mouse=

" no 'popup-menu' but the right button extends selection
set mousemodel=extend

" pressing ALT+LeftMouse releases mouse until main cursor moves
nnoremap <M-LeftMouse> <Cmd>
  \ set mouse=<Bar>
  \ echo 'mouse OFF until next cursor-move'<Bar>
  \ autocmd CursorMoved * ++once set mouse&<Bar>
  \ echo 'mouse ON'<CR>

" Also, mouse is not in use in 'command-mode' or at 'more-prompt'.
" So if you need to copy/paste with your terminal then just pressing ':'
" makes Nvim to release the mouse cursor temporarily.

" Default Mappings:

nnoremap Y y$
nnoremap <C-L> <Cmd>nohlsearch<Bar>diffupdate<Bar>normal! <C-L><CR>
inoremap <C-U> <C-G>u<C-U>
inoremap <C-W> <C-G>u<C-W>
xnoremap * y/\V<C-R>"<CR>
xnoremap # y?\V<C-R>"<CR>
nnoremap & :&&<CR>

" Default Autocommands
" ":autocmd {group}"

" nvim_terminal:
" BufReadCmd: Treats "term://" buffers as 'terminal' buffers.

" nvim_cmdwin:
" CmdwinEnter: Limits syntax sync to maxlines=1 in the 'cmdwin'.

