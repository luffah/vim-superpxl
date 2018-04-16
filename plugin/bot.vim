if get(g:,"render_dj_set_command_DjPlayAnim", 0)
  command! -nargs=1 -complete=file DjPlayAnim call render#Dj_playAnimation(<q-args>)
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

function! bot#fill(x,y,w,h,color)
  let l:blank_line=repeat(a:color, a:w)
  let l:blank=repeat([l:blank_line], a:h)
  call bot#pasteSprite(a:x,a:y,a:w,a:h,l:blank)
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


function! bot#pasteSprite(x,y,w,h,lines)
  let l:bglines = getline(a:y+1, a:y+a:h)
  for l:i in range(a:h)
    let l:cur=a:lines[l:i]
    let l:line=split(l:bglines[l:i],'\zs')
    " (assert a:x+l:c >= 0)
    for l:c in range((a:x<0?-a:x:0),len(l:cur)-1)
      if l:cur[l:c] != ' '
        let l:line[l:c+a:x]=l:cur[l:c]
      endif
    endfor
    let l:bglines[l:i]=join(l:line,'')
  endfor
  call setline(a:y+1, l:bglines)
endfu

function! bot#newSprite(lines,offset)
  let l:obj={'place':function("s:placeSprite"), 'paste':function('s:pasteSprite'),'changePic':function("s:changeSpritePic"), 'clear': function("s:clearSprite"), 'placeBase': function("s:placeSpriteBase")}
  let s:last_bg=getline(0,line('$'))
  let l:obj.lines=a:lines
  let [l:obj.w, l:obj.h] = bot#getSpriteSize(a:lines)
  let l:obj.offset=a:offset
  return l:obj
endfunction

let s:last_bg=[]
function! s:clearSprite() dict
  if has_key(self, 'x')
    let l:max_y=self.y+self.h-1
    let l:prev_bglines = b:last_bg[ self.y : l:max_y ]
    let l:bglines = getline(self.y+1, l:max_y+1)
    for l:i in range(self.h)
      let l:cur=self.lines[l:i]
      let l:line=split(l:bglines[l:i],'\zs')
      " (assert a:x+l:c >= 0)
      for l:c in range((self.x<0?-self.x:0),len(l:cur)-1)
        if l:cur[l:c] != ' '
          let l:line[l:c+self.x]=l:prev_bglines[l:i][l:c+self.x]
        endif
      endfor
      let l:bglines[l:i]=join(l:line,'')
    endfor
    call setline(self.y+1, l:bglines)
  endif
endfu

function! s:placeSprite(x,y) dict
  call self.clear()
  let b:last_bg=getline(0,line('$'))
  call bot#pasteSprite(a:x+self.offset,a:y,self.w,self.h,self.lines)
  let self.x=a:x+self.offset
  let self.y=a:y
endfunction

function! s:pasteSprite(x,y) dict
  call bot#pasteSprite(a:x+self.offset,a:y,self.w,self.h,self.lines)
endfunction

function! s:placeSpriteBase(x,y) dict
  call self.clear()
  let b:last_bg=getline(0,line('$'))
  call bot#pasteSprite(a:x+self.offset,a:y-self.h,self.w,self.h,self.lines)
  let self.x=a:x+self.offset
  let self.y=a:y-self.h
endfunction

function! s:changeSpritePic(lines) dict
  call self.clear()
  let b:last_bg=getline(0,line('$'))
  let self.lines=a:lines
  let [self.w, self.h] = bot#getSpriteSize(a:lines)
  call bot#pasteSprite(self.x,self.y,self.w,self.h,self.lines)
endfunction


""" bot part
if !(exists('g:bot_activate') && g:bot_activate)
    finish
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

fu! bot#BackupSearch()
  " Set local settings for search
  let b:hlsearch=&hlsearch
  let b:prevsearch=getreg('/')
  set nohlsearch
endfu

fu! bot#RestoreSearch()
  let &hlsearch=b:hlsearch
  silent! exe '/'.b:prevsearch
endfu

fu! bot#ShowRenderedFile(file, renderer)
  if filereadable(a:file)
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
    exe join(filter(l:post_process_lines,{idx, val -> val !~ '^\s*"'}),"\n")
  endif
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


