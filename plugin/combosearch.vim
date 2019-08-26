" Displays an input field where it accepts two characters, then sends those
" characters to the FZF Command FileAndCodeSearchWithPrefix

" User provided settings
let s:exact = get(g:, 'combosearch_fzf_exact_match', 1)
let s:ignore_options = get(g:, 'combosearch_ignore_patterns', [".git", "node_modules"])
let s:trigger_key = get(g:, 'combosearch_trigger_key', 'NONE')

" Privately used variables
let s:plugindir = expand('<sfile>:p:h:h')
let s:executablesNotFound = 0
let s:missingExecutables = []

" Set key mapping, if specified
if s:trigger_key != "NONE"
  execute "nnoremap <silent> " . s:trigger_key . " :call VimCombosearch()<CR>"
endif

function! s:VerifyExecutable(binname)
  if executable(a:binname) == 0
    let s:executablesNotFound = 1
    call add(s:missingExecutables, a:binname)
  endif
endfunction

function! s:ValidateCompatibility()
  " Won't work on Windows
  if has('win32')
    echoerr "Plugin not compatible with Windows; try running vim in WSL"
    return
  endif

  " Verify all executables
  for i in ['rg', 'fd', 'fzf', 'sh']
    call s:VerifyExecutable(i)
  endfor
  if s:executablesNotFound
    echoerr "vim-combosearch requires external binaries: " . join(s:missingExecutables, ', ')
    return ''
  endif
endfunction


function! VimCombosearch()

  call s:ValidateCompatibility()

  echon "File/code search> "
  let l:number = 2
  let l:string = ""

  while l:number > 0
    let l:getchar = getchar()
    let l:newchar = nr2char(l:getchar)
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
      \   <bang>0 ? fzf#vim#with_preview({'options': '--prompt="Combo> " --exact -q ' . shellescape(<q-args>)}, 'up:60%')
      \           : fzf#vim#with_preview({'options': '--prompt="Combo> " --exact -q ' . shellescape(<q-args>)}, 'right:50%:hidden', '?'),
      \   <bang>0
      \)
