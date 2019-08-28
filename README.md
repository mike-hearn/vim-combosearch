# vim-combosearch

Combined file/code fuzzy search powered by
[fzf](https://github.com/junegunn/fzf),
[ripgrep](https://github.com/BurntSushi/ripgrep), and
[fd](https://github.com/sharkdp/fd).

![combosearch-lossy](https://user-images.githubusercontent.com/1016999/63821364-b8e72700-c91a-11e9-972a-770614775732.gif)

<hr/>
<p align="center"><b>TOC:</b>
<a href="#introduction">Introduction</a> |
<a href="#requirements">Requirements</a> |
<a href="#settings">Settings/Configuration</a> |
<a href="#faq">FAQ</a> |
<a href="#screenshots">Screenshots & Use-Cases</a>
<hr/>

## Introduction

vim-combosearch combines filename search and code search into a single,
filter-able list. I know it sounds simple but I've found it incredibly
productive in my day-to-day work.

One search of a `pattern` returns:

* All filenames matching `pattern` (similar to [ctrl-p](https://github.com/kien/ctrlp.vim))
* All code lines matching `pattern` (similar to `:grep`)
* All lines contained in any file matching `pattern`

To make this work, the search is executed *after three characters have been
entered*, then characters 4 through *n* use `:FZF` to filter the results.

<b>Note:</b> Although functional, this is largely intended as a
proof-of-concept of a type of code search I'd like to see implemented in every
code editor (hopefully implemented better than this, which is sort of a hack
job).

## Requirements

* [fzf](https://github.com/junegunn/fzf)
* [fzf.vim](https://github.com/junegunn/fzf.vim)
* [ripgrep](https://github.com/BurntSushi/ripgrep)
* [fd](https://github.com/sharkdp/fd)

Also currently <b>MacOS/Linux only</b> due to the search script using `bash`
(though Windows users should be able to use WSL).

(And yes, that's a lot of external requirements, which might understandably
offend the purists. I feel your pain. I wanted this to be as portable as
possible, but I wasn't willing to compromise on getting the exact search
results I wanted. For more info, see the FAQ for "Why doesn't this work with
just `grep` and `find`?")

## Installation

Make sure you've installed `ripgrep` and `fd.` On MacOS this is typically
done with `brew install ripgrep fd`. On Linux use the package manager
provided by your distribution, or follow the instructions on their respective
README files.

Once those are installed, include the vim-combosearch plugin in your `.vimrc` /
`init.vim`.

Sample `.vimrc`:

```vim
" This will auto-install vim-plug; remove if you already have it
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin('~/.vim/plugged')

Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'
Plug 'mike-hearn/vim-combosearch'

call plug#end()

let g:combosearch_trigger_key = "<c-p>"
```

## Settings/Configuration

In progress.

### Screenshots

1. You can search for a file name, then filter _within_ the file, all in one
   command:

   (example: search for `db/models/__init__.py` then filter down by `class`)

* You can search for a file
* You don't have to think "do I need grep or find" every time you want to
	search your code base.


## Frequently asked questions?

### What is this?

<b>vim-combosearch</b> combines filename search and code search, allowing for faster-ish
searching, better search patterns, and a lower cognitive load when attempting
to search.

### What problems is this actually fixing? Like... what's the point?

It solves a few problems, in my mind:

1. It allows you to search a filename, then immediately filter down INTO the
   file in one series of keystrokes.

<b>Problem:</b>

Many users search their code base in two distinct ways: 1) using a file search
(like [ctrlp](https://github.com/kien/ctrlp.vim),
[fzf.vim's](https://github.com/junegunn/fzf.vim) `:Files`) and 2) using `grep`,

This causes a few issues:

1. In some languages, the actual name of a class or component might not be
   declared in the code. For example, in Javascript you might have a
   `ButtonClass` that is imported from `ButtonClass.jsx`, but in that file
   itself, the name does not necessarily appear if exported as a pure function.

   If you *only* grep for `ButtonClass`, you will find everywhere the component
   is imported, but not the component itself.

2. Often times, when opening a file, what you really want is

*tl;dr* most users search their code base in two distinct ways: 1) using a file
search (like ctrlp, fzf.vim's `:Files`) and 2) using `grep`, `:Ag` or the like.
This plugin combines those functions.

*Longer explanation:*

This plugin is a proof-of-concept for how to combine file and code search for
maximum usability.  This plugin that waits until you've typed 2 characters, but
then sends *all matching files and lines of code* to FZF to be filtered.

The benefits are that, with one command, you can:

* Search by filename
* Search for any line of code
* Search with a combination of a file name, then immediately filter down into the code

Sometimes you might think you're searching by filename, then realize you want
to further filter down to a specific line.
