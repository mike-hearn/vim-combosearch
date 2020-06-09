# vim-combosearch

This plugin extends `fzf.vim` to provide a combined file/code fuzzy search in a single interface.

*(Note: Due to `bash` requirement this is currently Linux/MacOS/WSL only.)*

![combosearch example](https://user-images.githubusercontent.com/1016999/63905223-979d3e00-c9e1-11e9-9f77-090b867c69c3.gif)

<hr/>
<p align="center"><b>TOC:</b>
<a href="#introduction">Introduction</a> |
<a href="#requirements">Requirements</a> |
<a href="#installation">Installation</a> |
<a href="#usage">Usage</a> |
<a href="#settingsconfiguration">Settings/Configuration</a> |
<a href="#faq">FAQ</a>
<hr/>

## Introduction

vim-combosearch combines filename, file contents and line numbers into a
single filterable list.

One search of a `pattern` returns:

* All filenames matching `pattern` (similar to [ctrl-p](https://github.com/kien/ctrlp.vim))
* All code lines matching `pattern` (similar to `:grep`)
* All lines contained in any file matching `pattern`

This involves fuzzy filtering through *a lot* of files, so to reduce the
amount, the search gets executed after three (3) characters have been entered,
then characters 4 through *n* use `fzf` to filter the results.

<b>Note:</b> Although functional, this is largely intended as a
proof-of-concept of a type of code search I'd like to see implemented in every
code editor (hopefully implemented better than this, which is sort of a hack
job).

## Requirements

* [fzf.vim](https://github.com/junegunn/fzf.vim)

Currently <b>MacOS/Linux only</b> due to the search script using `bash`
(though Windows users should be able to use WSL).

## Installation

1. Install ripgrep (`rg`) and `fd` (either through `brew install ripgrep fd`
on Mac, or your system's package manager on Linux)
2. Install the [fzf.vim](https://github.com/junegunn/fzf.vim) plugin
3. Install vim-combosearch
4. Add `let g:combosearch_trigger_key = "<c-p>"` to your vim config (if you
do not set this, the combosearch can still be run with `:ComboSearch`)


Sample `.vimrc`:

```vim
" This will auto-install vim-plug; remove if you already have it
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin('~/.vim/plugged')

" Optional if you want vim to auto-install the fzf binary
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }

" Required
Plug 'junegunn/fzf.vim'  " Place before vim-combosearch
Plug 'mike-hearn/vim-combosearch'

call plug#end()

" Sets the key mapping to trigger search
let g:combosearch_trigger_key = "<c-p>"
```

## Usage

You can either:

* Run it directly with `:ComboSearch`
* Manually map a key to `:ComboSearch`
* Set `let g:combosearch_trigger_key = "<c-p>"` (or whatever key you choose)
to let the plugin handle the mapping

## Settings/Configuration

### g:combosearch_trigger_key

Set the key mapping to trigger the combosearch input.

Because the default is set to none, until it's mapped you will have to call
`:ComboSearch`.

**Default:** None

```vim
" Recommended binding
let g:combosearch_trigger_key = "<c-p>"
```

### g:combosearch_pattern_length

Because combosearch can potentially end up filtering *a lot* of lines, the
actual search doesn't get kicked off until *after three characters have been
typed* (by default; see screenshots for this functionality in action) to
prevent the search script from returning too many results.

Depending on the speed of your CPU/hard drive, you may want to increase or
decrease this limit.

**Default:** 3

```vim
let g:combosearch_pattern_length = 3
```

### g:combosearch_fzf_exact_match

Set to 1 for fzf to default to accepting only exact (`--exact`) matches (this
gives more accurate filter results, but is less forgiving). Set to 0 to turn
exact filtering off.

**Default:** 1

```vim
" Example usage
let g:combosearch_fzf_exact_match = 1
```

## Frequently asked questions?

### What problems is this actually fixing? What's the point?

The #1 reason I made this was to reduce my own cognitive load when jumping
around files.

* Eliminating the question: do I need to use `ctrl-p` or `:grep`?
* Eliminating the question: at what point can I safely hit `<enter>` when typing a pattern to search with `:Ag`
* Eliminating the need to decide whether to search filename then code (example search: `utils models class CharField`) or code then filename (example search: `class CharField utils models`). Both are equally effective and return the same result.

With this search method, I can just run `:ComboSearch` and start typing
whatever my brain thinks of first.

### Why doesn't this work on Windows / in Gvim?

The hard work in this script is done with
[search.sh](https://github.com/mike-hearn/vim-combosearch/blob/master/plugin/search.sh),
which requires `bash`. If you have any ideas for how to move that script into
either VimL, or some other cross-platform scripting language, hit me with a
PR.
