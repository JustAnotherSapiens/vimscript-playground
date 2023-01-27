
" Static index move
function! SetIndex(length, index = 0)
  let index = a:index
  function! MoveIndex(direction = '', step = 1) closure
    let step = a:step % a:length
    if a:direction == '+'
      let l:index = (l:index + l:step) % a:length
      return l:index
    elseif a:direction == '-'
      let l:index = (l:index - l:step + a:length) % a:length
      return l:index
    else
      return l:index
    endif
  endfunction
  return funcref('MoveIndex')
endfunction

" Linewise visual selection
function! VisualLineRange(upperlimit, lowerlimit)
  execute "normal! \<C-\>\<C-N>"
  call cursor(a:upperlimit, col('.'))
  normal! V
  call cursor(a:lowerlimit, col('.'))
endfunction

" Set 'ts', 'sts' and 'sw'
function! SetTabWidth(tab_width)
  let &tabstop = a:tab_width
  let &softtabstop = a:tab_width
  let &shiftwidth = a:tab_width
endfunction

" Clear the undo history
function! ClearUndo()
  let saved_ul = &undolevels
  set undolevels=-1
  execute "normal! a \<BS>\<Esc>"
  let &undolevels = l:saved_ul
endfunction

command! -nargs=1 -bar Togglebool let <args> = !<args>

command! -nargs=1 -bar Tabwidth
      \ let &tabstop = <args> |
      \ let &softtabstop = <args> |
      \ let &shiftwidth = <args>

let g:ntimeout = 1500
let g:itimeout = 400

augroup InsertTimeout
  autocmd!
  autocmd InsertEnter * let &timeoutlen = g:itimeout
  autocmd InsertLeave * let &timeoutlen = g:ntimeout
augroup END

" Prevent files opened from the standard input to be set as modified
augroup StandardInput
  autocmd!
  autocmd StdinReadPost * set nomodified
augroup END

"          strlen: 2, 4, 8, 8, 12
"        strwidth: 2, 4, 4, 4, 4
" strdisplaywidth: 4, 4, 4, 4, 4

