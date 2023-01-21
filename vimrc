syntax on
set number
set ts=4
set expandtab
set cursorline
hi CursorLine cterm=NONE ctermbg=darkred ctermfg=white guibg=darkred guifg=white
set colorcolumn=121
highlight ExtraWhitespace ctermbg=red guibg=red
autocmd BufWinEnter * match ExtraWhitespace /\s\+$\| \+\ze\t\+\|\t\+\zs \+/
