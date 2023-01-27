
command! -range -nargs=1 Winfrac let g:windowfraction = <args>
let g:windowfraction = 5

function! CursorAtWinFrac(num, den)
  let topwinline = line('w0') - 1
  let botwinline = line('w$') + 1
  let fracline = float2nr(floor(((l:botwinline - l:topwinline) * a:num) / a:den))
  normal! zt
  execute "normal! ".(l:fracline - 1)."\<C-Y>"
endfunction

" The line is exact if the number of window lines equals:
" ('den' stands for 'denominator')
" x*den + (den-1)
" (x+1)*den - 1
" Explanation:
" den |     representation
" ----|----------------------
"  1  |           l
"  2  |         l . l
"  3  |       l . l . l
"  4  |     l . l . l . l
"  5  |   l . l . l . l . l
"  6  | l . l . l . l . l . l
" Where:
" . -> fracline
" l -> same number of lines
" Therefore, for . to be an exact line all l's must be equal,
" i.e. n*l + (n-1)*. represent the number of lines.
" But the number of . is always n - 1, and n = denominator, hence:
" Number of lines for exact fraction = (den-1) + x*den
" Number of lines for exact fraction = (x+1)*den - 1
" Where x could be any positive integer > 1.


" winheight()		
" winwidth()		
" win_screenpos()		
" winlayout()		
" winrestcmd()		
" winsaveview()		
" winrestview()		

