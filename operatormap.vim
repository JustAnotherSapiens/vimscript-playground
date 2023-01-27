" OPERATOR MAPPING FUNCTIONS


function! MappedOperatorFunc(func, args)
  let &operatorfunc = function('OperatorFuncWrapper', [a:func, a:args])
  return 'g@'
endfunction


function! OperatorFuncWrapper(func, args, type)
  let clipboard = &clipboard
  let selection = &selection
  let savedreg = getreginfo('a')
  let visualmarks = {'<': getpos("'<"), '>': getpos("'>")}
  let virtualedit = [&l:virtualedit, &g:virtualedit]
  let visual = #{char: "`[v`]", line: "'[V']", block: "`[\<C-V>`]"}
  try
    set clipboard= selection=inclusive virtualedit=
    let off = getpos("']")[3] " [bufnum, lnum, col, off]
    if l:off != 0
      let vcol1 = strdisplaywidth(strpart(getline("'["), 0, col("']") + l:off))
      let vcol2 = virtcol([line("'["), '$']) - 1
      let extendblock = l:vcol1 >= l:vcol2 ? 'oO$' : 'oO'.l:vcol.'|'
    else
      let extendblock = ''
    endif
    let cmdstr = l:visual[a:type].l:extendblock.'"ay'
    execute "silent noautocmd keepjumps normal! ".l:cmdstr
    let regtext = getreg('a')
    let regtype = getregtype('a')
    let MainFunc = function(a:func, a:args)
    let output = l:MainFunc(l:regtext, l:regtype)
    if type(l:output) == v:t_string
      call setreg('a', l:output, l:regtype)
      normal! gv"ap
    endif
  finally
    let &clipboard = l:clipboard
    let &selection = l:selection
    call setreg('a', l:savedreg)
    call setpos("'<", l:visualmarks['<'])
    call setpos("'>", l:visualmarks['>'])
    let [&l:virtualedit, &g:virtualedit] = l:virtualedit
  endtry
endfunction


" " The most basic way to map an operator
" function! PrintType(type)
"   echomsg a:type
" endfunction
" let &operatorfunc = funcref('PrintType')



" '[ and '] marks store the start and end of the previously changed or
" yanked text.

" 'virtualedit' 've'
" (default: "")
" none, onemore, block, insert, all
" Allow the cursor to be positioned where there are not actual characters,
" like halfway into a tab or beyond the end of the line.
" Note: The offset from getpos() comes from this option.

" 'clipboard' 'cb'
" (default: "")
" unnamed('*' register), unnamedplus('+' register)
" autoselect, autoselectplus
" autoselectml, html, exclude:{pattern}

" 'selection' 'sel'
" (default: "inclusive")
" |   value   | past line | inclusive |
" |-----------|-----------|-----------|
" |    old    |    no     |    yes    |
" | inclusive |    yes    |    yes    |
" | exclusive |    yes    |    no     |
" "past line" means position one character past the line is allowed
" "inclusive" means that the last character is included in operations


" strdisplaywidth({string} [, {col}])
" 22										
" 22                    


" 'ambiwidth' 'ambw
" (default: "single")
" single, double
" Useful for East Asian scripts, CJK characters, etc.

