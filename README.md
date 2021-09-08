# filetype.nvim

Easily speed up your neovim startup time!


## What does this do?

This plugin is a replacement for the included `filetype.vim` that is sourced on startup.
The purpose of that file is to create a series of autocommands that set the `filetype` variable
depending on the filename. The issue is that creating autocommands have significant overhead, and
creating hundreds like `filetype.vim` does really bogs down your startup time.

`filetype.nvim` fixes the issue by only creating a single autocommand that resolves the filetype
when a buffer is opened using Lua tables. This can be more than 450x faster than using `filetype.vim`!
See Performance for benchmarks.

## Usage

First, install using your favorite package manager

```lua
use("nathom/filetype.nvim")
```

Then, add the following to your `init.lua`

```lua
-- Do not source the default filetype.vim
vim.g.did_load_filetypes = 1
```

That's it! You should now have a much snappier neovim experience!
