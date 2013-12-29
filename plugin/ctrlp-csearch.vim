" File: plugin/ctrlp-csearch.vim
" Description: a vim ctrlp plugin for search
" Author: Tom MacWright
" License: CC0

command! -nargs=? CtrlPCSearch call ctrlp#csearch#csearch(<q-args>)
