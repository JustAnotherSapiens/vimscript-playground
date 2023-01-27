" SURROUND


" TODO: Use tr() to add 'change surround' functionality
function! Surround(lchar, rchar, linewise, text, regtype) abort
  let indent = !g:surroundindent ? '\(\s*\)' : '\(\)'
  if !a:linewise
    if a:regtype == 'v' || a:regtype[0] == ''
      let match = '\%^\(\_.\{-}\)\(\n\)\=\%$'
      let replace = a:lchar.'\1'.a:rchar.'\2'
    elseif a:regtype == 'V'
      let match = '\%^'.l:indent.'\(\_.\{-}\)\(\n\)\=\%$'
      let replace = '\1'.a:lchar.'\2'.a:rchar.'\3'
    endif
    let newtext = substitute(a:text, l:match, l:replace, '')
  else
    let match = l:indent.'\([^\n]\+\)'
    let replace = '\1'.a:lchar.'\2'.a:rchar
    let newtext = substitute(a:text, l:match, l:replace, 'g')
  endif
  return l:newtext
endfunction


function! VisualSurround(lchar, rchar, linewise) abort
  let sreg = getreginfo('a')
  execute "normal! \<C-\>\<C-N>gv\"ay"
  let text = getreg('a')
  let regtype = getregtype('a')
  let newtext = Surround(a:lchar, a:rchar, a:linewise, l:text, l:regtype)
  call setreg('a', l:newtext, l:regtype)
  normal! gv"ap
  call setreg('a', l:sreg)
endfunction


let g:surroundindent = v:false


command! -range -nargs=+ SurroundCharwise call VisualSurround(<f-args>, v:false)
command! -range -nargs=+ SurroundLinewise call VisualSurround(<f-args>, v:true)
command! -range -nargs=+ SC call VisualSurround(<f-args>, v:false)
command! -range -nargs=+ SL call VisualSurround(<f-args>, v:true)
command! -range Togglesorroundindent Togglebool g:surroundindent


