
map <Space> <Nop>
let mapleader=" "

" " Insert a space before the cursor
" nnoremap g<Space> i<Space><C-O>:stopinsert<CR>
" Visual selection of the last modified text
nnoremap <expr> <Leader>p '`['.strpart(getregtype(), 0, 1).'`]'

nnoremap Y y$
nnoremap U <C-R>
nnoremap <BS> <Cmd>nohlsearch<CR><Cmd>echo ''<CR>
vnoremap J j
vnoremap K k

nnoremap <M-j> <C-d>
nnoremap <M-k> <C-u>
inoremap <M-e> <C-X><C-E>
inoremap <M-y> <C-X><C-Y>

noremap <M-c> "*y
noremap <M-v> <Cmd>set paste<CR>"*p<Cmd>set nopaste<CR>


" NOT_VSCODE_EXCLUSIVE:
if !exists('g:vscode')
 " INSERT:
inoremap <C-[> <C-O>:stopinsert<CR>
inoremap <C-S> <Esc>:write<CR>gi
inoremap <C-J> <End><CR>
inoremap <C-K> <Up><End><CR>

" Enable undo
inoremap <C-U> <C-G>u<C-U>
inoremap <C-W> <C-G>u<C-W>
inoremap <CR> <C-G>u<CR>

inoremap <S-Up> <C-O>{
inoremap <S-Down> <C-O>}
inoremap <C-Up> <C-X><C-Y>
inoremap <C-Down> <C-X><C-E>

" INSERT_COMMANDLINE_TERMINAL:
" <C-L>   (insert) when 'insertmode' set: Leave Insert mode
" <C-L>   (command-line) do completion on the pattern in front of the
"          cursor and insert the longest common part
noremap! <C-L> <Del>
noremap! <M-p> <C-P>
noremap! <M-n> <C-N>

noremap! ( ()<Left>
noremap! [ []<Left>
noremap! { {}<Left>
noremap! "" ""<Left>
noremap! '' ''<Left>
noremap! <lt>> <lt>><Left>

noremap <M-Space> zz
noremap <M-Bslash> <Esc>
inoremap <M-Bslash> <C-O>:stopinsert<CR>
noremap! <M-p> <C-U>
cnoremap <M-a> <C-Left>
cnoremap <M-f> <C-Right>

noremap! <M-u> <C-U>
noremap! <M-h> <Left>
noremap! <M-l> <Right>
inoremap <M-j> <C-G>j
inoremap <M-k> <C-G>k
cnoremap <M-j> <C-N>
cnoremap <M-k> <C-P>

inoremap <M-t> <C-E>
inoremap <M-y> <C-Y>

nnoremap <silent> <M-]> <Cmd>move+1<CR>
nnoremap <silent> <M-[> <Cmd>move-2<CR>
inoremap <silent> <M-]> <Cmd>move+1<CR>
inoremap <silent> <M-[> <Cmd>move-2<CR>
vnoremap <silent> <M-]> :move'>+1<CR>gv
vnoremap <silent> <M-[> :move'<-2<CR>gv

noremap <M-o> <Cmd>buffers<CR>:b
noremap <M-t> <Cmd>tabnew<CR>:edit <C-D>
noremap <M-T> <Cmd>$tabnew<CR>
noremap <M-g> <Cmd>tabnext<CR>
noremap <M-r> <Cmd>tabprevious<CR>
noremap <M-G> <Cmd>+tabmove<CR>
noremap <M-R> <Cmd>-tabmove<CR>
noremap <M-Q> <Cmd>wincmd c<CR>
noremap <M-O> <Cmd>wincmd o<CR>


" VSCode inspired
" noremap <C-Bslash> <Cmd>wincmd v<CR>
" noremap <C-S-Bslash> <Cmd>wincmd s<CR>
noremap <M-z> <Cmd>set wrap!<CR>
noremap <Leader><C-X> <Cmd>%s/\s\+$//<CR>
noremap <Leader><C-F> ggVG=

endif " END_OF_NOT_VSCODE_EXCLUSIVE
















" VSCODE_EXCLUSIVE:
if exists('g:vscode')

" THIS DOESN'T WORK
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" function! MoveVisualSelection(direction)
"   execute "normal! \<Esc>"
"   let startLine = line("'<")
"   let endLine = line("'>")
"   let lineCount = getbufinfo('%')[0]['linecount']
"   if (a:direction == "Up"   && l:startLine == 1) ||
"    \ (a:direction == "Down" && l:endLine   == l:lineCount) 
"     let [newStart, newEnd] = [l:startLine, l:endLine]
"   else
"     let leaveSelection = 0
"     let vsCodeCommand = 'editor.action.moveLines'.a:direction.'Action'
"     call VSCodeNotifyRange(l:vsCodeCommand, l:startLine, l:endLine, l:leaveSelection)
"     let newStart = a:direction == "Up" ? l:startLine - 1 : l:startLine + 1
"     let newEnd   = a:direction == "Up" ? l:endLine - 1   : l:endLine + 1
"   endif
"   echomsg "New start line: ".l:newStart
"   echomsg "New end line:   ".l:newEnd
"   execute "normal! ".l:newStart."GV".l:newEnd."G"
" endfunction
" 
" 
" vnoremap <M-f> <Cmd>call MoveVisualSelection("Down")<CR>
" vnoremap <M-e> <Cmd>call MoveVisualSelection("Up")<CR>
" 
" xnoremap <M-j> dp`[V`]
" xnoremap <M-k> dkP`[V`]

" THIS DOES WORK
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Moves lines up and down, while keeping the cursor pos
" function! MoveLineUp()
"     call MoveLineOrVisualUp(".", "")
" endfunction
" 
" function! MoveLineDown()
"     call MoveLineOrVisualDown(".", "")
" endfunction
" 
" function! MoveVisualUp()
"     call MoveLineOrVisualUp("'<", "'<,'>")
"     normal gv
" endfunction
" 
" function! MoveVisualDown()
"     call MoveLineOrVisualDown("'>", "'<,'>")
"     normal gv
" endfunction
" 
" function! MoveLineOrVisualUp(line_getter, range)
"     let l_num = line(a:line_getter)
"     if l_num - v:count1 - 1 < 0
"         let move_arg = "0"
"     else
"         let move_arg = a:line_getter." -".(v:count1 + 1)
"     endif
"     call MoveLineOrVisualUpOrDown(a:range."move ".move_arg)
" endfunction
" 
" function! MoveLineOrVisualDown(line_getter, range)
"     let l_num = line(a:line_getter)
"     if l_num + v:count1 > line("$")
"         let move_arg = "$"
"     else
"         let move_arg = a:line_getter." +".v:count1
"     endif
"     call MoveLineOrVisualUpOrDown(a:range."move ".move_arg)
" endfunction
" 
" function! MoveLineOrVisualUpOrDown(move_arg)
"     let col_num = virtcol(".")
"     execute "silent! ".a:move_arg
"     execute "normal! ".col_num."|"
" endfunction
" 
" vnoremap <M-j> :<C-u>call MoveVisualDown()<CR>
" vnoremap <M-k> :<C-u>call MoveVisualUp()<CR>
" 

nnoremap <M-j> <Cmd>call VSCodeNotify('editor.action.moveLinesDownAction')<CR>
nnoremap <M-k> <Cmd>call VSCodeNotify('editor.action.moveLinesUpAction')<CR>

endif " END_OF_VSCODE_EXCLUSIVE

