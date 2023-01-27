
let g:surroundindent = v:false


" TODO: Use tr() to add 'change surround' functionality
function! s:Surround(text, regtype) abort
  let indent = !g:surroundindent ? '\(\s*\)' : '\(\)'
  if !s:linewise
    if a:regtype == 'v' || a:regtype[0] == ''
      let match = '\%^\(\_.\{-}\)\(\n\)\=\%$'
      let replace = s:lchar.'\1'.s:rchar.'\2'
    elseif a:regtype == 'V'
      let match = '\%^'.l:indent.'\(\_.\{-}\)\(\n\)\=\%$'
      let replace = '\1'.s:lchar.'\2'.s:rchar.'\3'
    endif
    let newtext = substitute(a:text, l:match, l:replace, '')
  else
    let match = l:indent.'\([^\n]\+\)'
    let replace = '\1'.s:lchar.'\2'.s:rchar
    let newtext = substitute(a:text, l:match, l:replace, 'g')
  endif
  return l:newtext
endfunction


function! SetSurround(lchar, rchar, linewise)
  let s:lchar = a:lchar
  let s:rchar = a:rchar
  let s:linewise = a:linewise
  set operatorfunc=SurroundOperator
  return 'g@'
endfunction


function! SurroundOperator(type)
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
    let output = s:Surround(l:regtext, l:regtype)
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


function! VisualSurround(lchar, rchar, linewise) abort
  let s:lchar = a:lchar
  let s:rchar = a:rchar
  let s:linewise = a:linewise
  let sreg = getreginfo('a')
  execute "normal! \<C-\>\<C-N>gv\"ay"
  let text = getreg('a')
  let regtype = getregtype('a')
  let newtext = s:Surround(l:text, l:regtype)
  call setreg('a', l:newtext, l:regtype)
  normal! gv"ap
  call setreg('a', l:sreg)
endfunction


command! -range -nargs=+ SurroundCharwise call VisualSurround(<f-args>, v:false)
command! -range -nargs=+ SurroundLinewise call VisualSurround(<f-args>, v:true)
command! -range -nargs=+ SC call VisualSurround(<f-args>, v:false)
command! -range -nargs=+ SL call VisualSurround(<f-args>, v:true)
command! -range Togglesorroundindent Togglebool g:surroundindent

