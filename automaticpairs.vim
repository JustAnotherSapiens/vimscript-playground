
let s:activeautomaticpairs = v:true

let s:matchingpairs = {
  \ '(': ['(', ')'],
  \ '[': ['[', ']'],
  \ '{': ['{', '}'],
  \ '`': ['`', '`'],
  \ '"': ['"', '"'],
  \ '''': ['''', ''''],
  \ '<lt>': ['<', '>'],
  \ }

func! CmdDeletePair()
  let text = getcmdline()
  let curpos = getcmdpos()
  let [part1, part2] = [l:text[:l:curpos-2], l:text[l:curpos-1:]]
  let part1 = l:part1[:-2]
  if s:activeautomaticpairs
    for [lchar, rchar] in values(s:matchingpairs)
      if l:part1[-1:] == l:lchar && l:part2[:0] == l:rchar
        let l:part2 = l:part2[1:]
        break
      endif
    endfor
  endif
  call setcmdline(l:part1.l:part2, l:curpos - 1)
endfunc

func! CmdInsertPair(lchar, rchar)
  let text = getcmdline()
  let curpos = getcmdpos()
  let [part1, part2] = [l:text[:l:curpos - 2], l:text[l:curpos - 1:]]
  if s:activeautomaticpairs
    if a:lchar == ''''
      if l:part1[-1:] !~ '\w'
        let insertedtext = a:lchar.a:rchar
      else
        let insertedtext = a:lchar
      endif
    else
      let insertedtext = a:lchar.a:rchar
    endif
  else
    let insertedtext = a:lchar
  endif
  call setcmdline(l:part1.l:insertedtext.l:part2, l:curpos + 1)
endfunc

function! MapSmartPairs()
  for [key, chars] in items(s:matchingpairs)
    let pair = trim(string(l:chars), '[]')
    execute "cnoremap ".l:key." <Cmd>call CmdInsertPair(".l:pair.")<CR>"
  endfor
  cnoremap <BS> <Cmd>call CmdDeletePair()<CR>
endfunction
call MapSmartPairs()


" noremap! ( ()<Left>
" noremap! [ []<Left>
" noremap! { {}<Left>
" noremap! "" ""<Left>
" noremap! '' ''<Left>
" noremap! <lt>> <lt>><Left>
" inoremap <expr> <BS> "\<BS>\<Del>"

" <C-\>e{expr}<CR>
" <C-R>={expr}<CR>
" map <expr> ...
" getcmdpos()
" " The first column is 1
" setcmdpos({pos})
" " The first position is 1 (byte position)
" getcmdscreenpos()
" " It adds the prompt position
" getcmdline()
" " Only works when the command line is being edited
" " cmap <F7> <C-\>eescape(getcmdline(), ' \')<CR>
" setcmdline({str} [, {pos}])
" " If {pos} is omitted, the cursor is positioned after the text
" getcmdtype()
" getcmdwintype()
" "  :  Ex
" "  >  Debug
" "  /  Forward search
" "  ?  Backward search
" "  @  input()
" "  -  :insert/:append
" "  =  <C-R>=
" getcmdcompltype()
" " Returns an empty string when completions is not defined
" " arglist, command, dir, file, file_in_path, function, history, ...
" " :help :command-complete
" 
" cnoremap <expr> <C-d> (getcmdpos()==len(getcmdline())+1?'<C-d>':'<Del>')
" inoremap <buffer>
" call substitute()
" call getcmdwintype()
" call getchangelist()
" call matchadd('DiffAdd', 'map', -1)
" call getmatches()
" call matchdelete({id})
" call clearmatches()
" 
" function! CleverTab()
"     if strpart(getline('.'), 0, col('.') - 1) =~ '^\s*$'
"       return "\<Tab>"
"     else
"       return "\<C-N>"
"     endif
" endfunction
" inoremap <Tab> <C-R>=CleverTab()<CR>
" 
" 	asdfasdf asdasdfa
" 
" set complete=. " current buffer
" set complete=.,w " current buffer and buffers in other windows
" set complete=i " current and included files
" 
" help mode()
" help ins-special-special
" help profiling

