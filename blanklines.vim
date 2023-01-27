" ADD & REMOVE BLANK LINES

command! -count=1 -nargs=1 Blanklinesadd call DualBlankLines(<args>, 0, <count>)
command! -count=1 -nargs=1 Blanklinesremove call DualBlankLines(<args>, 1, <count>)

command! -count=1 -nargs=1 Blanklineaddbelow call BlankLine(<args>, 0, 0, <count>)
command! -count=1 -nargs=1 Blanklineaddabove call BlankLine(<args>, 0, 1, <count>)
command! -count=1 -nargs=1 Blanklineremovebelow call BlankLine(<args>, 1, 0, <count>)
command! -count=1 -nargs=1 Blanklineremoveabove call BlankLine(<args>, 1, 1, <count>)

function! FirstNonBlankChar(line)
  let byteindex = match(getline(a:line), '\v%(\S|\n)')
  call cursor(a:line, l:byteindex + 1)
endfunction

function! RemoveLine(target)
  let [curline, curcol] = getpos('.')[1:2]
  if a:target != 0
    execute a:target."delete _"
    let newcurline = a:target < l:curline ? l:curline - 1 : l:curline
    call cursor(l:newcurline, l:curcol)
  endif
endfunction

function! BlankLine(visual, remove, above, n = 1, line = line('.'))
  execute "normal! \<C-\>\<C-N>"
  let line = !a:visual ? a:line : (!a:above ? line("'>") : line("'<"))
  call cursor(l:line, col('.'))
  for i in range(a:n)
    if !a:remove
      let upperline = !a:above ? l:line : l:line - 1
      call append(l:upperline, '')
    else
      let flags = !a:above ? 'nW' : 'bnWz'
      let targetline = search('^\s*$', l:flags)
      call RemoveLine(l:targetline)
    endif
  endfor
endfunction

function! DualBlankLines(visual, remove, n = 1, line = line('.'))
  if a:visual
    call BlankLine(v:true, a:remove, v:false, a:n)
    call BlankLine(v:true, a:remove, v:true, a:n)
  else
    call BlankLine(v:false, a:remove, v:false, a:n, a:line)
    call BlankLine(v:false, a:remove, v:true, a:n, a:line)
  endif
endfunction

" TODO:
" 1. Code refactoring of BlankLine() and DualBlankLines()

" DONE: Use SurroundCharwise with escaped spaces as arguments.
"      If($_.Exception.Message -eq 'Access is Denied'){

