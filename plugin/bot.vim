if get(g:,"superpxl_set_command_StartGameDj", 0)
  command! -nargs=1 -complete=file StartGameDj call render#Dj_playAnimation(<q-args>)
endif

" Bot api shall be usable even if bot is not used
let s:prev_crono=reltime()
let s:prev_random=0
fu! bot#getRandom(val)
  let l:timediff=reltime(s:prev_crono)
  let s:random=l:timediff[1]
  if a:val==0
    return 0
  endif
  let l:new_rand = s:random%a:val
  if s:prev_random == l:new_rand
     call bot#getRandom(a:val)
  else
     let s:prev_random=s:random%a:val
  endif
  return s:prev_random
endfu
fu! bot#getRandom2(val)
  let l:timediff=reltime(s:prev_crono)
  let s:random=l:timediff[1]*l:timediff[0]
  if a:val==0
    return 0
  endif
  let l:new_rand = s:random%a:val
  let s:prev_random=s:random%a:val
  return s:prev_random
endfu

fu! bot#getCharSync(timebase,retries)
  let l:c=0
  exe 'sleep '.a:timebase.'m'
  while l:c < a:retries
     let l:gchar=getchar(0)
     if !empty(l:gchar)
       return l:gchar
     endif
     let l:c+=1
     exe 'sleep '.a:timebase.'m'
  endwhile
  return
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
    if ((a:x + a:w < 0) || (a:y + a:h < 0) || (a:y > l:screenh))
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
      let l:cur=split(a:lines[l:i+l:decy],'\zs')
      if len(l:cur) + l:decx > 0
        " the sprite part shall be in the image
        let l:line=split(l:bglines[l:i],'\zs')
        if len(l:line)<a:x
          "the line end is before x coord -> just append
          let l:bglines[l:i].=repeat(' ',a:x-len(l:line)).join(l:cur,'')
        else
          let l:suf=''
          for l:c in range(l:decx,len(l:cur)-1)
            " here we add the sprite part char by char to the line
            if (l:c + a:x) >= len(l:line)
              " if the char is space (=null),  only append
              let l:suf.=l:cur[l:c]
            elseif l:cur[l:c] != ' '
              " if the char is not space (= not null), modify existing
              let l:line[l:c+a:x]=l:cur[l:c]
            endif
            " if l:cur[l:c] != ' '
            "   " if the char is not space (= not null)
            "   if (l:c + a:x) <= len(l:line)
            "     let l:line[l:c+a:x]=l:cur[l:c]
            "   else  
            "     let l:suf.=l:cur[l:c]
            "   endif
            " elseif (l:c + a:x) >= len(l:line)
            "     let l:suf.=' '
            " endif
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

" TOFIX: include offset in computing
function! s:collide(sprtb) dict
  let l:ax=self.x+self.offset
  let l:bx=a:sprtb.x+a:sprtb.offset
  " if (self.x<=(a:sprtb.x+a:sprtb.w) && a:sprtb.x<=(self.x+self.w)) && (self.y<=(a:sprtb.y+a:sprtb.h) && a:sprtb.y<=(self.y+self.h)) 
  if (l:ax<=(l:bx+a:sprtb.w) && l:bx<=(l:ax+self.w)) && (self.y<=(a:sprtb.y+a:sprtb.h) && a:sprtb.y<=(self.y+self.h)) 
      let l:ma=s:get_collision_matrix(self)
      let l:mb=s:get_collision_matrix(a:sprtb)
      return s:is_colliding(l:ma,l:mb)
  endif
  return 0
endfu

function! s:equilibre(lines,max)
  for l:i in range(len(a:lines))
     let l:_len=len(a:lines[l:i])
     let a:lines[l:i].= repeat(' ',a:max - l:_len)
  endfor
  return a:lines
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
  let [l:obj.w, l:obj.h] = bot#getSpriteSize(a:lines)
  let l:obj.lines=s:equilibre(a:lines,l:obj.w)
  let l:obj.train=[]
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

fu! bot#getSpriteImages(pattern)
  let l:sprites={}
  let l:name=''
  let l:start=0
  for l:i in range(line('$'))
    let l:l=getline(l:i)
    if l:l =~ a:pattern
      if len(l:name)
        let l:sprites[l:name]=getline(l:start,l:i-1)
      endif
      let l:name = substitute(l:l,a:pattern,'\1','')
      let l:start = l:i + 1
    endif
  endfor
  let l:sprites[l:name]=getline(l:start,line('$'))
  return l:sprites
endfu

""" bot part
if !(exists('g:superpxl_bot_activate') && g:superpxl_bot_activate)
    finish
endif
let s:path=expand('<sfile>:p:h:h')
let g:bot_time_interval=get(g:,'bot_time_interval',60*30)
" Default is a simple bot that shows messages rendered in a template
" using Dj_render (django like template renderer for vim)
let g:bot_initialization_done=0

let g:bot_initialization_path=s:path.'/doc/samples/pxl_tpl/'
let g:bot_initialization=get(g:,'bot_initialization','call bot#PreparePics("'.g:bot_initialization_path.'",".pxl")')

let g:bot_instruction=get(g:,'bot_instruction','call bot#ShowRandomPic("rightbelow split | enew | call render#Dj_playAnimation(a:file)")')
  

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
  call bot#RenderFile(
        \s:vivi_templates[bot#getRandom(s:vivi_random_range)],
        \a:renderer)
endfu

fu! bot#RenderFile(file, renderer)
  if filereadable(a:file)
    exe a:renderer  
  endif
  " call getchar()
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
  augroup superpxl_bot
    au!
    au CmdwinLeave,CmdUndefined,InsertChange,InsertLeave,VimResized *
          \ cal <SID>CheckTime()
  augroup END
catch
  echo "Bot initialization fails. Bot is disabled."
  unlet g:bot_instruction
endtry


