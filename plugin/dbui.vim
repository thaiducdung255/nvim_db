if exists('g:loaded_dbui') | finish | endif

let s:save_cpo = &cpo
set cpo&vim

hi def link DBUIHeader     Number
hi def link DBUISubHeader  Identifier

command! Dbui lua require'dbui'.dbui()

let &cpo = s:save_cpo
unlet s:save_cpo

let g:loaded_dbui = 1
