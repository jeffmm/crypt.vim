"
" ENCRYPTION
"

function! s:init_option(name, default) abort " {{{1
  let l:option = 'g:' . a:name
  if !exists(l:option)
    let {l:option} = a:default
  endif
endfunction
" }}}1

call s:init_option('crypt_root', expand('~/.vim/vault'))
call s:init_option('wiki_mappings_use_defaults', 'all')

" Don't save backups of *.gpg files
set backupskip+=*.gpg,*.asc

" The main encryption script
augroup encrypted
  au!
  " Disable swap files, viminfo, and set binary file format before reading the file
  autocmd BufReadPre,FileReadPre *.gpg,*.asc
              \ set viminfo= |
              \ setlocal noswapfile
  autocmd BufReadPre,FileReadPre *.gpg setlocal bin
  " Decrypt the contents after reading the file, reset binary file format
  " and run any BufReadPost autocmds matching the file name without the .gpg
  " extension
  autocmd BufReadPost,FileReadPost *.gpg,*.asc
              \ execute "'[,']!gpg --decrypt --default-recipient-self 2> /dev/null" |
              \ setlocal nobin |
              \ execute "doautocmd BufReadPost " . expand("%:r")
  " Set binary file format and encrypt the contents before writing the file
  autocmd BufWritePre,FileWritePre *.gpg,*.asc
              \ let window_view=winsaveview()
  autocmd BufWritePre,FileWritePre *.gpg
              \ setlocal bin |
              \ execute "'[,']!gpg --encrypt --default-recipient-self 2> /dev/null"
  autocmd BufWritePre,FileWritePre *.asc
              \ execute "'[,']!gpg --encrypt --armor --default-recipient-self 2> /dev/null"
  " After writing the file, do an :undo to revert the encryption in the
  " buffer, and reset binary file format
  autocmd BufWritePost,FileWritePost *.gpg,*.asc
              \ silent u |
              \ setlocal nobin |
              \ call winrestview(window_view) |
              \ let window_view=""
augroup END

command! CryptVaultNew      call crypt#vault#new()
command! CryptVaultPrev     call crypt#vault#prev()
command! CryptVaultNext     call crypt#vault#next()
command! CryptVaultSearch   call crypt#vault#search()
command! -bang CryptVaultFiles    call crypt#vault#files(<bang>0)

nnoremap <silent> <plug>(crypt-vault-new)       :CryptVaultNew<cr>
nnoremap <silent> <plug>(crypt-vault-next)      :CryptVaultNext<cr>
nnoremap <silent> <plug>(crypt-vault-prev)      :CryptVaultPrev<cr>
nnoremap <silent> <plug>(crypt-vault-search)    :CryptVaultSearch<cr>
nnoremap <silent> <plug>(crypt-vault-files)     :CryptVaultFiles<cr>

" Apply default mappings
let s:mappings = index(['all', 'global'], g:wiki_mappings_use_defaults) >= 0
      \ ? {
      \ '<plug>(crypt-vault-new)' : '<leader>jn',
      \ '<plug>(crypt-vault-next)' : '<leader>j,',
      \ '<plug>(crypt-vault-prev)' : '<leader>j.',
      \ '<plug>(crypt-vault-search)' : '<leader>js',
      \ '<plug>(crypt-vault-files)' : '<leader>jf',
      \} : {}
call extend(s:mappings, get(g:, 'crypt_mappings_global', {}))
call crypt#init#apply_mappings_from_dict(s:mappings, '')

