
function! s:ReverseText(text, regtype)
  if !s:linewise
    return a:text->trim("\n")->split('\zs')->reverse()->join('')
  else
    let lines = []
    for line in split(a:text, "\n")
      let indent = matchstr(l:line, '^\s*')
      let rawtext = matchstr(l:line, '\S.*$')
      call add(l:lines, l:indent.l:rawtext->split('\zs')->reverse()->join(''))
    endfor
    return l:lines->join("\n")
  endif
endfunction


function! SetReverse(linewise)
  let s:linewise = a:linewise
  set operatorfunc=ReverseOperator
  return 'g@'
endfunction


function! ReverseOperator(type)
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
    let output = s:ReverseText(l:regtext, l:regtype)
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

