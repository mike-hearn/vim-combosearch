# vim-combosearch

This Neovim Lua plugin extends `fzf.vim` to provide a combined filename search and code
fuzzy search in a single interface.

**Now rewritten in Lua for better Neovim integration and cross-platform support!**

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

* Neovim 0.7.0 or later
* [fzf.vim](https://github.com/junegunn/fzf.vim)

The Lua version now has experimental Windows support! The plugin will work on all platforms,
though performance may vary on Windows.

## Installation

1. Install the [fzf.vim](https://github.com/junegunn/fzf.vim) plugin
2. Install vim-combosearch
3. Configure the plugin in your init.lua or init.vim

### For Neovim with Lua configuration (init.lua):

```lua
-- Using lazy.nvim
{
  'mike-hearn/vim-combosearch',
  dependencies = {
    'junegunn/fzf',
    'junegunn/fzf.vim',
  },
  config = function()
    require('combosearch').setup({
      trigger_key = '<c-p>',        -- Key to trigger search
      trigger_key_all = '<c-s-p>',  -- Key to trigger search all
      pattern_length = 3,           -- Characters before search triggers
      fzf_exact_match = true,       -- Use exact matching in fzf
    })
  end,
}

-- Or using packer.nvim
use {
  'mike-hearn/vim-combosearch',
  requires = {
    'junegunn/fzf',
    'junegunn/fzf.vim',
  },
  config = function()
    require('combosearch').setup({
      trigger_key = '<c-p>',
    })
  end,
}
```

### For traditional Vim/Neovim configuration (.vimrc/init.vim):

```vim
call plug#begin('~/.vim/plugged')

" Required dependencies
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'
Plug 'mike-hearn/vim-combosearch'

call plug#end()

" Configure combosearch after plugins are loaded
lua << EOF
require('combosearch').setup({
  trigger_key = '<c-p>',
  pattern_length = 3,
})
EOF
```

## Usage

You can use combosearch in several ways:

* `:ComboSearch` - Start a search (will auto-trigger after typing 3 characters)
* `:ComboSearch!` - Start a search with alternate preview layout
* `:ComboSearch query` - Start a search with an initial query
* `:ComboSearchAll` - Force search all files (ignores git repository)
* `:ComboSearchAll!` - Force search all with alternate preview layout
* Use the configured trigger key (e.g., `<c-p>`)
* Use the configured trigger key for search all (e.g., `<c-s-p>`)

Press `?` in the FZF window to toggle the preview pane.

## Settings/Configuration

The plugin is configured through the `setup()` function:

```lua
require('combosearch').setup({
  -- Key mapping to trigger search
  trigger_key = '<c-p>',         -- Default: nil
  
  -- Key mapping to trigger search all (non-git)
  trigger_key_all = '<c-s-p>',   -- Default: nil
  
  -- Number of characters before search triggers
  pattern_length = 3,            -- Default: 3
  
  -- Use exact matching in fzf
  fzf_exact_match = true,        -- Default: true
  
  -- FZF preview window position
  preview_position = 'right:50%:hidden',  -- Default
  preview_position_alt = 'up:60%',        -- Alternative position
})
```

### Configuration Options

#### `trigger_key`
Key mapping to trigger the combosearch. If not set, you'll need to use `:ComboSearch`.

#### `trigger_key_all`
Key mapping to trigger search all (forces filesystem search, ignoring git).

#### `pattern_length`
Number of characters to type before the search automatically triggers. This prevents
searching through too many results on short queries.

#### `fzf_exact_match`
When `true`, fzf uses exact matching (`--exact` flag), which gives more accurate results
but is less forgiving of typos. Set to `false` for fuzzy matching.

## Frequently asked questions?

### What problems is this actually fixing? What's the point?

The #1 reason I made this was to reduce my own cognitive load when jumping
around files.

* Eliminating the question: do I need to use `ctrl-p` or `:grep`?
* Eliminating the question: at what point can I safely hit `<enter>` when typing a pattern to search with `:Ag`
* Eliminating the need to decide whether to search filename then code (example search: `utils models class CharField`) or code then filename (example search: `class CharField utils models`). Both are equally effective and return the same result.

With this search method, I can just run `:ComboSearch` and start typing
whatever my brain thinks of first.

### Does this work on Windows?

Yes! The Lua version now has experimental Windows support. The plugin will automatically
use appropriate commands for your platform. Performance may vary on Windows compared to
Unix-like systems.

### How is this different from the original Vimscript version?

The Lua rewrite offers several improvements:
- Better Neovim integration with modern Lua APIs
- Cleaner configuration and setup
- More maintainable codebase structure
- Proper command bang support (`:ComboSearch!`)
- FZF preview support restored

Note: The search functionality still uses the optimized bash script for streaming
performance. A full Lua implementation using async APIs is planned for the future.

### Can I still use the old Vimscript version?

The original Vimscript files are still in the repository. However, the Lua version
is now the recommended and actively maintained version.
