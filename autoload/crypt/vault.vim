
function! s:date() abort "{{{1
    return strftime(get(g:, 'crypt_date_format', '%Y%m%d'))
endfunction
" }}}1

function! crypt#vault#new() abort " {{{1
  silent execute ':e ' . get(g:, 'crypt_root', '.') . '/' . s:date() 
              \ . get(g:, 'crypt_vault_ext', '.md')
              \ . get(g:, 'crypt_ext', '.asc')
endfunction
" }}}1

function! crypt#vault#next() abort " {{{1
endfunction
" }}}1

function! crypt#vault#prev() abort " {{{1
endfunction
" }}}1

function! crypt#vault#search() abort " {{{1
endfunction
" }}}1

" Search for files in dir that match pattern
function! crypt#vault#files(fullscreen) "{{{1
    if !exists('*fzf#run')
        call wiki#log#warn('fzf must be installed for this to work')
        return
    endif
    let l:dir = get(g:, 'crypt_root', expand('~/.vim/vault'))
    call fzf#vim#files(l:dir,
               \ fzf#vim#with_preview({
               \ 'source': join([
                    \ 'rg',
                    \ '--follow',
                    \ '--smart-case',
                    \ '--line-number',
                    \ '--color never',
                    \ '--no-messages',
                    \ '--sortr path',
                    \ '--files',
                    \ l:dir]),
               \ 'down': '40%',
               \ 'options': ['--layout=reverse', '--inline-info']
               \ }), a:fullscreen)
endfunction
"}}}1
