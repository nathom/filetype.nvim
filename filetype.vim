let g:did_load_filetypes = 1

augroup filetypedetect
    au!
    au BufNewFile,BufRead * lua require('filetype').resolve()
augroup END
