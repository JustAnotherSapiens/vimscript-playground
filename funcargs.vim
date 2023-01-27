" ARGUMENT OBJECTS

function! AverageTime(func, n=5)
  let times = []
  let TargetFunc = a:func
  for i in range(a:n)
    let start_time = reltime()
    call l:TargetFunc()
    let total_time = reltimefloat(reltime(start_time))
    call add(l:times, l:total_time)
  endfor
  let average = reduce(l:times, {a, b -> a + b}) / len(l:times)
  echomsg a:func
  echomsg l:times
  echomsg "Average:" l:average
endfunction

function! MoveArgument(backward)
  let savedregister = @a
  let cursorchar = matchstr(getline('.'), '\%' . col('.') . 'c.')
  if l:cursorchar =~ '[()\[\]{}]'
    normal! "ay2ib
  else
    normal! "ayib
  endif
  let args = split(@a, ', ')
  let @a = l:savedregister
endfunction


" It is possible for later argument defaults to refer to prior arguments,
"   :function Okay(mandatory, optional = a:mandatory)
"   :endfunction
"
" Use <C-V> to prevent abbreviation expansion

  ((),()) ()func (func(), func(func(func(), func(), (), ((), ())), (), ()), ()) ( (), () )

" Insightful regular expressions:
" 1. Match everything possibly inside parentheses that contains empty
"    parentheses within
" \v([^()]*\([^()]*\)[^()]*)+
" 2. Matches everything within parentheses containing multiple possible
"    separated parentheses within
" \v\(\zs(([^()]*\([^()]*\)[^()]*)*)\ze\)


function! StringRegex(strchar, escapedchar)
  let withinstr = ['[^'.a:strchar.']']
  if !empty(a:escapedchar)
    call extend(l:withinstr, [a:escapedchar], 0)
  endif
  let regex = a:strchar.'\%('.join(l:withinstr, '\|').'\)*'.a:strchar
  call setreg('/', l:regex)
  return l:regex
endfunction

function! StringRegex(stringspecs)
  let strmatches = []
  for [char, rawescaped] in items(a:stringspecs)
    let notchar = '[^'.l:char.']'
    let escaped = escape(l:rawescaped, '\^$*~.[]')
    let withinstr = !empty(l:escaped) ? [l:escaped, l:notchar] : [l:notchar]
    call add(l:strmatches, l:char.'\%('.join(l:withinstr, '\|').'\)*'.l:char)
  endfor
  let regex = '\%('.join(l:strmatches, '\|').'\)'
  call setreg('/', l:regex)
  return l:regex
endfunction
call StringRegex({'"': '\"', "'": "''"})

function! RobustArgumentMatch(n, strspecs={'"': '\"', "'": "''"})
  let pairs = '(:),[:],{:},<:>'
  let pairslist = split(l:pairs, ',')
  let pairschars = substitute(l:pairs, '\%(:\|,\)', '', 'g')
  let collectionchars = '^-[]\'
  let escpairs = escape(l:pairschars, l:collectionchars)

  let stringtoken = StringRegex(a:strspecs)
  let numbertoken = '\d\+\%(\.\d*\)\='
  let keywordtoken = '\w'
  let notchars = '[^'.l:escpairs.']*'
  let nestlist = []
  call add(l:nestlist, l:strmatch)
  call add(l:nestlist, l:numbermatch)

  let regexchars = '[]$^*~.\'
  for pair in l:pairslist
    let [rawlchar, rawrchar] = split(l:pair, ':')
    let lchar = escape(l:rawlchar, l:regexchars)
    let rchar = escape(l:rawrchar, l:regexchars)
    let withinpair = '\%('.join([l:strmatch, l:notchars], '\|').'\)'
    let pairmatch = l:lchar.l:withinpair.l:rchar
    call add(l:nestlist, l:pairmatch)
  endfor
  let nest = '\%('.join(l:nestlist, '\|').'\)'
  echomsg len(l:nest)
  call setreg('/', l:nest)
endfunction

function! ArgMove()
  " let insideparens = '(\zs[^(]*\%#[^)]*\ze)'
  let insideparens = '[^(]*\%#[^)]*'
  call setreg('/', l:insideparens)
  let text = matchstr(l:insideparens)
endfunction
noremap <expr> <M-q> ArgMove()



(1,2,3)
(1, 2, 3)
(1.0,2.55,-2.23e42,1.2342e-23)
(1.0, -2.55, -2.23e42, 1.2342e-23)
(foo,bar,blob)
(foo, bar, blob)
('a,b', "a,", '. ''z'' .', ". \"z\" .", '"bar"', "'blob'")
(1+2, (1+2)/3, ((1-2)*(3-4))/(4-2))
[1,2,3]
[1, 2, 3]
[1.0,2.55,-2.23e42,1.2342e-23]
[1.0, -2.55, -2.23e42, 1.2342e-23]
[foo,bar,blob]
[foo, bar, blob]
['a,b', "a,", '. ''z'' .', ". \"z\" .", '"bar"', "'blob'"]
[1+2, [1+2]/3, [[1-2]*[3-4]]/[4-2]]

function! RobustArgumentMatch(n, strspecs={'"': '\"', "'": "''"})
  let pairs = '(:),[:],{:},<:>'
  let pairslist = split(l:pairs, ',')
  let pairschars = substitute(l:pairs, '\%(:\|,\)', '', 'g')
  let collectionchars = '^-[]\'
  let escpairs = escape(l:pairschars, l:collectionchars)
  let strmatch = StringRegex(a:strspecs)
  let notchars = '[^'.l:escpairs.']*'
  let numbermatch = '\d\+\.\=\%(\d*\)'
  let nestlist = []
  call add(l:nestlist, l:strmatch)
  call add(l:nestlist, l:numbermatch)
  let regexchars = '[]$^*~.\'
  for pair in l:pairslist
    let [rawlchar, rawrchar] = split(l:pair, ':')
    let lchar = escape(l:rawlchar, l:regexchars)
    let rchar = escape(l:rawrchar, l:regexchars)
    let withinpair = '\%('.join([l:strmatch, l:notchars], '\|').'\)'
    let pairmatch = l:lchar.l:withinpair.l:rchar
    call add(l:nestlist, l:pairmatch)
  endfor
  let nest = '\%('.join(l:nestlist, '\|').'\)'
  echomsg len(l:nest)
  call setreg('/', l:nest)
endfunction

{'a', 5, 'blob', 'c'}
(1, 'bar', [1, 'bar', {'a': 'blob'}, 2], {'a': [1, 2 'foo']})
[1, 2, 'a', (1, 2, 'a'), 'c']

\%(\%("\%(\\"\|[^"]\)*"\|'\%(''\|[^']\)*'\)\|\d\+\.\=\%(\d*\)\|(\%(\%("\%(\\"\|[^"]\)*"\|'\%(''\|[^']\)*'\)\|[^()\[\]{}<>]*\))\|\[\%(\%("\%(\\"\|[^"]\)*"\|'\%(''\|[^']\)*'\)\|[^()\[\]{}<>]*\)\]\|{\%(\%("\%(\\"\|[^"]\)*"\|'\%(''\|[^']\)*'\)\|[^()\[\]{}<>]*\)}\|<\%(\%("\%(\\"\|[^"]\)*"\|'\%(''\|[^']\)*'\)\|[^()\[\]{}<>]*\)>\)
let foo = map('(', ')')
" \%(([^()\[\]{}<>]*)\|\[[^()\[\]{}<>]*\]\|{[^()\[\]{}<>]*}\|<[^()\[\]{}<>]*>\)

function! MatchScope(lchars, rchars, n)
  let lowernest = '[^()]*'
  for i in range(a:n + 1)
    let nest = '('.l:lowernest.')'
    let multinest = '\%('.l:lowernest.l:nest.l:lowernest.'\|'.l:lowernest.'\)*'
    let lowernest = l:multinest
  endfor
  let regexlength = len(l:nest)
  call setreg('/', l:nest)
  return l:regexlength
endfunction
call AverageTime(function('RobustArgumentMatch', [3]))

" PERFORMANCE_TABLE:
" Performance when setting the search register '/' to the output regex
" n -> nesting level
|  n  | regex length | delay |
|:---:| ------------:|:-----:|
|  0  |            8 |       |
|  1  |           36 |       |
|  2  |          148 |       |
|  3  |          596 |       |
|  4  |        2,388 |       |
|  5  |        9,556 |       |
|  6  |       38,228 |       |
|  7  |      152,916 |  150  |
|  8  |      611,668 |  350  |
|  9  |    2,446,676 |  800  |
| 10  |    9,786,708 | 2000  |
| 11  |   39,146,836 |       |
| 12  |  156,587,348 |       |
" NOTE: Approximated delay between 'n' or 'N' commands

function! SearchSelection()
  let regexchars = '[]^$.*~\'
endfunction


" TODO: Research some matching pairs algorithms

" let [bufnum, lnum, col, off] = getpos('.')
" call setpos()
" let [bufnum, lnum, col, off] = getcharpos('.')
" call setcharpos()
" let [_, lnum, col, off, curswant] = getcurpos()
" call cursor()

let g:sound_names = [SystemAsterisk, SystemDefault,
		SystemExclamation, SystemExit, SystemHand, SystemQuestion,
		SystemStart, SystemWelcome,]

call sound_playevent('SystemAsterisk')
call sound_clear()

