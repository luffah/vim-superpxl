if get(g:,"superpxl_set_command_StartGameDj", 0)
  command! -nargs=1 -complete=file StartGameDj call render#Dj_playAnimation(<q-args>)
endif

" Bot api shall be usable even if bot is not used
let s:prev_crono=reltime()
fu! bot#getRandom(val)
  let l:timediff=reltime(s:prev_crono)
  let s:random=l:timediff[1]
  if a:val==0
    return 0
  endif
  return s:random%a:val
endfu

fu! bot#echof(align,txt,width)
  if a:align=='c'
     let l:ret=repeat(" ",(a:width/2)-(len(a:txt)/2)).a:txt
  elseif a:align=='r'
     let l:ret=repeat(" ",a:width-len(a:txt)).a:txt
  else
     let l:ret=a:txt
  endif
  echo l:ret
endfu

fu! bot#BackupSearch()
  " Set local settings for search
  let s:hlsearch=&hlsearch
  let s:prevsearch=getreg('/')
  set nohlsearch
endfu

fu! bot#RestoreSearch()
  let &hlsearch=s:hlsearch
  silent! exe '/'.s:prevsearch
endfu

function! bot#fill(x,y,w,h,color)
  let l:blank_line=repeat(a:color, a:w)
  let l:blank=repeat([l:blank_line], a:h)
  call bot#pastePixels(a:x,a:y,a:w,a:h,l:blank)
  let b:last_bg=getline(0,line('$'))
endfunction

function! bot#newBackground(w,h,color)
  %delete
  exe 'resize '.a:h
  let l:blank_line=repeat(a:color, a:w)
  let l:blank=repeat([l:blank_line], a:h)
  call append(0,l:blank)
  0
  let b:last_bg=getline(0,line('$'))
endfunction

function! bot#getSpriteSize(lines)
  let l:h=len(a:lines)
  let l:w=0
  for l:i in a:lines
    if len(l:i) > l:w
      let l:w=len(l:i)
    endif
  endfor
  return [l:w, l:h]
endfunction


function! bot#pastePixel(x,y,pix)
  let l:bgline = getline(a:y+1)
  if a:x>=0
    if a:x>len(l:bgline)
      let l:bgline.=repeat(' ',a:x-len(l:bgline)-len(a:pix))
      call setline(a:y+1, l:bgline . a:pix)
    else
      let l:line=split(l:bgline,'\zs')
      for l:c in range(len(a:pix))
        if a:pix[l:c] != ' '
          let l:line[l:c+a:x]=a:pix[l:c]
        endif
      endfor
      call setline(a:y+1, join(l:line,''))
    endif
  endif
endfu

function! bot#pastePixels(x,y,w,h,lines)
    let l:screenh=line('$')
    " if pixels are out of scope, do nothing
    if (a:x + a:w < 0) || (a:y + a:h < 0) || (a:y > l:screenh)
      return
    endif
    " offset modifiers for the case pixel set is partially out of the screen
    let l:decx=a:x<0?-a:x:0
    let l:decy=a:y<0?-a:y:0
   
    " number of pixel lines that are visible
    let l:nbli=a:h-l:decy
    " numbers of pixel lines outide the screen (bottom)
    let l:outofy = a:y + a:h - l:screenh
    
    if l:outofy > 0
      let l:nbli-=l:outofy
    endif

    let l:bglines = getline(a:y+l:decy+1, a:y+l:decy+l:nbli)
    
    for l:i in range(l:nbli)
      let l:cur=a:lines[l:i+l:decy]
      if len(l:cur) > l:decx && len(l:bglines[l:i]) > 0
        if len(l:bglines[l:i])<a:x
          let l:bglines[l:i].=repeat(' ',a:x-len(l:bglines[l:i])-1).a:x
        else
          let l:suf=''
          let l:line=split(l:bglines[l:i],'\zs')
          for l:c in range(l:decx,len(l:cur)-1)
            if l:cur[l:c] != ' '
              if len(l:line)>=(l:c + a:x)
                let l:line[l:c+a:x]=l:cur[l:c]
              else  
                let l:suf.=l:cur[l:c]
              endif
            endif
          endfor
          let l:bglines[l:i]=join(l:line,'').l:suf
        endif
      endif
    endfor
    call setline(a:y+l:decy+1, l:bglines)
endfu

function! s:clearSprite() dict
    let l:screenh=line('$')
    " if pixels are out of scope, do nothing
    if has_key(self, 'x') && (self.x + self.w >= 0) && (self.y + self.h >= 0) && (self.y < l:screenh)
      " offset modifiers for the case pixel set is partially out of the screen
      let l:decx=self.x<0?-self.x:0
      let l:decy=self.y<0?-self.y:0
      " number of pixel lines that are visible
      let l:nbli=self.h-l:decy
      " numbers of pixel lines outide the screen (bottom)
      let l:outofy = self.y + self.h - l:screenh

      if l:outofy > 0
        let l:nbli-=l:outofy
      endif

      let l:bglines = getline(self.y+l:decy+1, self.y+l:decy+l:nbli)
      let l:prev_bglines = b:last_bg[ self.y+l:decy : self.y+self.h-1 ]

      for l:i in range(l:nbli)
        let l:cur=self.lines[l:i+l:decy]
        if len(l:cur) > l:decx && len(l:bglines[l:i]) > 0
          let l:line=split(l:bglines[l:i],'\zs')
          for l:c in range((self.x<0?-self.x:0),len(l:cur)-1)
            if l:cur[l:c] != ' '
              let l:line[l:c+self.x]=l:prev_bglines[l:i][l:c+self.x]
            endif
          endfor
          let l:bglines[l:i]=join(l:line,'')
        endif
      endfor
      call setline(self.y+l:decy+1, l:bglines)
    endif
endfu

function! s:get_collision_matrix(sprt)
  let l:m={}
  for l:x in range(len(a:sprt.lines))
    let l:line=split(a:sprt.lines[l:x],'\zs')
    for l:y in range(len(l:line))
       if l:line[l:y] != ' ' 
          let l:m[((a:sprt.x+l:x).'-'.(a:sprt.y+l:y))]=1
       endif
    endfor
  endfor
  return l:m
endfu

function! s:is_colliding(ma,mb)
  for l:k in keys(a:ma)
     if has_key(a:mb, l:k)
        return 1
     endif
  endfor
  return 0
endfu

function! s:collide(sprtb) dict
  if (self.x<=(a:sprtb.x+a:sprtb.w) && a:sprtb.x<=(self.x+self.w)) && (self.y<=(a:sprtb.y+a:sprtb.h) && a:sprtb.y<=(self.y+self.h)) 
      let l:ma=s:get_collision_matrix(self)
      let l:mb=s:get_collision_matrix(a:sprtb)
      return s:is_colliding(l:ma,l:mb)
  endif
  return 0
endfu


function! bot#newSprite(lines,offset)
  let l:obj={
        \ 'place':function("s:placeSprite"),
        \ 'paste':function('s:pasteSprite'),
        \ 'changePic':function("s:changeSpritePic"),
        \ 'clear': function("s:clearSprite"),
        \ 'placeBase': function("s:placeSpriteBase"),
        \ 'placeBaseCentered': function("s:placeSpriteBaseCentered"),
        \ 'redraw': function("s:redrawSprite"),
        \ 'collide': function("s:collide")
        \ }
  " let b:before_bg=getline(0,line('$'))
  let b:last_bg=getline(0,line('$'))
  let l:obj.lines=a:lines
  let l:obj.train=[]
  let [l:obj.w, l:obj.h] = bot#getSpriteSize(a:lines)
  let l:obj.offset=a:offset
  return l:obj
endfunction

function! s:placeSprite(x,y,...) dict
  call self.clear()
  " if len(a:000) && a:1 
    " let b:last_bg=getline(0,line('$'))
  " endif
  call bot#pastePixels(a:x+self.offset,a:y,self.w,self.h,self.lines)
  let self.x=a:x+self.offset
  let self.y=a:y
endfunction

function! s:pasteSprite(x,y) dict
  call bot#pastePixels(a:x+self.offset,a:y,self.w,self.h,self.lines)
endfunction

function! s:redrawSprite() dict
  call self.clear()
  call bot#pastePixels(self.x,self.y,self.w,self.h,self.lines)
endfunction

function! s:placeSpriteBase(x,y,...) dict
  call self.clear()
  " if len(a:000) && a:1 
    " let b:last_bg=getline(0,line('$'))
  " endif
  call bot#pastePixels(a:x+self.offset,a:y-self.h,self.w,self.h,self.lines)
  let self.x=a:x+self.offset
  let self.y=a:y-self.h
endfunction

function! s:placeSpriteBaseCentered(x,y,...) dict
  call self.clear()
  call bot#pastePixels(a:x+(self.offset/2)-(self.w/2),a:y-self.h,self.w,self.h,self.lines)
  let self.x=a:x+(self.offset/2)-(self.w/2)
  let self.y=a:y-self.h
endfunction

function! s:changeSpritePic(lines,...) dict
  call self.clear()
  " if len(a:000) && a:1 
     " let b:last_bg=getline(0,line('$'))
  " endif
  let self.lines=a:lines
  let [self.w, self.h] = bot#getSpriteSize(a:lines)
  call bot#pastePixels(self.x,self.y,self.w,self.h,self.lines)
endfunction


""" bot part
if !(exists('g:superpxl_bot_activate') && g:superpxl_bot_activate)
    "finish
endif
let s:path=expand('<sfile>:p:h:h')
let g:bot_time_interval=get(g:,'bot_time_interval',60*30)
" Default is a simple bot that shows messages rendered in a template
" using Dj_render (django like template renderer for vim)
let g:bot_initialization_done=0

let g:bot_initialization_path=s:path.'/doc/samples/pxl_tpl/'
let g:bot_initialization=get(g:,'bot_initialization','call bot#PreparePics("'.g:bot_initialization_path.'",".pxl")')
let g:bot_instruction=get(g:,'bot_instruction','call bot#ShowRandomPic("let b:updater = render#Dj(1,l:lines) | let l:post_process_lines=render#Dj_getIgnoredLines() | let l:lines=[] ")')

exe 'set rtp+='.g:bot_initialization_path


fu! bot#PreparePics(path, ext)
  let s:vivi_templates=[]
  for i in globpath(a:path,'*'.a:ext,0,1)
    call add(s:vivi_templates, i)
  endfor
  let s:vivi_random_range=len(s:vivi_templates)
  if s:vivi_random_range==0
    throw "No pic found."
  endif
endfu

fu! bot#ShowRandomPic(renderer)
  call bot#ShowRenderedFile(
        \s:vivi_templates[bot#getRandom(s:vivi_random_range)],
        \a:renderer)
endfu

fu! bot#ShowRenderedFile(file, renderer)
  if filereadable(a:file)
    cal bot#BackupSearch()
    rightbelow split
    enew
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
    setlocal signcolumn=no
    setlocal regexpengine=1
    setlocal lazyredraw
    setlocal nofoldenable
    let l:post_process_lines=[]
    let l:lines=readfile(a:file)
    exe a:renderer
    call setline(1,l:lines)
    exe 'set ft='.split(a:file,'\.')[-1]
    exe 'resize '.line('$')
    redraw
    " execute "setlocal synmaxcol=" . (a:config['width'] - 1)
    if has('gui')
      let l:_back_gui_cursor=&guicursor
      augroup bot_exec
        au!
        execute "autocmd BufEnter,BufLeave,BufUnload,WinLeave <buffer> set guicursor=" . &guicursor
      augroup END
      set guicursor=n:none
    else
      " Hides/restores cursor at the start/end of the game
      augroup bot_exec
        au!
        execute "autocmd BufEnter,BufLeave,BufUnload,WinLeave <buffer> set t_ve=" . &t_ve
        execute "autocmd VimLeave <buffer> set t_ve=" . &t_ve
      augroup END
      setlocal t_ve=
    endif
    let l:_script_lines=filter(l:post_process_lines,{idx, val -> val !~ '^\s*".*'})
    
    try
      let l:i = 0
      while l:i < len(l:_script_lines)
        if l:_script_lines[l:i]=~'^\s*\\\s*'
          let l:_script_lines[l:i-1].=substitute( remove(l:_script_lines,l:i),'^\s*\\\s*','','')
        else
          let l:i+=1
        endif
      endwhile
      exe "function! s:_current_process()\n".join(l:_script_lines,"\n")."\n endfunction"
      call s:_current_process()
    catch
      echo v:exception
      echo " - at - " . v:throwpoint
      if v:throwpoint =~ '.*__current_process, \a\+ \d\+'
        let l:nu=str2nr(substitute(v:throwpoint,'^.*__current_process, \a\+ \(\d\+\)','\1',''))
        if l:nu > 1
          echo l:nu-1.' '.l:_script_lines[l:nu-2]
        endif
        if l:nu > 0
          echo l:nu.' '.l:_script_lines[l:nu-1]
        endif
        echo l:nu+1.' '.l:_script_lines[l:nu]
        if l:nu < len(l:_script_lines)
          echo l:nu+2.' '.l:_script_lines[l:nu+1]
        endif
      endif
      cal bot#RestoreSearch()
    endtry
  endif
  cal bot#RestoreSearch()
  if has('gui')
    exe 'set guicursor='.l:_back_gui_cursor
  endif
endfu

" Bot generic programme
let s:random=0
fu! s:CheckTime()
  let l:timediff=reltime(s:prev_crono)
  let s:random=l:timediff[1]
  if l:timediff[0] >= g:bot_time_interval
    let s:prev_crono=reltime()
    exe g:bot_instruction
  endif
endfu

try
  exe g:bot_initialization
  augroup vivi
    au! VimEnter,BufEnter,TabEnter,CursorHold *
          \ cal <SID>CheckTime()
  augroup END
catch
  echo "Bot initialization fails. Bot is disabled."
  unlet g:bot_instruction
endtry


