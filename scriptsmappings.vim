
" execute "source ".$SCRIPTS."\\operatormap.vim"

function! MapOperator(keys, func, args)
  let argstr = trim(string(a:args), '[]')
  let funcstr = a:func."(".l:argstr.")"
  let lastkey = matchstr(a:keys, '\%(<\w\+>\|.\)$')
  execute "xnoremap <expr> ".a:keys." ".l:funcstr
  execute "nnoremap <expr> ".a:keys." ".l:funcstr
  execute "nnoremap <expr> ".a:keys.l:lastkey." ".l:funcstr.".'_'"
endfunction

execute "source ".$SCRIPTS."\\operatorcomment.vim"
call MapOperator('<Leader>c', 'SetComment', [v:false])
call MapOperator('<Leader>v', 'SetComment', [v:true])

execute "source ".$SCRIPTS."\\operatorvarious.vim"
call MapOperator('<Leader>r', 'SetReverse', [v:false])
call MapOperator('<Leader>lr', 'SetReverse', [v:true])

execute "source ".$SCRIPTS."\\operatorsurround.vim"
function! MapSurround()
  let surroundpairs = {
    \ '(': ['(', ')'],
    \ '[': ['[', ']'],
    \ '{': ['{', '}'],
    \ '<': ['<', '>'],
    \ '`': ['`', '`'],
    \ '"': ['"', '"'],
    \ 'w': ['[[', ']]'],
    \ '''': ['''', ''''],
    \ '<Space>': [' ', ' '],
    \ }
  for [key, chars] in items(l:surroundpairs)
    let [lchar, rchar] = l:chars
    call MapOperator('g'.l:key, 'SetSurround', [l:lchar, l:rchar, v:false])
    call MapOperator('gl'.l:key, 'SetSurround', [l:lchar, l:rchar, v:true])
  endfor
endfunction
let g:surroundindent = v:false
call MapSurround()


function! MapCmd(modes, lhs, cmd, args = [], special = '')
  let specialargs = !empty(a:special) ? a:special.' ' : ''
  let chars = split(a:modes, '\zs')
  for i in range(len(l:chars))
    let map = l:chars[i] != '!' ? l:chars[i].'noremap' : 'noremap'.l:chars[i]
    let cmdargs = !empty(a:args) ? a:cmd.' '.a:args[i] : a:cmd
    let rhs = "<Cmd>".l:cmdargs."<CR>"
    exe l:map." ".l:specialargs.a:lhs." ".l:rhs
  endfor
endfunction

function! MapCountCmd(modes, lhs, cmd, args = [], special = '')
  let specialargs = !empty(a:special) ? a:special.' ' : ''
  let chars = split(a:modes, '\zs')
  for i in range(len(l:chars))
    let map = l:chars[i] != '!' ? l:chars[i].'noremap' : 'noremap'.l:chars[i]
    let cmdargs = !empty(a:args) ? a:cmd.' '.a:args[i] : a:cmd
    let countcmd = 'execute v:count1."'.l:cmdargs.'"'
    let rhs = "<Cmd>".l:countcmd."<CR>"
    exe l:map." ".l:specialargs.a:lhs." ".l:rhs
  endfor
endfunction

execute "source ".$SCRIPTS."\\indentlevel.vim"
call MapCountCmd('ox', 'ii', 'Indentlevelvisual')
call MapCountCmd('nx', '<M-a>', 'Indentoutercornerprev')
call MapCountCmd('nx', '<M-s>', 'Indentinnercornerprev')
call MapCountCmd('nx', '<M-d>', 'Indentinnercornernext')
call MapCountCmd('nx', '<M-f>', 'Indentoutercornernext')
call MapCmd('nx', '<M-A>', 'Indentinclusivemovetop')
call MapCmd('nx', '<M-S>', 'Indentexclusivemovetop')
call MapCmd('nx', '<M-D>', 'Indentexclusivemovebot')
call MapCmd('nx', '<M-F>', 'Indentinclusivemovebot')

execute "source ".$SCRIPTS."\\blanklines.vim"
call MapCountCmd('nx', '<Space>o', 'Blanklinesadd', ['v:false', 'v:true'])
call MapCountCmd('nx', '<Space>O', 'Blanklinesremove', ['v:false', 'v:true'])
call MapCountCmd('nx', '<Space>j', 'Blanklineaddbelow', ['v:false', 'v:true'])
call MapCountCmd('nx', '<Space>k', 'Blanklineaddabove', ['v:false', 'v:true'])
call MapCountCmd('nx', '<S-Space>J', 'Blanklineremovebelow', ['v:false', 'v:true'])
call MapCountCmd('nx', '<S-Space>K', 'Blanklineremoveabove', ['v:false', 'v:true'])

execute "source ".$SCRIPTS."\\verticalvisualmove.vim"
nnoremap <M-e> <Cmd>SwapCharDown<CR>
nnoremap <M-w> <Cmd>SwapCharUp<CR>
xnoremap <M-e> <Cmd>VisualSwapDown<CR>
xnoremap <M-w> <Cmd>VisualSwapUp<CR>

execute "source ".$SCRIPTS."\\keymaps.vim"
nnoremap <C-Up> <Cmd>Keymapnext<CR>
nnoremap <C-Down> <Cmd>Keymapprev<CR>

execute "source ".$SCRIPTS."\\winfraction.vim"
let g:windowfraction = 5
noremap z<CR> <Cmd>call CursorAtWinFrac(1, g:windowfraction)<CR>

execute "source ".$SCRIPTS."\\blockalign.vim"

let g:systemclipboard = v:false
function! ToggleClipboard()
  let g:systemclipboard = !g:systemclipboard
  let &clipboard = !g:systemclipboard ? '' : 'unnamed'
  if !empty(&clipboard)
    echomsg "System clipboard (".string(&clipboard).")"
  else
    echomsg "Vim clipboard (".string(&clipboard).")"
  endif
endfunction
noremap <M-C> <Cmd>call ToggleClipboard()<CR>

