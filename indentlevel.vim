" INDENT LEVEL

command! Indentexclusivemovetop call IndentLevelMove(1, 1)
command! Indentexclusivemovebot call IndentLevelMove(1, 0)
command! Indentinclusivemovetop call IndentLevelMove(0, 1)
command! Indentinclusivemovebot call IndentLevelMove(0, 0)

command! -count=1 Indentlevelvisual call IndentLevelVisual(<count>)

command! -count=1 Indentoutercornerprev call IndentCorners(1, 1, <count>)
command! -count=1 Indentoutercornernext call IndentCorners(1, 0, <count>)
command! -count=1 Indentinnercornerprev call IndentCorners(0, 1, <count>)
command! -count=1 Indentinnercornernext call IndentCorners(0, 0, <count>)

function! FirstNonBlankChar(line)
	let byteindex = match(getline(a:line), '\v%(\S|\n)')
	call cursor(a:line, l:byteindex + 1)
endfunction

function! NextNonBlankLine(backwards)
	let direction = !a:backwards ? 'next' : 'prev'
	return function(l:direction.'nonblank')
endfunction

function! LastContiguousMatch(backwards, pattern, line = line('.'))
	let Nextline = NextNonBlankLine(a:backwards)
	let offset = !a:backwards ? 1 : -1
	let line = a:line
	let nextline = Nextline(l:line + l:offset)
	if getline(l:nextline) =~ a:pattern
		while l:nextline != 0 && getline(l:nextline) =~ a:pattern
			let l:line = l:nextline
			let l:nextline = Nextline(l:line + l:offset)
		endwhile
		return l:line
	else
		return l:line
	endif
endfunction

function! LessIndentMatch(indent)
	let spaceindent = repeat(' ', a:indent)
	let tabindent = substitute(l:spaceindent, ' \{'.&l:tabstop.'}', '\t', 'g')
	return '^\('.l:spaceindent.'\|'.l:tabindent.'\)'
endfunction

function! IndentMatch(indent)
	let spaceindent = repeat(' ', a:indent)
	let tabindent = substitute(l:spaceindent, ' \{'.&l:tabstop.'}', '\t', 'g')
	return '^\('.l:spaceindent.'\|'.l:tabindent.'\)'
endfunction

function! IndentLevelVisual(n = 1, line = line('.'))
	let line = a:line
	let indent = indent(l:line)
	execute "normal! \<C-\>\<C-N>"
	if a:n > 1
		for i in range(a:n - 1)
			let spacecharslimit = '^\s\{,'.(l:indent - 1).'}'
			let virtualcols = []
			for virtualcol in range(l:indent, 1, -1)
				call add(l:virtualcols, '\%'.l:virtualcol.'v')
			endfor
			let possiblecolumnmatches = '\('.join(l:virtualcols, '\|').'\)\S'
			let lessindented = l:spacecharslimit.l:possiblecolumnmatches
			let upperline = search(l:lessindented, 'bnWz')
			let lowerline = search(l:lessindented, 'nW')
			let lines = [l:upperline, l:lowerline]
			let l:line = reduce(l:lines, {a, b -> indent(a) > indent(b) ? a : b})
			let l:indent = indent(l:line)
			call FirstNonBlankChar(l:line)
		endfor
	endif
	call IndentLevelMove(v:false, v:true, l:line)
	normal! V
	call IndentLevelMove(v:false, v:false, l:line)
endfunction

" f
"  f
" 	f
" 	 \v(\s)@<=(%4v|%5v).*
" 	 f
" 		f
" 		 f
" 		  \v^\s{,5}\zs(%6v|%5v|%4v|%3v|%2v|%1v)\S
" 			\v(^\s*)@<=(%1v).
" 		 f
" 		f
" 	 f
" 	 \v(\s)@<=(%4v|%5v).*
" 	f
"    f
"   f
"  f
" f

" function! LineIndentMatch(line = line('.'))
" 	let indent = indent(a:line)
" 	let ensurespace = '\(^\s*\)\@<='
" 	let virtualcols = []
" 	for i in range(l:indent + 1, l:indent + &l:tabstop)
" 		call add(l:virtualcols, '\%'.l:i.'v')
" 	endfor
" 	let columnmatches = '\('.join(l:virtualcols, '\|').'\)'
" 	return l:ensurespace.l:columnmatches
" endfunction

function! LineIndentMatch(line = line('.'))
  let indent = indent(a:line)
  " TODO:
  " Add a convolution algorithm to match all possibilities.
  let indentstr = matchstr(getline(a:line), '^\s*', '')
  let tabexpandedstr = substitute(l:indentstr, '\t', repeat(' ', &l:tabstop), 'g')
  let retabstr = substitute(l:tabexpandedstr, ' \{'.&l:tabstop.'}', '\t', 'g')
  return '^\('.l:indentstr.'\|'.l:tabexpandedstr.'\|'.l:retabstr.'\)'
endfunction

" TODO:
" Support for the jump list.
function! IndentLevelMove(exclusive, backwards, line = line('.'))
	call FirstNonBlankChar(a:line)
	let scope = !a:exclusive ? '' : '\(\S\|$\)'
	let validline = LineIndentMatch(a:line).l:scope
	let target = LastContiguousMatch(a:backwards, l:validline)
	call FirstNonBlankChar(l:target)
endfunction


function! IndentCorners(outer, backwards, n = 1, line = line('.'))
	let offset = !a:backwards ? 1 : -1
	let Nextline = NextNonBlankLine(a:backwards)
	let line = a:line
	for i in range(a:n)
		let indent = indent(l:line)
		let nline = Nextline(l:line + l:offset)
		let nindent = indent(l:nline)
		if l:nline != 0
			if a:outer ? l:indent > l:nindent : l:indent < l:nindent
				let l:line = l:nline
			else

				"                   exclusive
				call IndentLevelMove(v:true, a:backwards, l:nline)
				let l:indent = indent('.')
				let l:nline = Nextline(line('.') + l:offset)
				let l:nindent = indent(l:nline)
				if l:nindent != -1
					if a:outer ? l:indent > l:nindent : l:indent < l:nindent
						let l:line = l:nline
					else
						let l:line = line('.')
					endif
				endif

			endif
			call FirstNonBlankChar(l:line)
		else
			call FirstNonBlankChar(l:line)
		endif
	endfor
endfunction


" function! IndentLevelVisual(n = 1, line = line('.'))
" 	let line = a:line
" 	let indent = indent(l:line)
" 	execute "normal! \<C-\>\<C-N>"
" 	if a:n > 1
" 		for i in range(a:n - 1)
" 			let lessindented = '\v^\s{,'.(l:indent - 1).'}\S'
" 			let upperline = search(l:lessindented, 'bnWz')
" 			let lowerline = search(l:lessindented, 'nW')
" 			let lines = [l:upperline, l:lowerline]
" 			let l:line = reduce(l:lines, {a, b -> indent(a) > indent(b) ? a : b})
" 			let l:indent = indent(l:line)
" 			call FirstNonBlankChar(l:line)
" 		endfor
" 	endif
" 	call IndentLevelMove(v:false, v:true, l:line)
" 	normal! V
" 	call IndentLevelMove(v:false, v:false, l:line)
" endfunction

