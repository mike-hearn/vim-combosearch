" Displays an input field where it accepts two characters, then sends those
" characters to the FZF Command FileAndCodeSearchWithPrefix

" User provided settings
let s:exact = get(g:, 'combosearch_fzf_exact_match', 1)
let s:ignore_options = get(g:, 'combosearch_ignore_patterns', [".git", "node_modules"])

let s:plugindir = expand('<sfile>:p:h:h')

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

  echo " "
  redraw!
  execute "FileAndCodeSearchWithPrefix " . l:string
endfunction

autocmd VimEnter * command! -bang -nargs=* FileAndCodeSearchWithPrefix
      \ call fzf#vim#grep(
      \   s:plugindir . '/plugin/search.sh ' . shellescape(<q-args>) . ' ' . join(s:ignore_options, '\\n'),
      \   1,
      \   <bang>0 ? fzf#vim#with_preview({'options': '--exact -q ' . shellescape(<q-args>)}, 'up:60%')
      \           : fzf#vim#with_preview({'options': '--exact -q ' . shellescape(<q-args>)}, 'right:50%:hidden', '?'),
      \   <bang>0
      \)
