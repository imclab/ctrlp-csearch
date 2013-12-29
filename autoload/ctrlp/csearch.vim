" File: autoload/ctrlp/csearch.vim
" Author: Tom MacWright
" License: CC0

if get(g:, 'loaded_ctrlp_csearch', 0)
  finish
endif
let g:loaded_ctrlp_csearch = 1

let s:saved_cpo = &cpo
set cpo&vim

let s:report_filter_error = get(g:, 'ctrlp_csearch_report_filter_error', 0)
let s:winnr = -1
" }}}

let s:errmsg = ''

" The main variable for this extension.
"
" The values are:
" + the name of the input function (including the brackets and any argument)
" + the name of the action function (only the name)
" + the long and short names to use for the statusline
" + the matching type: line, path, tabs, tabe
"                      |     |     |     |
"                      |     |     |     `- match last tab delimited str
"                      |     |     `- match first tab delimited str
"                      |     `- match full line like file/dir path
"                      `- match full line
call add(g:ctrlp_ext_vars, {
  \ 'init':   'ctrlp#csearch#init(s:query)',
  \ 'accept': 'ctrlp#csearch#accept',
  \ 'lname':  'csearch',
  \ 'sname':  'csh',
  \ 'type':   'line',
  \ 'exit':  'ctrlp#csearch#exit()'
  \ })

function! s:error(msg)
    echohl ErrorMsg | echomsg a:msg | echohl NONE
    let v:errmsg  = a:msg
endfunction

" Provide a list of strings to search in
"
" Return: List
function! ctrlp#csearch#init(q)
  return split(system(printf('csearch "%s"', shellescape(a:q))), '\n')
endfunction

function! ctrlp#csearch#csearch(word)
  let s:winnr = winnr()
  try
    if !empty(a:word)
      let default_input_save = get(g:, 'ctrlp_default_input', '')
      let g:ctrlp_default_input = a:word
    endif

    call ctrlp#init(ctrlp#csearch#id())
  finally
    if exists('default_input_save')
      let g:ctrlp_default_input = default_input_save
    endif
  endtry
endfunction

" The action to perform on the selected string.
"
" Arguments:
"  a:mode   the mode that has been chosen by pressing <cr> <c-v> <c-t> or <c-x>
"           the values are 'e', 'v', 't' and 'h', respectively
"  a:str    the selected string
fu! ctrlp#csearch#accept(mode, str)
	let vals = matchlist(a:str, '^\([^:]\+\):\([^:]\+\)')
	if vals == [] || vals[1] == '' | retu | en
	cal ctrlp#acceptfile(a:mode, vals[1])
	cal cursor(vals[2], 0)
	sil! norm! zvzz
endf

function!ctrlp#csearch#exit()
  if !empty(s:errmsg) | call s:error(s:errmsg) | endif
endfunction

" Give the extension an ID
let s:id = g:ctrlp_builtins + len(g:ctrlp_ext_vars)
" Allow it to be called later
function! ctrlp#csearch#id()
  return s:id
endfunction

let &cpo = s:saved_cpo
unlet s:saved_cpo
