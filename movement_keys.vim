
let g:keybindings = {}

let g:moves =<< trim END
{
  "soW": {
    "search": "\\%(\\s\\\\|^\\)\\zs\\S"
  },
  "sow": {
    "search": "\\%(\\W\\\\|^\\)\\zs\\w"
  },
  "eoW": {
    "search": "\\S\\ze\\_s",
    "isearch": "\\S\\zs\\_s"
  },
  "eow": {
    "search": "\\w\\ze\\_W",
    "isearch": "\\w\\zs\\_W"
  }
}
END
let g:moves = json_decode(g:moves->join())

let g:moves = {}
let g:moves.soW = #{search: '\%(\s\\|^\)\zs\S'}
let g:moves.sow = #{search: '\%(\W\\|^\)\zs\w'}
let g:moves.eoW = #{search: '\S\ze\_s', isearch: '\S\zs\_s'}
let g:moves.eow = #{search: '\w\ze\_W', isearch: '\w\zs\_W'}


function! MapWordMotions(chars="wdef", mold="<M- >")
  if len(a:chars) != 4
    echoerr "Exactly 4 characters are required to map word motions"
    return 1
  endif
  if exists('*UnmapWordMotions')
    call UnmapWordMotions()
    delfunction UnmapWordMotions
  endif
  let fullchars = a:chars . toupper(a:chars)
  let charlist = split(l:fullchars, '\zs')
  let g:keybindings.wordmotions = []
  for char in l:charlist
    let keybinding = substitute(a:mold, ' ', l:char, '')
    call add(g:keybindings['wordmotions'], l:keybinding)
  endfor
  let lhs = #{soW: {}, eoW: {}, sow: {}, eow: {}}
  let lhs.soW.backward = g:keybindings['wordmotions'][0]
  let lhs.eoW.backward = g:keybindings['wordmotions'][1]
  let lhs.soW.forward  = g:keybindings['wordmotions'][2]
  let lhs.eoW.forward  = g:keybindings['wordmotions'][3]
  let lhs.sow.backward = g:keybindings['wordmotions'][4]
  let lhs.eow.backward = g:keybindings['wordmotions'][5]
  let lhs.sow.forward  = g:keybindings['wordmotions'][6]
  let lhs.eow.forward  = g:keybindings['wordmotions'][7]
  for [key, val] in items(l:lhs)
    for [skey, sval] in items(val)
      let flags  = l:skey != 'backward' ? 'W' : 'Wb'
      let search = g:moves[l:key]['search']
      exe "noremap ".sval." <Cmd>call search('".l:search."', '".l:flags."')<CR>"
      if has_key(g:moves[l:key], 'isearch')
        let l:search = g:moves[l:key]['isearch']
        exe "inoremap ".sval." <Cmd>call search('".l:search."', '".l:flags."')<CR>"
      else
        exe "inoremap ".sval." <Cmd>call search('".l:search."', '".l:flags."')<CR>"
      endif
    endfor
  endfor
  function UnmapWordMotions()
    if !empty(g:keybindings['wordmotions'])
      for i in range(len(g:keybindings['wordmotions']) - 1, 0, -1)
        let keybinding = remove(g:keybindings['wordmotions'], i)
        execute "unmap ".l:keybinding
        execute "iunmap ".l:keybinding
      endfor
    endif
  endfunction
  echomsg g:keybindings
endfunction

call MapWordMotions("wdef", "<M- >")










function! MapWordMotions(chars="wdef", mold="<M- >")

  if len(a:chars) != 4
    echoerr "Exactly 4 characters are required to map word motions"
    return 1
  endif
  if exists('*UnmapWordMotions')
    call UnmapWordMotions()
    delfunction UnmapWordMotions
  endif

endfunction
UnmapKeybindings(keybindings, modechars)
execute "unmap ".l:keybinding

function UnmapKeybindings(keybindings, modechars)
  if !empty(a:keybindings)
    for char in a:modechars
      let unmapcmd = l:char != '!' ? l:char.'unmap' : 'unmap!'
      for keybinding in a:keybindings
        execute l:unmapcmd." ".l:keybinding
      endfor
      for i in range(len(a:keybindings) - 1, 0, -1)
        execute "unmap ".l:keybinding
        execute "iunmap ".l:keybinding
      endfor
    endfor
    for idx in range(len(a:keybindings) - 1, 0, -1)
      call remove(a:keybindings, l:idx)
    endfor
  endif
endfunction


function! MapWordMotions(chars, mold)

  function! GenerateFullChars(charstr)
    return split(a:charstr..toupper(a:charstr), '\zs')
  endfunction

  function! GenerateKeybindings(rawchars, mold)
    let chars = GenerateFullChars(a:rawchars)
    return mapnew(l:chars, {_, val -> substitute(a:mold, ' ', val, '')})
  endfunction

  function! GenerateLhsDict(keybindings)
    let lhs = #{soW: {}, eoW: {}, sow: {}, eow: {}}
    let lhs.soW.backward = a:keybindings[0]
    let lhs.eoW.backward = a:keybindings[1]
    let lhs.soW.forward  = a:keybindings[2]
    let lhs.eoW.forward  = a:keybindings[3]
    let lhs.sow.backward = a:keybindings[4]
    let lhs.eow.backward = a:keybindings[5]
    let lhs.sow.forward  = a:keybindings[6]
    let lhs.eow.forward  = a:keybindings[7]
    return l:lhs
  endfunction

  function! GenerateMappings(lhs)
    for [key, val] in items(a:lhs)
      for [skey, sval] in items(val)
        let flags  = l:skey != 'backward' ? 'W' : 'Wb'
        let search = g:moves[l:key]['search']
        exe "noremap ".sval." <Cmd>call search('".l:search."', '".l:flags."')<CR>"
        if has_key(g:moves[l:key], 'isearch')
          let l:search = g:moves[l:key]['isearch']
          exe "inoremap ".sval." <Cmd>call search('".l:search."', '".l:flags."')<CR>"
        else
          exe "inoremap ".sval." <Cmd>call search('".l:search."', '".l:flags."')<CR>"
        endif
      endfor
    endfor
  endfunction

  let g:keybindings.wordmotions = GenerateKeybindings(a:chars, a:mold)
  call GenerateMappings(GenerateLhsDict(g:keybindings['wordmotions']))

endfunction



function! SomeRequieredOpeningCode()
  echomsg "Important code to be executed before SomeOtherFunc"
endfunction

function! SomeOtherFunc()
  echomsg "Code from SomeOtherFunc"
endfunction

function! OuterFuncTest(openingfunc, userfunc)
  echomsg "Starting code in OuterFuncTest"
  let UserFunc = funcref(a:userfunc)
  let OpeningFunc = funcref(a:openingfunc)

  function! InnerFuncTest() closure
    echomsg "Starting code in InnerFuncTest"
    call l:OpeningFunc()
    call l:UserFunc()
    echomsg "Ending code in InnerFuncTest"
  endfunction

  echomsg "Ending code in OuterFuncTest"
  return funcref('InnerFuncTest')
endfunction

let DecoratedFunc = OuterFuncTest('SomeRequieredOpeningCode', 'SomeOtherFunc')
echomsg "DecoratedFunc starts here"
call DecoratedFunc()
echomsg "DecoratedFunc ends here"

