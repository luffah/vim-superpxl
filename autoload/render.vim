"=======================================================
" File:       render.vim
" Maintainer: Luffah <luffah@runbox.com>
" Created: 25.03.2017
" Last Change: 29.03.2017 - 14:29:56
" License: Distributed under the same terms as Vim itself
" Features:
"   * Render for django-like vim templates
" Usage:
"   let updater=render#Dj(pos,tpl_as_table)
"   call render#Dj_update(updater)
"=======================================================
if exists('g:loaded_dj_render_plugin') || &compatible
    "finish
endif
let g:loaded_dj_render_plugin = 1

let g:render_dj_enable_preprocessing = get(g:,
      \'render_dj_enable_preprocessing',0)

let g:render_dj_enable_systematic_postprocessing = get(g:,
      \'render_dj_enable_systematic_postprocessing',0)

fu! render#Dj(pos,tpl,...)
  let l:ret=[]
  let l:contains_extra_param=(len(a:000)>0)
  let l:updatable_index=[a:pos]
  let l:i=0
  let l:comment=0
  let l:block_comment=0
  let l:ignore_lines=0
  let l:substitutes=[]
  let s:dj_last_pass_ignored_lines=[]
  for l:l in a:tpl
    for l:v in l:substitutes
      let l:l=substitute(l:l,l:v[0],l:v[1],l:v[2])
    endfor
    if (match(l:l, '^"\?{{')==0)
      let l:ignore_lines=1
      continue
    elseif l:ignore_lines
      if (match(l:l, '^"\?}}')==0)
        let l:ignore_lines=0
      else
        call add(s:dj_last_pass_ignored_lines, l:l)
      endif
      continue
    endif
    let l:comment=(match(l:l, '\s*{%')==0)
    if !l:comment
      if match(l:l, '\s*{#')==0
        let l:block_comment=1
      endif
      if l:block_comment
        let l:comment=1
        if match(l:l, '#}')
          let l:block_comment=0
        endif
      endif
    endif
    if !l:comment
      if len(s:dj_last_pass_ignored_lines) > 0
        let l:newly_ignored=[]
        let l:preprocessing=join(
              \filter(
                \s:dj_last_pass_ignored_lines
                \,'v:val =~ ''^\s*s\(.\).*\1.*\1g\?\s*\(".*\)\?''')
            \,"\n")
        for l:il in s:dj_last_pass_ignored_lines
          if l:il =~ '^\s*s\(.\).*\1.*\1g\?\s*\(".*\)\?'
            let l:sep=l:il[match(l:il,'s')+1]
            let l:split=split(l:il." ",l:sep)
            call add(l:substitutes,l:split[1:])
          else
            call add(l:newly_ignored,l:ll)
          endif
        endfor

        let  s:dj_last_pass_ignored_lines=l:newly_ignored
      endif
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
    endif
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

fu! render#Dj_getIgnoredLines()
  return s:dj_last_pass_ignored_lines
endfu

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
  let b:updater=render#Dj(1,readfile(a:file))
  let l:_post_process_lines=render#Dj_getIgnoredLines()
  exe 'set ft='.split(a:file,'\.')[-1]
  exe 'resize '.line('$')
  redraw
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

fu! render#Dj_update(up)
  let l:offset = a:up[0] -1
  if l:offset >= 0
    for l:update in a:up[1:]
      exe 'let l:txt_rdr='.l:update[2]
      cal setline(l:offset+l:update[0],l:update[1].l:txt_rdr.l:update[3])
    endfor
  endif
endfu
