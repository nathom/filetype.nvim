# filetype.nvim

Easily speed up your neovim startup time!


## What does this do?

This plugin is a replacement for the included `filetype.vim` that is sourced on startup.
The purpose of that file is to create a series of autocommands that set the `filetype` variable
depending on the filename. The issue is that creating autocommands have significant overhead, and
creating [800+ of them](https://github.com/vim/vim/blob/master/runtime/filetype.vim) as `filetype.vim` does is a very inefficient way to get the job done.

As you can see, `filetype.vim` is by far the heaviest nvim runtime file

```diff
13.782    [runtime] 
-	9.144     /usr/local/Cellar/neovim/0.5.0/share/nvim/runtime/filetype.vim
	1.662     /usr/local/Cellar/neovim/0.5.0/share/nvim/runtime/plugin/matchit.vim
	0.459     /usr/local/Cellar/neovim/0.5.0/share/nvim/runtime/syntax/synload.vim
	0.388     /usr/local/Cellar/neovim/0.5.0/share/nvim/runtime/plugin/netrwPlugin.vim
	0.334     /usr/local/Cellar/neovim/0.5.0/share/nvim/runtime/plugin/gzip.vim
	0.251     /usr/local/Cellar/neovim/0.5.0/share/nvim/runtime/plugin/rplugin.vim
	0.248     /usr/local/Cellar/neovim/0.5.0/share/nvim/runtime/syntax/syntax.vim
	0.216     /usr/local/Cellar/neovim/0.5.0/share/nvim/runtime/plugin/tarPlugin.vim
	0.205     /usr/local/Cellar/neovim/0.5.0/share/nvim/runtime/plugin/zipPlugin.vim
	0.186     /usr/local/Cellar/neovim/0.5.0/share/nvim/runtime/syntax/syncolor.vim
	0.173     /usr/local/Cellar/neovim/0.5.0/share/nvim/runtime/plugin/matchparen.vim
	0.123     /usr/local/Cellar/neovim/0.5.0/share/nvim/runtime/plugin/shada.vim
	0.114     /usr/local/Cellar/neovim/0.5.0/share/nvim/runtime/plugin/tohtml.vim
	0.075     /usr/local/Cellar/neovim/0.5.0/share/nvim/runtime/plugin/man.vim
	0.056     /usr/local/Cellar/neovim/0.5.0/share/nvim/runtime/ftplugin.vim
	0.048     /usr/local/Cellar/neovim/0.5.0/share/nvim/runtime/indent.vim
	0.039     /usr/local/Cellar/neovim/0.5.0/share/nvim/runtime/plugin/spellfile.vim
	0.038     /usr/local/Cellar/neovim/0.5.0/share/nvim/runtime/plugin/tutor.vim
	0.022     /usr/local/Cellar/neovim/0.5.0/share/nvim/runtime/plugin/health.vim
```

`filetype.nvim` fixes the issue by only creating a single autocommand that resolves the file type
when a buffer is opened. This method is ~175x faster\*!


## Usage

First, install using your favorite package manager. Using [packer](https://github.com/wbthomason/packer.nvim):

```lua
use("nathom/filetype.nvim")
```

If using a Neovim version earlier than 0.6.0, add the following to `init.lua`

```lua
-- Do not source the default filetype.vim
vim.g.did_load_filetypes = 1
```

That's it! You should now have a much snappier neovim experience!

## Customization

`filetype.nvim` allows you to easily add custom filetypes using the `setup` function. Here's an example:

```lua
-- In init.lua or filetype.nvim's config file
require("filetype").setup({
    overrides = {
        extensions = {
            -- Set the filetype of *.pn files to potion
            pn = "potion",
        },
        literal = {
            -- Set the filetype of files named "MyBackupFile" to lua
            MyBackupFile = "lua",
        },
        complex = {
            -- Set the filetype of any full filename matching the regex to gitconfig
            [".*git/config"] = "gitconfig", -- Included in the plugin
        },

        -- The same as the ones above except the keys map to functions
        function_extensions = {
            ["cpp"] = function()
                vim.bo.filetype = "cpp"
                -- Remove annoying indent jumping
                vim.bo.cinoptions = vim.bo.cinoptions .. "L0"
            end,
            ["pdf"] = function()
                vim.bo.filetype = "pdf"
                -- Open in PDF viewer (Skim.app) automatically
                vim.fn.jobstart(
                    "open -a skim " .. '"' .. vim.fn.expand("%") .. '"'
                )
            end,
        },
        function_literal = {
            Brewfile = function()
                vim.cmd("syntax off")
            end,
        },
        function_complex = {
            ["*.math_notes/%w+"] = function()
                vim.cmd("iabbrev $ $$")
            end,
        },

        shebang = {
            -- Set the filetype of files with a dash shebang to sh
            dash = "sh",
        },
    },
})
```

The `extensions` and `literal` tables are orders faster than the other ones
because they only require a table lookup. Always try to use these before resorting
to the `complex` tables, which require looping over the entries and running
a regex for each one.

## Performance Comparison

**These were measured using [startuptime.vim](https://github.com/tweekmonster/startuptime.vim)**

### Without `filetype.nvim`

Average startup time (100 rounds): **36.410 ms**

<details>
<summary>Sample log</summary>
  
  ```diff
  times in msec
   clock   self+sourced   self:  sourced script
   clock   elapsed:              other lines
  
  000.008  000.008: --- NVIM STARTING ---
  000.827  000.819: locale set
  001.304  000.477: inits 1
  001.358  000.054: window checked
  001.369  000.011: parsing arguments
  002.537  001.168: expanding arguments
  002.626  000.089: inits 2
  002.998  000.372: init highlight
  012.731  000.961  000.961: sourcing /Users/nathan/.local/share/nvim/site/pack/packer/start/vim-gruvbox8/colors/gruvbox8.vim
  012.829  009.549  008.588: sourcing /Users/nathan/.config/nvim/init.lua
  012.837  000.290: sourcing vimrc file(s)
  019.775  000.035  000.035: sourcing /Users/nathan/.local/share/nvim/site/pack/packer/start/nvim-treesitter/ftdetect/elixir.vim
  019.867  000.026  000.026: sourcing /Users/nathan/.local/share/nvim/site/pack/packer/start/nvim-treesitter/ftdetect/fish.vim
  019.949  000.022  000.022: sourcing /Users/nathan/.local/share/nvim/site/pack/packer/start/nvim-treesitter/ftdetect/gdresource.vim
  020.025  000.017  000.017: sourcing /Users/nathan/.local/share/nvim/site/pack/packer/start/nvim-treesitter/ftdetect/gdscript.vim
  020.108  000.018  000.018: sourcing /Users/nathan/.local/share/nvim/site/pack/packer/start/nvim-treesitter/ftdetect/gomod.vim
  020.194  000.029  000.029: sourcing /Users/nathan/.local/share/nvim/site/pack/packer/start/nvim-treesitter/ftdetect/graphql.vim
  020.280  000.029  000.029: sourcing /Users/nathan/.local/share/nvim/site/pack/packer/start/nvim-treesitter/ftdetect/hcl.vim
  020.358  000.021  000.021: sourcing /Users/nathan/.local/share/nvim/site/pack/packer/start/nvim-treesitter/ftdetect/heex.vim
  020.436  000.021  000.021: sourcing /Users/nathan/.local/share/nvim/site/pack/packer/start/nvim-treesitter/ftdetect/json5.vim
  020.517  000.024  000.024: sourcing /Users/nathan/.local/share/nvim/site/pack/packer/start/nvim-treesitter/ftdetect/julia.vim
  020.601  000.028  000.028: sourcing /Users/nathan/.local/share/nvim/site/pack/packer/start/nvim-treesitter/ftdetect/ledger.vim
  020.680  000.022  000.022: sourcing /Users/nathan/.local/share/nvim/site/pack/packer/start/nvim-treesitter/ftdetect/nix.vim
  020.764  000.028  000.028: sourcing /Users/nathan/.local/share/nvim/site/pack/packer/start/nvim-treesitter/ftdetect/ql.vim
  020.851  000.031  000.031: sourcing /Users/nathan/.local/share/nvim/site/pack/packer/start/nvim-treesitter/ftdetect/query.vim
  020.933  000.025  000.025: sourcing /Users/nathan/.local/share/nvim/site/pack/packer/start/nvim-treesitter/ftdetect/surface.vim
  021.127  000.031  000.031: sourcing /Users/nathan/.local/share/nvim/site/pack/packer/start/nvim-treesitter/ftdetect/teal.vim
  021.218  000.025  000.025: sourcing /Users/nathan/.local/share/nvim/site/pack/packer/start/nvim-treesitter/ftdetect/tlaplus.vim
  021.301  000.023  000.023: sourcing /Users/nathan/.local/share/nvim/site/pack/packer/start/nvim-treesitter/ftdetect/yang.vim
  021.382  000.023  000.023: sourcing /Users/nathan/.local/share/nvim/site/pack/packer/start/nvim-treesitter/ftdetect/zig.vim
- 022.213  009.200  008.722: sourcing /usr/local/Cellar/neovim/0.5.0/share/nvim/runtime/filetype.vim
  022.820  000.046  000.046: sourcing /usr/local/Cellar/neovim/0.5.0/share/nvim/runtime/ftplugin.vim
  023.350  000.042  000.042: sourcing /usr/local/Cellar/neovim/0.5.0/share/nvim/runtime/indent.vim
  025.075  000.180  000.180: sourcing /usr/local/Cellar/neovim/0.5.0/share/nvim/runtime/syntax/syncolor.vim
  026.263  001.786  001.606: sourcing /Users/nathan/.local/share/nvim/site/pack/packer/start/vim-gruvbox8/colors/gruvbox8.vim
  026.338  002.204  000.418: sourcing /usr/local/Cellar/neovim/0.5.0/share/nvim/runtime/syntax/synload.vim
  026.432  002.447  000.243: sourcing /usr/local/Cellar/neovim/0.5.0/share/nvim/runtime/syntax/syntax.vim
  030.711  000.317  000.317: sourcing /usr/local/Cellar/neovim/0.5.0/share/nvim/runtime/plugin/gzip.vim
  030.810  000.021  000.021: sourcing /usr/local/Cellar/neovim/0.5.0/share/nvim/runtime/plugin/health.vim
  030.951  000.074  000.074: sourcing /usr/local/Cellar/neovim/0.5.0/share/nvim/runtime/plugin/man.vim
  032.470  000.187  000.187: sourcing /usr/local/Cellar/neovim/0.5.0/share/nvim/runtime/pack/dist/opt/matchit/plugin/matchit.vim
  032.781  001.760  001.573: sourcing /usr/local/Cellar/neovim/0.5.0/share/nvim/runtime/plugin/matchit.vim
  033.095  000.240  000.240: sourcing /usr/local/Cellar/neovim/0.5.0/share/nvim/runtime/plugin/matchparen.vim
  033.539  000.364  000.364: sourcing /usr/local/Cellar/neovim/0.5.0/share/nvim/runtime/plugin/netrwPlugin.vim
  033.873  000.021  000.021: sourcing /Users/nathan/.local/share/nvim/rplugin.vim
  033.883  000.251  000.231: sourcing /usr/local/Cellar/neovim/0.5.0/share/nvim/runtime/plugin/rplugin.vim
  034.065  000.106  000.106: sourcing /usr/local/Cellar/neovim/0.5.0/share/nvim/runtime/plugin/shada.vim
  034.185  000.036  000.036: sourcing /usr/local/Cellar/neovim/0.5.0/share/nvim/runtime/plugin/spellfile.vim
  034.472  000.205  000.205: sourcing /usr/local/Cellar/neovim/0.5.0/share/nvim/runtime/plugin/tarPlugin.vim
  034.664  000.104  000.104: sourcing /usr/local/Cellar/neovim/0.5.0/share/nvim/runtime/plugin/tohtml.vim
  034.781  000.034  000.034: sourcing /usr/local/Cellar/neovim/0.5.0/share/nvim/runtime/plugin/tutor.vim
  035.048  000.178  000.178: sourcing /usr/local/Cellar/neovim/0.5.0/share/nvim/runtime/plugin/zipPlugin.vim
  042.395  000.030  000.030: sourcing /Users/nathan/.local/share/nvim/site/pack/packer/opt/vim-markdown/ftdetect/markdown.vim
  042.409  007.066  007.036: sourcing /Users/nathan/.config/nvim/plugin/packer_compiled.lua
  043.195  007.867: loading plugins
  043.813  000.037  000.037: sourcing /Users/nathan/.local/share/nvim/site/pack/packer/start/easy-replace.nvim/plugin/easy_replace.vim
  044.564  000.032  000.032: sourcing /Users/nathan/.local/share/nvim/site/pack/packer/start/nvim-bqf/plugin/bqf.vim
  046.955  001.984  001.984: sourcing /Users/nathan/.local/share/nvim/site/pack/packer/start/nvim-treesitter/plugin/nvim-treesitter.vim
  047.595  000.050  000.050: sourcing /Users/nathan/.local/share/nvim/site/pack/packer/start/nvim-treesitter/ftdetect/elixir.vim
  047.693  000.030  000.030: sourcing /Users/nathan/.local/share/nvim/site/pack/packer/start/nvim-treesitter/ftdetect/fish.vim
  047.851  000.092  000.092: sourcing /Users/nathan/.local/share/nvim/site/pack/packer/start/nvim-treesitter/ftdetect/gdresource.vim
  047.978  000.026  000.026: sourcing /Users/nathan/.local/share/nvim/site/pack/packer/start/nvim-treesitter/ftdetect/gdscript.vim
  048.082  000.026  000.026: sourcing /Users/nathan/.local/share/nvim/site/pack/packer/start/nvim-treesitter/ftdetect/gomod.vim
  048.183  000.031  000.031: sourcing /Users/nathan/.local/share/nvim/site/pack/packer/start/nvim-treesitter/ftdetect/graphql.vim
  048.284  000.031  000.031: sourcing /Users/nathan/.local/share/nvim/site/pack/packer/start/nvim-treesitter/ftdetect/hcl.vim
  048.378  000.024  000.024: sourcing /Users/nathan/.local/share/nvim/site/pack/packer/start/nvim-treesitter/ftdetect/heex.vim
  048.470  000.023  000.023: sourcing /Users/nathan/.local/share/nvim/site/pack/packer/start/nvim-treesitter/ftdetect/json5.vim
  048.562  000.022  000.022: sourcing /Users/nathan/.local/share/nvim/site/pack/packer/start/nvim-treesitter/ftdetect/julia.vim
  048.659  000.027  000.027: sourcing /Users/nathan/.local/share/nvim/site/pack/packer/start/nvim-treesitter/ftdetect/ledger.vim
  048.749  000.021  000.021: sourcing /Users/nathan/.local/share/nvim/site/pack/packer/start/nvim-treesitter/ftdetect/nix.vim
  048.842  000.024  000.024: sourcing /Users/nathan/.local/share/nvim/site/pack/packer/start/nvim-treesitter/ftdetect/ql.vim
  048.943  000.032  000.032: sourcing /Users/nathan/.local/share/nvim/site/pack/packer/start/nvim-treesitter/ftdetect/query.vim
  049.035  000.019  000.019: sourcing /Users/nathan/.local/share/nvim/site/pack/packer/start/nvim-treesitter/ftdetect/surface.vim
  049.115  000.018  000.018: sourcing /Users/nathan/.local/share/nvim/site/pack/packer/start/nvim-treesitter/ftdetect/teal.vim
  049.197  000.017  000.017: sourcing /Users/nathan/.local/share/nvim/site/pack/packer/start/nvim-treesitter/ftdetect/tlaplus.vim
  049.276  000.017  000.017: sourcing /Users/nathan/.local/share/nvim/site/pack/packer/start/nvim-treesitter/ftdetect/yang.vim
  049.390  000.017  000.017: sourcing /Users/nathan/.local/share/nvim/site/pack/packer/start/nvim-treesitter/ftdetect/zig.vim
  049.772  000.047  000.047: sourcing /Users/nathan/.local/share/nvim/site/pack/packer/start/nvim-web-devicons/plugin/nvim-web-devicons.vim
  050.319  000.043  000.043: sourcing /Users/nathan/.local/share/nvim/site/pack/packer/start/plenary.nvim/plugin/plenary.vim
  051.424  000.301  000.301: sourcing /Users/nathan/.local/share/nvim/site/pack/packer/start/vim-rooter/plugin/rooter.vim
  051.751  005.565: loading packages
  052.307  000.556: loading after plugins
  052.316  000.010: inits 3
  052.328  000.012: clearing screen
  054.268  001.940: opening buffers
  054.539  000.271: BufEnter autocommands
- 054.542  000.003: editing files in windows
  ```
</details>


### With `filetype.nvim`

Average startup time (100 rounds): **26.492 ms**

<details>
  <summary>Sample log</summary>
  
  ```diff
    times in msec
   clock   self+sourced   self:  sourced script
   clock   elapsed:              other lines
  
  000.008  000.008: --- NVIM STARTING ---
  000.813  000.805: locale set
  001.282  000.470: inits 1
  001.334  000.052: window checked
  001.345  000.011: parsing arguments
  002.386  001.041: expanding arguments
  002.459  000.073: inits 2
  002.859  000.400: init highlight
  013.346  001.066  001.066: sourcing /Users/nathan/.local/share/nvim/site/pack/packer/start/vim-gruvbox8/colors/gruvbox8.vim
  013.471  010.343  009.276: sourcing /Users/nathan/.config/nvim/init.lua
  013.485  000.283: sourcing vimrc file(s)
+ 013.666  000.025  000.025: sourcing /usr/local/Cellar/neovim/0.5.0/share/nvim/runtime/filetype.vim
  014.360  000.057  000.057: sourcing /usr/local/Cellar/neovim/0.5.0/share/nvim/runtime/ftplugin.vim
  014.993  000.043  000.043: sourcing /usr/local/Cellar/neovim/0.5.0/share/nvim/runtime/indent.vim
  016.715  000.168  000.168: sourcing /usr/local/Cellar/neovim/0.5.0/share/nvim/runtime/syntax/syncolor.vim
  017.849  001.667  001.499: sourcing /Users/nathan/.local/share/nvim/site/pack/packer/start/vim-gruvbox8/colors/gruvbox8.vim
  017.932  002.321  000.654: sourcing /usr/local/Cellar/neovim/0.5.0/share/nvim/runtime/syntax/synload.vim
  018.025  002.551  000.230: sourcing /usr/local/Cellar/neovim/0.5.0/share/nvim/runtime/syntax/syntax.vim
  021.955  000.187  000.187: sourcing /usr/local/Cellar/neovim/0.5.0/share/nvim/runtime/plugin/gzip.vim
  022.056  000.021  000.021: sourcing /usr/local/Cellar/neovim/0.5.0/share/nvim/runtime/plugin/health.vim
  022.175  000.047  000.047: sourcing /usr/local/Cellar/neovim/0.5.0/share/nvim/runtime/plugin/man.vim
  023.777  000.207  000.207: sourcing /usr/local/Cellar/neovim/0.5.0/share/nvim/runtime/pack/dist/opt/matchit/plugin/matchit.vim
  024.039  001.791  001.584: sourcing /usr/local/Cellar/neovim/0.5.0/share/nvim/runtime/plugin/matchit.vim
  024.276  000.164  000.164: sourcing /usr/local/Cellar/neovim/0.5.0/share/nvim/runtime/plugin/matchparen.vim
  024.668  000.318  000.318: sourcing /usr/local/Cellar/neovim/0.5.0/share/nvim/runtime/plugin/netrwPlugin.vim
  024.992  000.017  000.017: sourcing /Users/nathan/.local/share/nvim/rplugin.vim
  025.001  000.245  000.228: sourcing /usr/local/Cellar/neovim/0.5.0/share/nvim/runtime/plugin/rplugin.vim
  025.153  000.077  000.077: sourcing /usr/local/Cellar/neovim/0.5.0/share/nvim/runtime/plugin/shada.vim
  025.270  000.035  000.035: sourcing /usr/local/Cellar/neovim/0.5.0/share/nvim/runtime/plugin/spellfile.vim
  025.469  000.118  000.118: sourcing /usr/local/Cellar/neovim/0.5.0/share/nvim/runtime/plugin/tarPlugin.vim
  025.719  000.163  000.163: sourcing /usr/local/Cellar/neovim/0.5.0/share/nvim/runtime/plugin/tohtml.vim
  025.834  000.031  000.031: sourcing /usr/local/Cellar/neovim/0.5.0/share/nvim/runtime/plugin/tutor.vim
  026.077  000.169  000.169: sourcing /usr/local/Cellar/neovim/0.5.0/share/nvim/runtime/plugin/zipPlugin.vim
  033.400  000.027  000.027: sourcing /Users/nathan/.local/share/nvim/site/pack/packer/opt/vim-markdown/ftdetect/markdown.vim
  033.411  007.043  007.016: sourcing /Users/nathan/.config/nvim/plugin/packer_compiled.lua
  034.214  007.645: loading plugins
  034.853  000.030  000.030: sourcing /Users/nathan/.local/share/nvim/site/pack/packer/start/easy-replace.nvim/plugin/easy_replace.vim
+ 035.412  000.022  000.022: sourcing /Users/nathan/.local/share/nvim/site/pack/packer/start/filetype.nvim/plugin/filetype.vim
  036.064  000.027  000.027: sourcing /Users/nathan/.local/share/nvim/site/pack/packer/start/nvim-bqf/plugin/bqf.vim
  038.325  001.867  001.867: sourcing /Users/nathan/.local/share/nvim/site/pack/packer/start/nvim-treesitter/plugin/nvim-treesitter.vim
  038.937  000.037  000.037: sourcing /Users/nathan/.local/share/nvim/site/pack/packer/start/nvim-treesitter/ftdetect/elixir.vim
  039.039  000.032  000.032: sourcing /Users/nathan/.local/share/nvim/site/pack/packer/start/nvim-treesitter/ftdetect/fish.vim
  039.132  000.023  000.023: sourcing /Users/nathan/.local/share/nvim/site/pack/packer/start/nvim-treesitter/ftdetect/gdresource.vim
  039.284  000.023  000.023: sourcing /Users/nathan/.local/share/nvim/site/pack/packer/start/nvim-treesitter/ftdetect/gdscript.vim
  039.427  000.022  000.022: sourcing /Users/nathan/.local/share/nvim/site/pack/packer/start/nvim-treesitter/ftdetect/gomod.vim
  039.523  000.028  000.028: sourcing /Users/nathan/.local/share/nvim/site/pack/packer/start/nvim-treesitter/ftdetect/graphql.vim
  039.620  000.030  000.030: sourcing /Users/nathan/.local/share/nvim/site/pack/packer/start/nvim-treesitter/ftdetect/hcl.vim
  039.711  000.023  000.023: sourcing /Users/nathan/.local/share/nvim/site/pack/packer/start/nvim-treesitter/ftdetect/heex.vim
  039.800  000.022  000.022: sourcing /Users/nathan/.local/share/nvim/site/pack/packer/start/nvim-treesitter/ftdetect/json5.vim
  039.888  000.021  000.021: sourcing /Users/nathan/.local/share/nvim/site/pack/packer/start/nvim-treesitter/ftdetect/julia.vim
  039.983  000.029  000.029: sourcing /Users/nathan/.local/share/nvim/site/pack/packer/start/nvim-treesitter/ftdetect/ledger.vim
  040.075  000.026  000.026: sourcing /Users/nathan/.local/share/nvim/site/pack/packer/start/nvim-treesitter/ftdetect/nix.vim
  040.169  000.025  000.025: sourcing /Users/nathan/.local/share/nvim/site/pack/packer/start/nvim-treesitter/ftdetect/ql.vim
  040.271  000.035  000.035: sourcing /Users/nathan/.local/share/nvim/site/pack/packer/start/nvim-treesitter/ftdetect/query.vim
  040.362  000.024  000.024: sourcing /Users/nathan/.local/share/nvim/site/pack/packer/start/nvim-treesitter/ftdetect/surface.vim
  040.455  000.027  000.027: sourcing /Users/nathan/.local/share/nvim/site/pack/packer/start/nvim-treesitter/ftdetect/teal.vim
  040.547  000.025  000.025: sourcing /Users/nathan/.local/share/nvim/site/pack/packer/start/nvim-treesitter/ftdetect/tlaplus.vim
  040.638  000.025  000.025: sourcing /Users/nathan/.local/share/nvim/site/pack/packer/start/nvim-treesitter/ftdetect/yang.vim
  040.731  000.027  000.027: sourcing /Users/nathan/.local/share/nvim/site/pack/packer/start/nvim-treesitter/ftdetect/zig.vim
  041.143  000.047  000.047: sourcing /Users/nathan/.local/share/nvim/site/pack/packer/start/nvim-web-devicons/plugin/nvim-web-devicons.vim
  041.688  000.042  000.042: sourcing /Users/nathan/.local/share/nvim/site/pack/packer/start/plenary.nvim/plugin/plenary.vim
  042.618  000.203  000.203: sourcing /Users/nathan/.local/share/nvim/site/pack/packer/start/vim-rooter/plugin/rooter.vim
  042.980  006.026: loading packages
  043.533  000.553: loading after plugins
  043.543  000.010: inits 3
  043.554  000.011: clearing screen
  045.378  001.823: opening buffers
  045.676  000.298: BufEnter autocommands
+ 045.679  000.003: editing files in windows
  ```
</details>

\* The time my machine takes to source the file goes from 9.1 ms to (0.022 + 0.03) ms, which is a 175x speedup.

## Contributions

All contributions are appreciated! But please make sure to follow these guidelines:

- Format your code with stylua, complying with the rules in the `stylua.toml` file
- Document any new functions you write, and update the documentation of functions
you edit if appropriate
- Set the base branch to `dev`
