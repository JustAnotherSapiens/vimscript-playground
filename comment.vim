" COMMENT AND UNCOMMENT
" Vim global plugin for linewise and blockwise comments
" Last Change:  2022 Nov 30
" Maintainer: Leonardo Alvaro <arl880895@proton.me>

" if exists("g:loaded_comment")
"   finish
" endif
" let g:loaded_comment = 1
" map <unique> <Leader>c <Plug>Comment
" map <unique> <Leader>v
" map <unique> <Leader>cc
" map <unique> <Leader>vv
" if !hasmapto('<Plug>TypecorrAdd;')
"   map <unique> <Leader>a  <Plug>TypecorrAdd;
" endif

command! -range Comment execute <line1>.",".<line2>."call CommentFunc(v:false)"
command! -range Uncomment execute <line1>.",".<line2>."call CommentFunc(v:true)"

command! Commentmode Togglebool g:firstcolcomment |
      \ echomsg g:firstcolcomment ?
      \ 'COMMENT: First column mode' :
      \ 'COMMENT: Indent column mode'

function! FirstNonBlankChar(line)
  let byteindex = match(getline(a:line), '\v%(\S|\n)')
  call cursor(a:line, l:byteindex + 1)
endfunction

function! CommentFunc(uncomment) range
  let comchars = split(&commentstring, '%s')
  if len(l:comchars) == 1
    let comstr = trim(l:comchars[0], ' ', 2)
    exe a:firstline.",".a:lastline."call LineComment".
          \ "('".l:comstr."', ".a:uncomment.")"
  elseif len(l:comchars) == 2
    let comhead = trim(l:comchars[0], ' ', 2)
    let comfoot = trim(l:comchars[1], ' ', 1)
    exe a:firstline.",".a:lastline."call BlockComment".
          \ "('".l:comhead."', '".l:comfoot."', ".a:uncomment.")"
  endif
endfunction

function! LineIndentMatch(line = line('.'))
  let indent = indent(a:line)
  " TODO: Add a convolution algorithm to match all possibilities.
  let indentstr = matchstr(getline(a:line), '^\s*', '')
  let tabexpandedstr = substitute(l:indentstr, '\t', repeat(' ', &l:tabstop), 'g')
  let retabstr = substitute(l:tabexpandedstr, ' \{'.&l:tabstop.'}', '\t', 'g')
  return '^\('.l:indentstr.'\|'.l:tabexpandedstr.'\|'.l:retabstr.'\)'
endfunction

function! MinimumIndentMatch(start, end)
  let indents = {}
  for n in range(a:start, a:end)
    if getline(l:n) =~ '^\s*$'
      continue
    else
      let indents[l:n] = indent(l:n)
    endif
  endfor
  let minindent = min(values(l:indents))
  let minindentlines = filter(copy(l:indents), 'v:val == l:minindent')
  let lastminindentline = min(keys(l:minindentlines))
  return LineIndentMatch(l:lastminindentline)
endfunction

function! LineComment(comstr, uncomment) range
  if !a:uncomment
    let match = MinimumIndentMatch(a:firstline, a:lastline)
    let replace = '\1'.escape(a:comstr, '\').' '
  else
    let match = '^\(\s*\)'.escape(a:comstr, '.*$^~[]\').' \?'
    let replace = '\1'
  endif
  for n in range(a:firstline, a:lastline)
    let newline = substitute(getline(l:n), l:match, l:replace, '')
    call setline(l:n, l:newline)
    call FirstNonBlankChar('.')
  endfor
endfunction


" TODO: Deal with <Tab> characters.
" Indent can be 2, but there will be just one character.

" TODO: Review and refactor BlockComment
" 1. Determine a clear functionality
"    - Embedded comment vs. Indented block comment
" 2. Check if you can make the searchpair() function work
"    - Maybe removing 'c' from the 'cpoptions'?

let g:firstcolcomment = v:true

function! BlockComment(comhead, comfoot, uncomment) range
  let leadspace = !g:firstcolcomment ? repeat(' ', indent('.')) : ''
  if !a:uncomment
    call append(a:lastline, l:leadspace . a:comfoot)
    call append(a:firstline - 1, l:leadspace . a:comhead)
  else
    let specialchars = '\([.*$^~\[\]\\]\)'
    let regexhead = substitute(a:comhead, l:specialchars, '\\\1', 'g')
    let regexfoot = substitute(a:comfoot, l:specialchars, '\\\1', 'g')
    call cursor('.', 1)
    let headline = search(l:leadspace . l:regexhead, 'bcnW')
    let footline = search(l:leadspace . l:regexfoot, 'cnW')
    let invalhead = search(l:leadspace . l:regexfoot, 'bnW')
    let invalfoot = search(l:leadspace . l:regexhead, 'nW')
    if l:headline && l:footline
      if l:invalhead && (l:invalhead > l:headline) ||
        \ l:invalfoot && (l:invalfoot < l:footline)
        echomsg "Not within a comment block"
      else
        execute l:footline . "delete _"
        execute l:headline . "delete _"
      endif
    else
      echomsg "Not within a comment block"
    endif
  endif
  " TODO: Prevent nesting with searchcount()
endfunction

" IMPORTANT:
" This script relies on the 'commentstring' ('cms') option to:
"   Extract the comment characters
"   Determine linewise or blockwise action

" Users can define their own comment chars just by setting the
" 'commentstring' option using '%s' as a placeholder. Note that
" '%', '\', '"' and ' ' must be escaped with a '\', e.g.:
"   Linewise:
"     set cms=\%\ ->%s
"     set cms=#__%s
"   Blockwise:
"     set cms=$>-%s-<$
"     set cms=\\[$*^~.%s.~^*$]\\


