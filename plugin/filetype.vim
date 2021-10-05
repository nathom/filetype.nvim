augroup filetypedetect
    au!
    au BufNewFile,BufRead * lua require('filetype').resolve()
augroup END
