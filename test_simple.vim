" Simple test for combosearch
" Run with :source test_simple.vim

" Check if fzf.vim is loaded
if exists(':FZF')
  echo "FZF is available"
else
  echo "FZF is NOT available - please install junegunn/fzf.vim"
endif

" Check if fzf#vim#with_preview exists
if exists('*fzf#vim#with_preview')
  echo "fzf#vim#with_preview is available"
else
  echo "fzf#vim#with_preview is NOT available"
endif

" Try to run ComboSearch
try
  ComboSearch test
  echo "ComboSearch command works!"
catch
  echo "Error running ComboSearch: " . v:exception
endtry