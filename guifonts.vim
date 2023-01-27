" GUI FONTS
" FROM globals.vim IMPORT SetIndex

command! Fontnext call SetGUIFont(TIdx('+'), SIdx())
command! Fontprev call SetGUIFont(TIdx('-'), SIdx())
command! Fontsizeinc call SetGUIFont(TIdx(), SIdx('+'))
command! Fontsizedec call SetGUIFont(TIdx(), SIdx('-'))

let g:types = ["Consolas", "Courier_New", "Cascadia_Code"]
let g:sizes = [8, 9, 10, 11, 12, 13, 14, 16, 18, 20, 22, 24]

let TIdx = SetIndex(len(g:types), 2)
let SIdx = SetIndex(len(g:sizes), 2)

function! SetGUIFont(type_idx, size_idx, silent = v:false)
  let type = g:types[a:type_idx]
  let size = g:sizes[a:size_idx]
  let &guifont = $"{l:type}:h{l:size}:cANSI:qDRAFT"
  redraw!
  if !a:silent
    echomsg l:type.' '.l:size
  endif
endfunction

" 'guifont' 'gfn'

" Cascadia_Code:h11:cANSI:qDRAFT
" Consolas:h12:cANSI:qDRAFT
" Courier_New:h11:cANSI:qDRAFT
" Courier_New:h11:b:cANSI:qDRAFT
" Lucida_Console:h11:cANSI:qDRAFT
" MS_Gothic:h11:cANSI:qDRAFT
" NSimSun:h11:cANSI:qDRAFT

" 8514oem:h11:cOEM:qDRAFT
" Terminal:h11:cOEM:qDRAFT

