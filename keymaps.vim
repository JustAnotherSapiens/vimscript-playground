" KEYMAPS
" FROM globals.vim IMPORT SetIndex

command! Keymapnext call SetKeymap(KIdx('+'))
command! Keymapprev call SetKeymap(KIdx('-'))

let g:keymaps = ['my_spanish', 'dvorak', 'german-qwertz', 'russian-jcukenwin']

let KIdx = SetIndex(len(g:keymaps))

function! SetKeymap(keymap_index, silent = v:false)
  let keymap = g:keymaps[a:keymap_index]
  let &keymap = l:keymap
  let &iminsert = 0
  if !a:silent
    echomsg "Keymap set to" l:keymap
  endif
endfunction

