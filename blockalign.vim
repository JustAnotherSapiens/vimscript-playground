" BLOCK ALIGN

command! -range Left call BlockAlign('left')
command! -range Right call BlockAlign('right')
command! -range Center call BlockAlign('center')


function! BlockAlign(align)
  let savedregister = getreginfo('a')
  execute "normal! \<C-\>\<C-N>gv\"ay"
  let lines = getreg('a', 1, v:true)
  let width = max(map(deepcopy(l:lines), {_, val -> len(val)}))
  let texts = map(deepcopy(l:lines), {_, val -> trim(val)})
  let nspaces = map(deepcopy(l:texts), {_, val -> l:width - len(val)})
  for i in range(len(l:lines))
    if a:align == 'left'
      let space = repeat(' ', l:nspaces[i])
      let l:lines[i] = l:texts[i].l:space
    elseif a:align == 'right'
      let space = repeat(' ', l:nspaces[i])
      let l:lines[i] = l:space.l:texts[i]
    elseif a:align == 'center'
      let lspace = repeat(' ', float2nr(floor(l:nspaces[i] / 2.0)))
      let rspace = repeat(' ', float2nr(ceil(l:nspaces[i] / 2.0)))
      let l:lines[i] = l:lspace.l:texts[i].l:rspace
    endif
  endfor
  call setreg('a', l:lines, 'b')
  normal! gv"ap
  call setreg('a', l:savedregister)
endfunction

" IMPORTANT: mapnew() not available in Neovim
" function! BlockAlign(align)
"   let savedregister = getreginfo('a')
"   execute "normal! \<C-\>\<C-N>gv\"ay"
"   let lines = getreg('a', 1, v:true)
"   let width = max(mapnew(l:lines, {_, val -> len(val)}))
"   let texts = mapnew(l:lines, {_, val -> trim(val)})
"   let nspaces = mapnew(l:texts, {_, val -> l:width - len(val)})
"   for i in range(len(l:lines))
"     if a:align == 'left'
"       let space = repeat(' ', l:nspaces[i])
"       let l:lines[i] = l:texts[i].l:space
"     elseif a:align == 'right'
"       let space = repeat(' ', l:nspaces[i])
"       let l:lines[i] = l:space.l:texts[i]
"     elseif a:align == 'center'
"       let lspace = repeat(' ', float2nr(floor(l:nspaces[i] / 2.0)))
"       let rspace = repeat(' ', float2nr(ceil(l:nspaces[i] / 2.0)))
"       let l:lines[i] = l:lspace.l:texts[i].l:rspace
"     endif
"   endfor
"   call setreg('a', l:lines, 'b')
"   normal! gv"ap
"   call setreg('a', l:savedregister)
" endfunction

" UNNECESSARILY_OPTIMIZED_VERSION:
" function! BlockAlign(align)
"   let savedreg = @a
"   let savedregtype = getregtype('a')
"   execute "normal! \<C-\>\<C-N>gv\"ay"
"   let lines = getreg('a', 1, v:true)
"   let width = max(mapnew(l:lines, {_, val -> len(val)}))
"   let texts = mapnew(l:lines, {_, val -> trim(val)})
"   let nspaces = mapnew(l:texts, {_, val -> l:width - len(val)})
"   if a:align == 'left'
"     let spaces = mapnew(l:nspaces, {_, val -> repeat(' ', val)})
"     for i in range(len(l:lines))
"       let l:lines[i] = l:texts[i].l:spaces[i]
"     endfor
"   elseif a:align == 'right'
"     let spaces = mapnew(l:nspaces, {_, val -> repeat(' ', val)})
"     for i in range(len(l:lines))
"       let l:lines[i] = l:spaces[i].l:texts[i]
"     endfor
"   elseif a:align == 'center'
"     let lspaces = mapnew(l:nspaces, {_, val -> repeat(' ', float2nr(floor(val / 2.0)))})
"     let rspaces = mapnew(l:nspaces, {_, val -> repeat(' ', float2nr(ceil(val / 2.0)))})
"     for i in range(len(l:lines))
"       let l:lines[i] = l:lspaces[i].l:texts[i].l:rspaces[i]
"     endfor
"   endif
"   call setreg('a', l:lines, 'b')
"   normal! gv"ap
"   call setreg('a', l:savedreg, l:savedregtype)
" endfunction


"     adsasdf asdeis             bar and blob          
"      asdasd   ows     bar & more stuff here and there
"       sdfsd    i                    bar              

" NOTE:
" '' registers insert additional space when the block is pasted in the
" middle of other text. Just enough space to fill the register's width.

