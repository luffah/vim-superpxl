" render.vim -- render template for vim script (similar to Django)
" @Author:      luffah (luffah AT runbox com)
" @License:     AGPLv3 (see https://www.gnu.org/licenses/agpl-3.0.txt)
" @Created:     2017-03-25
" @Last Change: 2022-01-22
" @Revision:    2
"
" @Overview
" This renderer is actually very minimalist:
" it supports only 1 variable rendering per line.
" 
" Other functions here can be enough to build interactives animations.
" 
if exists('g:loaded_dj_render_plugin') || &compatible
    "finish
endif
let g:loaded_dj_render_plugin = 1

let g:render_dj_enable_preprocessing = get(g:,
      \'render_dj_enable_preprocessing',0)

let g:render_dj_enable_systematic_postprocessing = get(g:,
      \'render_dj_enable_systematic_postprocessing',0)

" @function render#Dj(pos, tpl_lines)
" Render a list of lines at specified line position,
" and return an index of lines with code for rendering
" updates.
" 
" Details about the returned index:
"  [
"    [ line_nr_to_update, text_begin, computed_part, text_end ]
"    .
"    .
"  ]
"
" In template, you can define:
"    {{ simple_value }}
"    {{ init_value {<<} updated_value }}
"
" Next blocks and comments will be not be rendered :
"
"     {# a simple in line comment #}
"     {# ---- #}
"     {% head %}
"     " totally ignored
"     " may contain code to load with :source %
"     {% end head %}
"     {# ------- #}
"     {% comment %}
"     " totally ignored
"     {% end comment %}
"     {# ----- #}
"     {% subst %}
"     "substitution to run before rendering
"     " it can apply to all lines
"     s/x/y/
"     " or specified ones among rendered content
"     2s/x/y/
"     {% end subst %}
"     {# ----- #}
"     {% code %}
"     " vim script to run on the same buffer that rendered content
"     " you can fetch these with render#Dj_getCodeLines()
"     {% end code %}
"     {# ----- #}
"
"
" Example :
"  let l:updater=render#Dj(1,readfile(a:file))
"  sleep 3
"  call render#Dj_update(l:updater)
fu! render#Dj(pos,tpl,...)
  let l:ret=[]
  let l:contains_extra_param=(len(a:000)>0)
  let l:updatable_index=[a:pos]
  let l:i=0
  let l:ignore_lines=0
  let l:by_line_substitutes={}
  let l:all_line_substitutes=[]
  let s:dj_last_pass_ignored_lines=[]
  for l:l in a:tpl
    let l:match_tag=(l:l[-2:] == '%}' && (l:l[0:1] == '{%' || l:l[0:2] == '"{%'))
    if l:match_tag
      if l:l[0] == '"'
        let l:l = l:l[1:]
      endif
      if (l:ignore_lines)
        if (
              \ (l:ignore_lines == 1 && l:l[3:10] == 'end code') ||
              \ (l:ignore_lines == 2 && l:l[3:13] == 'end comment') ||
              \ (l:ignore_lines == 3 && l:l[3:10] == 'end head') ||
              \ (l:ignore_lines == 4 && l:l[3:11] == 'end subst')
              \ )
          let ignore_lines = 0
        endif
      elseif (l:l[3:6] == 'code')
        let l:ignore_lines=1
      elseif (l:l[3:9] == 'comment')
        let l:ignore_lines=2
      elseif (l:l[3:6] == 'head')
        let l:ignore_lines=3
      elseif (l:l[3:7] == 'subst')
        let l:ignore_lines=4
      endif
      continue
    elseif (l:ignore_lines)
      if l:ignore_lines == 1
        call add(s:dj_last_pass_ignored_lines, l:l)
      elseif l:ignore_lines == 4 && l:l =~ '^\d*s\(.\).*\1.*\1g\?\s*\(".*\)\?'
        if l:l[0] != 's'
          let l:lnr = split(l:l, 's')[0]
          let l:l = l:l[len(l:lnr):]
          let l:sep = l:l[1]
          let l:split = split(l:l." ",l:sep)
          let l:lnr = str2nr(l:lnr) - 1
          if !has_key(l:by_line_substitutes, l:lnr)
            let l:by_line_substitutes[l:lnr] = []
          endif
          call add(l:by_line_substitutes[l:lnr], l:split[1:])
        else
          let l:sep = l:l[1]
          let l:split = split(l:l." ",l:sep)
          call add(l:all_line_substitutes,l:split[1:])
        endif
      endif
      " let l:i+=1
      continue
    elseif match(l:l, '\s*{\#.*\#}')==0  " line comment
      " let l:i+=1
      continue
    endif
    for l:v in get(l:by_line_substitutes, l:i ,[])
      let l:l=substitute(l:l,l:v[0],l:v[1],l:v[2])
    endfor
    for l:v in l:all_line_substitutes
      let l:l=substitute(l:l,l:v[0],l:v[1],l:v[2])
    endfor
    let l:pos_var=match(l:l, '{{')
    while l:pos_var >=0
      let l:pos_updatable=match(l:l,'{<<}',l:pos_var)
      let l:pos_var_end=match(l:l,'}}',l:pos_var)
      let l:txt_begin=strpart(l:l,0,l:pos_var)
      let l:txt_end=strpart(l:l,l:pos_var_end+2)
      if l:pos_updatable > 0
        let l:rdr=strpart(l:l,l:pos_var+2,l:pos_updatable-l:pos_var-2)
        cal add(l:updatable_index,
              \[l:i + a:pos
              \,l:txt_begin
              \,strpart(l:l,l:pos_updatable+4,l:pos_var_end-l:pos_updatable-4)
              \,l:txt_end
              \])
      else
        let l:rdr=strpart(l:l,l:pos_var+2,l:pos_var_end-l:pos_var-2)
      endif
      try
        if l:contains_extra_param && (match(l:rdr,'^\s*\d\+\s*$')==0)
          let l:txt_rdr=a:OOO[str2nr(l:rdr)]
        else
          exe 'let l:txt_rdr='.l:rdr
        endif
      catch
        echo l:rdr.' " rendering fails'
        let l:txt_rdr=l:rdr
      endtry
      let l:l=l:txt_begin.l:txt_rdr.l:txt_end
      let l:pos_var=match(l:l, '{{')
    endwhile
    cal add(l:ret, l:l)
    let l:i+=1
  endfor
  if g:render_dj_enable_systematic_postprocessing
    exe join(filter(l:post_process_lines,'v:val !~ ''^\s*"'''),"\n")
    let s:dj_last_pass_ignored_lines=[]
  endif
  if a:pos > 0
    cal setline(a:pos,l:ret)
    return l:updatable_index
  else
    return l:ret
  endif
endfu

" @function render#Dj_getCodeLines()
" return all lines that are not rendered (usually code to be executed) 
fu! render#Dj_getCodeLines()
  return s:dj_last_pass_ignored_lines
endfu

" @function render#Dj_playAnimation(file)
" Helper that setup current window
" to render animation and execute include code.
"
" Some variables and function will be available :
" - b:updater  which is the index to user with render#Dj_update
" - b:_script_lines  is the list of lines that are executed
" - s:_current_process()  is the main function executed, can be used for
"                         reboot
" 
fu! render#Dj_playAnimation(file,...)
  cal bot#BackupSearch()
  noh
  call clearmatches()
  setlocal undolevels=0
  setlocal nowrap nocursorline nonu
  setlocal buftype=nofile
  setlocal bufhidden=wipe
  setlocal nobuflisted
  setlocal noswapfile
  setlocal nocursorcolumn
  setlocal norelativenumber
  setlocal listchars=
  setlocal laststatus=2
  setlocal fileencodings=utf-8
  setlocal regexpengine=1
  setlocal lazyredraw
  setlocal nofoldenable
  setlocal undolevels=-1
  setlocal statusline=%#NONE#
  %d
  let b:updater=render#Dj(1,readfile(a:file))
  let l:_post_process_lines=render#Dj_getCodeLines()
  exe 'set ft='.split(a:file,'\.')[-1]
  exe 'resize '.line('$')
  redraw!
  " syntax on
  " Hides/restores cursor at the start/end of the game
  let l:guicursor=&guicursor
  let l:t_ve=&t_ve
  setlocal guicursor=n:none
  setlocal t_ve=
  let l:_post_process_lines=filter(l:_post_process_lines,'v:val !~ ''^\s*".*''')

  try
    let l:i = 0
    while l:i < len(l:_post_process_lines)
       if l:_post_process_lines[l:i]=~'^\s*\\\s*'
          let l:_post_process_lines[l:i-1].=substitute( remove(l:_post_process_lines,l:i),'^\s*\\\s*','','')
       else
         let l:i+=1
       endif
    endwhile
    exe "function! s:_current_process()\n".join(l:_post_process_lines,"\n")."\n endfunction"
    let b:_script_lines=l:_post_process_lines
    call s:_current_process()
  catch
    echo v:exception
    echo " - at - " . v:throwpoint
    if v:throwpoint =~ '.*__current_process, \a\+ \d\+'
      let l:nu=str2nr(substitute(v:throwpoint,'^.*__current_process, \a\+ \(\d\+\)','\1',''))
      if l:nu > 1
        echo l:nu-1.' '.b:_script_lines[l:nu-2]
      endif
      if l:nu > 0
        echo l:nu.' '.b:_script_lines[l:nu-1]
      endif
      echo l:nu+1.' '.b:_script_lines[l:nu]
      if l:nu < len(b:_script_lines)
        echo l:nu+2.' '.b:_script_lines[l:nu+1]
      endif
    endif
  endtry
  exe 'setlocal guicursor='.l:guicursor
  exe 'setlocal t_ve='.l:t_ve
  setlocal statusline=
  cal bot#RestoreSearch()
endfu

" @function render#Dj_update(updater)
" update current window with the updater index
" by evaluating the code to render parts
fu! render#Dj_update(up)
  let l:offset = a:up[0] - 1
  if l:offset >= 0
    for l:update in a:up[1:]
      exe 'let l:txt_rdr='.l:update[2]
      cal setline(l:offset+l:update[0],l:update[1].l:txt_rdr.l:update[3])
    endfor
  endif
endfu
