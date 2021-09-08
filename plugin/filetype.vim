augroup filetypedetect

au BufNewFile,BufRead * lua require('filetype').resolve()

augroup END
