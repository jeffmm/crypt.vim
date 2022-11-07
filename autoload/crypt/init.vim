function! crypt#init#apply_mappings_from_dict(dict, arg) abort " {{{1
  for [l:rhs, l:lhs] in items(a:dict)
    if l:rhs[0] !=# '<'
      let l:mode = l:rhs[0]
      let l:rhs = l:rhs[2:]
    else
      let l:mode = 'n'
    endif

    if hasmapto(l:rhs, l:mode) || !empty(maparg(l:lhs, l:mode))
      continue
    endif

    execute l:mode . 'map <silent>' . a:arg l:lhs l:rhs
  endfor
endfunction
" }}}1
