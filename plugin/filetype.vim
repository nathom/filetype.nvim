augroup filetypedetect

au BufNewFile,BufRead * lua require('filetype').set_filetype()

augroup END
