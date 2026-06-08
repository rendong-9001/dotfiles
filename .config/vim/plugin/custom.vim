" filetype
syntax on
filetype plugin indent on
augroup custom_indent
    autocmd!
    autocmd FileType yml,yaml setlocal et sw=2 ts=2 sts=2
    autocmd FileType json,jsonc setlocal et sw=2 ts=2 sts=2
    autocmd FileType css,scss setlocal et sw=2 ts=2 sts=2
    autocmd FileType markdown setlocal et sw=4 ts=4 sts=4
    autocmd FileType sh,bash setlocal et sw=4 ts=4 sts=4
augroup END

" toggle minimal view
function! s:toggle_minimal_view()
    if &number || &relativenumber || &foldcolumn > 0
        set nonu nornu foldcolumn=0
    else
        set nu rnu foldcolumn=1
    endif
endfunction
nnoremap <Leader>o :call <SID>toggle_minimal_view()<CR>

" remove trailing whitespaces
function! s:strip_trailing_whitespaces()
    let l:save = winsaveview()
    keeppatterns %s/\s\+$//e
    call winrestview(l:save)
endfunction
augroup strip_trailing_whitespace
    autocmd!
    autocmd BufWritePre * call <SID>strip_trailing_whitespaces()
augroup END
