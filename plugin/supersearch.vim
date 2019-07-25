" Displays an input field where it accepts two characters, then sends those
" characters to the FZF Command FileAndCodeSearchWithPrefix
function! GetTwoCharactersAndSendToFZF()
  echon "File/code search> "
  let l:number = 2
  let l:string = ""

  while l:number > 0
    let l:newchar = nr2char(getchar())
    let l:string .= l:newchar
    echon l:newchar
    let l:number -= 1
  endwhile

  execute "FileAndCodeSearchWithPrefix " . l:string
  call feedkeys(l:string)
endfunction

let s:plugindir = expand('<sfile>:p:h:h')

autocmd VimEnter * command! -bang -nargs=* FileAndCodeSearchWithPrefix
      \ call fzf#vim#grep(
      \   s:plugindir . '/plugin/search.sh ' . <q-args>,
      \   1,
      \   <bang>0 ? fzf#vim#with_preview('up:60%')
      \           : fzf#vim#with_preview('right:50%:hidden', '?'),
      \   <bang>0
      \)
