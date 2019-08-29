" Displays an input field where it accepts two characters, then sends those
" characters to the FZF Command FileAndCodeSearchWithPrefix

" User provided settings
let s:exact = get(g:, 'combosearch_fzf_exact_match', 1)
let s:ignore_options = get(g:, 'combosearch_ignore_patterns', [".git", "node_modules"])
let s:trigger_key = get(g:, 'combosearch_trigger_key', 'NONE')
let s:combosearch_pattern_length = get(g:, 'combosearch_pattern_length', 3)

" Privately used variables
let s:plugindir = expand('<sfile>:p:h:h')

" Set key mapping, if specified
if s:trigger_key != "NONE"
  execute "nnoremap <silent> " . s:trigger_key . " :call VimCombosearch()<CR>"
endif

" Given a string filename of a binary (example: 'sh'), sets
" executables_not_found to 1 if the binary does not exist on the PATH
function! s:verify_executable(binname)
endfunction

" Checks against OS
function! s:validate_compatibility()
  let s:executables_not_found = 0  " Set to 1 if any of the required bins are missing
  let s:missing_executables = []   " List of missing binaries, if any

  " Won't work on Windows
  if has('win32')
    echoerr "Plugin not compatible with Windows; try running vim in WSL"
    return 0
  endif

  " Verify all executables
  if executable("fd") == 0 && executable("fdfind") == 0
      let s:executables_not_found = 1
  endif
  for i in ['rg', 'fzf', 'sh']
    if executable(i) == 0
      let s:executables_not_found = 1
      call add(s:missing_executables, i)
    endif
  endfor
  if s:executables_not_found
    echoerr "vim-combosearch requires external binaries: " . join(s:missing_executables, ', ')
    return 0
  endif

  return 1
endfunction

function! s:on_input_change()
  if len(getcmdline()) == s:combosearch_pattern_length
    call feedkeys("\<CR>")
    echo " "
    redraw!
  endif
endfunction

function! VimCombosearch()
  if s:validate_compatibility() == 0
    return
  endif

  augroup input_test
    au!
    autocmd CmdlineChanged @ call s:on_input_change()
  augroup end

  let l:string = input("File/code search: ")

  au! input_test

  execute "FileAndCodeSearchWithPrefix " . l:string
endfunction

autocmd VimEnter * command! -bang -nargs=0 ComboSearch call VimCombosearch()
autocmd VimEnter * command! -bang -nargs=* FileAndCodeSearchWithPrefix
      \ call fzf#vim#grep(
      \   s:plugindir . '/plugin/search.sh ' . shellescape(<q-args>) . ' ' . join(s:ignore_options, '\\n'),
      \   1,
      \   <bang>0 ? fzf#vim#with_preview({'options': '--prompt="Combo> " ' . (s:exact == 1 ? '--exact' : '') . ' -q ' . shellescape(<q-args>)}, 'up:60%')
      \           : fzf#vim#with_preview({'options': '--prompt="Combo> " ' . (s:exact == 1 ? '--exact' : '') . ' -q ' . shellescape(<q-args>)}, 'right:50%:hidden', '?'),
      \   <bang>0
      \)
