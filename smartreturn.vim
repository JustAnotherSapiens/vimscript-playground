" SMART RETURN
" {range}norm[al][!] {commands}

function! SmartReturn()
  let savedreg = getreginfo('a')
  let nextchar = matchstr(getline('.'), '\%' . (col('.') + 1) . 'c.')
  execute "normal! \<C-\>\<C-N>"
  if !empty(nextchar)
    if getline('.') =~ '^[^{]*{[^}]*}$' && l:nextchar == '}'
      normal! l"axo}
      execute "normal! Ox\b"
      startinsert!
    else
      execute "normal! gi\r\e"
      startinsert
    endif
  else
    normal! o
    startinsert
  endif
  call setreg('a', l:savedreg)
endfunction

