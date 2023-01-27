" VERTICAL VISUAL SWAP
" TODO:
" - Generalize to include copy functionality

command! VisualSwapDown call VerticalVisualSwap(v:false)
command! VisualSwapUp call VerticalVisualSwap(v:true)

command! SwapCharDown call SwapChar(v:false)
command! SwapCharUp call SwapChar(v:true)

function! SwapChar(up)
  "               [0, lnum, col, off, curswant]
  let cursorcol = getcursorcharpos()[2]
  let nextline = !a:up ? line('.') + 1 : line('.') - 1
  let targetcol = col('.')
  let currentchar = matchstr(getline('.'), '\%'.l:targetcol.'c.')
  let nextchar = matchstr(getline(l:nextline), '\%'.l:targetcol.'c.')
  if l:nextchar != ''
    let newcurrentline = substitute(getline('.'), '\%'.l:targetcol.'c.', l:nextchar, '')
    let newnextline = substitute(getline(l:nextline), '\%'.l:targetcol.'c.', l:currentchar, '')
    call setline(line('.'), l:newcurrentline)
    call setline(l:nextline, l:newnextline)
    call setcursorcharpos(l:nextline, l:cursorcol)
  endif
endfunction

function! VerticalVisualSwap(up)
  let areg = getreginfo('a')
  let breg = getreginfo('b')
  execute "normal! \<C-\>\<C-N>"
  let cselbeg = getpos("'<")
  let cselend = getpos("'>")
  let xline = !a:up ? l:cselbeg[1] + 1 : l:cselbeg[1] - 1
  let xselbeg = [0, l:xline, l:cselbeg[2], l:cselbeg[3]]
  let xselend = [0, l:xline, l:cselend[2], l:cselend[3]]
  normal! gv"ay
  call setpos("'<", l:xselbeg)
  call setpos("'>", l:xselend)
  normal! gv"bygv"ap
  call setpos("'<", l:cselbeg)
  call setpos("'>", l:cselend)
  normal! gv"bp
  call setpos("'<", l:xselbeg)
  call setpos("'>", l:xselend)
  normal! gv
  call setreg('a', l:areg)
  call setreg('b', l:areg)
endfunction

" function! SurroundOperator(type)
"   let clipboard = &clipboard
"   let selection = &selection
"   let savedreg = getreginfo('a')
"   let visualmarks = {'<': getpos("'<"), '>': getpos("'>")}
"   let virtualedit = [&l:virtualedit, &g:virtualedit]
"   let visual = #{char: "`[v`]", line: "'[V']", block: "`[\<C-V>`]"}
"   try
"     set clipboard= selection=inclusive virtualedit=
"     let off = getpos("']")[3] " [bufnum, lnum, col, off]
"     if l:off != 0
"       let vcol1 = strdisplaywidth(strpart(getline("'["), 0, col("']") + l:off))
"       let vcol2 = virtcol([line("'["), '$']) - 1
"       let extendblock = l:vcol1 >= l:vcol2 ? 'oO$' : 'oO'.l:vcol.'|'
"     else
"       let extendblock = ''
"     endif
"     let cmdstr = l:visual[a:type].l:extendblock.'"ay'
"     execute "silent noautocmd keepjumps normal! ".l:cmdstr
"     let regtext = getreg('a')
"     let regtype = getregtype('a')
"     let output = s:Surround(l:regtext, l:regtype)
"     if type(l:output) == v:t_string
"       call setreg('a', l:output, l:regtype)
"       normal! gv"ap
"     endif
"   finally
"     let &clipboard = l:clipboard
"     let &selection = l:selection
"     call setreg('a', l:savedreg)
"     call setpos("'<", l:visualmarks['<'])
"     call setpos("'>", l:visualmarks['>'])
"     let [&l:virtualedit, &g:virtualedit] = l:virtualedit
"   endtry
" endfunction


