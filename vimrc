syntax on
set number
set ts=4
set expandtab
set cursorline
hi CursorLine cterm=NONE ctermbg=darkred ctermfg=white guibg=darkred guifg=white
set colorcolumn=121
highlight ExtraWhitespace ctermbg=red guibg=red
autocmd BufWinEnter * match ExtraWhitespace /\s\+$\| \+\ze\t\+\|\t\+\zs \+/
set hlsearch

let &t_EI = "\<Esc>[1;31;40m\<Esc>[2 q"  " Normal mode: red block
let &t_SI = "\<Esc>[1;32;40m\<Esc>[6 q"  " Insert mode: bright green bold stick
let &t_SR = "\<Esc>[1;33;40m\<Esc>[2 q"  " Replace mode: yellow block
