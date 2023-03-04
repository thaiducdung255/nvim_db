if exists('g:loaded_dbui') | finish | endif

let s:save_cpo = &cpo
set cpo&vim

hi def link DBUIHeader     Number
hi def link DBUISubHeader  Identifier

command! NvimDB lua require'nvim_db'.nvim_db()

let &cpo = s:save_cpo
unlet s:save_cpo

let g:loaded_dbui = 1
