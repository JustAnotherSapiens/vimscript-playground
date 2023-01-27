
function! SetComment(uncomment)
  try
    let s:uncomment = a:uncomment
    let s:comchars = split(&commentstring, '%s')
    if len(s:comchars) == 1
      let s:CommentFunction = function(expand('<SID>').'LineComment')
    elseif len(s:comchars) == 2
      let s:CommentFunction = function(expand('<SID>').'BlockComment')
    endif
  catch /.*/
    echomsg v:exception
  finally
    set operatorfunc=CommentOperator
    return 'g@'
  endtry
endfunction

function! CommentOperator(type)
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
    let output = s:CommentFunction(l:regtext, l:regtype)
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

function! s:MinimumIndentStr(lines)
  let indents = {}
  for idx in range(len(a:lines))
    if a:lines[l:idx] =~ '^\s*$'
      continue
    else
      let indents[l:idx] = indent(a:lines[l:idx])
    endif
  endfor
  let minindent = min(values(l:indents))
  let minindentlines = filter(copy(l:indents), 'v:val == l:minindent')
  let firstminindentidx = min(keys(l:minindentlines))
  return matchstr(a:lines[l:firstminindentidx], '^\s*')
endfunction

function! s:LineComment(regtext, regtype)
  let rawcomstr = trim(s:comchars[0], ' ', 2) " Trim at the end
  if !s:uncomment
    let comstr = escape(l:rawcomstr, '\') " replace
    if a:regtype == 'v'
      return substitute(a:regtext, '^', l:comstr.' ', '')
    elseif a:regtype[0] == ''
      let lines = split(a:regtext, "\n")
      let newlines = []
      for line in l:lines
        let newline = substitute(l:line, '^', l:comstr.' ', '')
        call add(l:newlines, l:newline)
      endfor
      return join(l:newlines, "\n")
    elseif a:regtype == 'V'
      let lines = split(a:regtext, "\n")
      let indentstr = s:MinimumIndentStr(l:lines)
      let newlines = []
      for line in l:lines
        let newline = substitute(l:line, '^\('.l:indentstr.'\)', '\1'.l:comstr.' ', '')
        call add(l:newlines, l:newline)
      endfor
      return join(l:newlines, "\n")
    endif
  else
    let comstr = escape(l:rawcomstr, '.*$^~[]\') " match
    if a:regtype == 'v'
      return substitute(a:regtext, l:comstr.' \=', '', '')
    elseif a:regtype == 'V' || a:regtype[0] == ''
      let lines = split(a:regtext, "\n")
      let newlines = []
      for line in l:lines
        let newline = substitute(l:line, l:comstr.' \=', '', '')
        call add(l:newlines, l:newline)
      endfor
      return join(l:newlines, "\n")
    endif
  endif
endfunction

function! s:BlockComment(regtext, regtype)
  let rawcomhead = trim(s:comchars[0], ' ', 2) " Trim at the end
  let rawcomfoot = trim(s:comchars[1], ' ', 1) " Trim at the beginning
  if !s:uncomment
    let comhead = escape(l:rawcomhead, '\') " replace
    let comfoot = escape(l:rawcomfoot, '\') " replace
    if a:regtype == 'v'
      return substitute(a:regtext, '\(\_.\+\)', l:comhead.'\1'.l:comfoot, '')
    elseif a:regtype == 'V'
      let lines = split(a:regtext, "\n")
      let indentstr = s:MinimumIndentStr(l:lines)
      call insert(l:lines, l:indentstr.l:comhead)
      call add(l:lines, l:indentstr.l:comfoot)
      return join(l:lines, "\n")
    elseif a:regtype[0] == ''
      echomsg "Blockwise block comment not supported"
    endif
  else
    let comhead = escape(l:rawcomhead, '.*$^~[]\') " match
    let comfoot = escape(l:rawcomfoot, '.*$^~[]\') " match
    if a:regtype == 'v'
      if !empty(matchstr(a:regtext, l:comhead)) && !empty(matchstr(a:regtext, l:comfoot))
        return substitute(a:regtext, '\('.l:comhead.'\|'.l:comfoot.'\)', '', 'g')
      endif
    elseif a:regtype == 'V'
      let lines = split(a:regtext, "\n")
      let comheadstack = []
      let enclosingpairs = []

      for idx in range(len(l:lines))
        if !empty(matchstr(l:lines[l:idx], l:comhead))
          call add(l:comheadstack, l:idx)
          continue
        elseif !empty(matchstr(l:lines[l:idx], l:comfoot))
          if !empty(l:comheadstack)
            let enclosingpair = [remove(l:comheadstack, -1), l:idx]
            call add(l:enclosingpairs, l:enclosingpair)
          else
            continue
          endif
        endif
      endfor
      if empty(l:enclosingpairs)
        let headline = searchpair(l:comhead, '', l:comfoot, 'bcnW')
        let footline = searchpair(l:comhead, '', l:comfoot, 'cnW')
        if matchstr(getline(l:footline), '^\s*'.l:comfoot.'$') &&
          \ matchstr(getline(l:headline), '^\s*'.l:comhead.'$')
          execute l:footline."delete _"
          execute l:headline."delete _"
        endif
      else
        for [headidx, footidx] in l:enclosingpairs
          let l:lines[l:headidx] = substitute(l:lines[l:headidx], l:comhead, '', '')
          let l:lines[l:footidx] = substitute(l:lines[l:footidx], l:comfoot, '', '')
        endfor
        return join(l:lines, "\n")
      endif
    elseif a:regtype[0] == ''
      echomsg "Blockwise block uncomment not supported"
    endif
  endif
endfunction

" function! s:BlockComment(comhead, comfoot, uncomment) range
"   let leadspace = !g:firstcolcomment ? repeat(' ', indent('.')) : ''
"   if !a:uncomment
"     call append(a:lastline, l:leadspace . a:comfoot)
"     call append(a:firstline - 1, l:leadspace . a:comhead)
"   else
"     let regexhead = escape(a:comhead, '.*$^~[]\') " match
"     let regexfoot = escape(a:comfoot, '.*$^~[]\') " match
"     call cursor('.', 1)
"     let headline = search(l:leadspace . l:regexhead, 'bcnW')
"     let footline = search(l:leadspace . l:regexfoot, 'cnW')
"     let invalhead = search(l:leadspace . l:regexfoot, 'bnW')
"     let invalfoot = search(l:leadspace . l:regexhead, 'nW')
"     if l:headline && l:footline
"       if l:invalhead && (l:invalhead > l:headline) ||
"         \ l:invalfoot && (l:invalfoot < l:footline)
"         echomsg "Not within a comment block"
"       else
"         execute l:footline . "delete _"
"         execute l:headline . "delete _"
"       endif
"     else
"       echomsg "Not within a comment block"
"     endif
"   endif
"   " TODO: Prevent nesting with searchcount()
" endfunction

