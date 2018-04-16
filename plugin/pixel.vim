" nmap \fR :Mirror<CR>
"  symbol -> guicolor, termcolor, hexAABBGGRR, guitext, termtext
let s:AsciiMirrorTr={
      \'/' : '\',
      \'\' : '/',
      \'(' : ')',
      \')' : '(',
      \'[' : ']',
      \']' : '[',
      \'{' : '}',
      \'}' : '{',
      \'<' : '>',
      \'>' : '<',
      \',' : '.',
      \'p' : 'q',
      \}

fu! s:LineColorsUnFill(line,dict)
  let l:ret=split(a:line, '\zs')
  let l:magic=get(a:dict,'magic','.')
  let l:prev=l:magic
  for l:i in range(len(l:ret))
    let l:ch=l:ret[l:i]
    if l:ch != l:magic
      if l:ch == l:prev
        let ret[l:i] = l:magic
      endif
      let l:prev=l:ch
    endif
  endfor
  return join(l:ret, '')
endfu

fu! s:LineColorsReFill(line,dict)
  let l:ret=split(a:line, '\zs')
  let l:magic=get(a:dict,'magic','.')
  let l:prev=l:magic
  for l:i in range(len(l:ret))
    let l:ch=l:ret[l:i]
    if l:ch == l:magic
      let l:ret[l:i]=l:prev
    else
      let l:prev = l:ch
    endif
  endfor
  return join(l:ret, '')
endfu

fu! s:MirrorFun(line,dict)
  let l:ret=reverse(split(a:line, '\zs'))
  if !empty(a:dict)
    for l:i in range(len(l:ret))
      let l:ch=l:ret[l:i]
      let l:ret[l:i]=get(a:dict,l:ch,l:ch)
    endfor
  endif
  return join(l:ret, '')
endfu

fu! s:IterL(lnu,dict,linefu)
  let l:line=getline(a:lnu)
  exe 'let l:line='.a:linefu.'(l:line,a:dict)'
  call setline(a:lnu, l:line)
endfu

fu! s:IterV(lnu,startcol,endcol,dict,linefu)
  let l:line=getline(a:lnu)
  let l:linepart=strpart(l:line, a:startcol, a:endcol-a:startcol)
  exe 'let l:linepartch='.a:linefu."(l:linepart, a:dict)"
  let l:line=strpart(l:line,0,a:startcol)
        \.l:linepartch
        \.strpart(l:line,a:endcol)
  call setline(a:lnu, l:line)
endfu

fu! s:Iter(linefu,start,end, dict)
  norm gv
  let l:mode=mode()
  if l:mode==#"V"
    for i in range(a:start,a:end)
      cal s:IterL(i,a:dict,a:linefu)
    endfor
  elseif l:mode==#"v"
    let l:colmin=min([col('.'),col('v')])-1
    let l:colmax=max([col('.'),col('v')])
    cal s:IterV(a:start,l:colmin,l:colmax,a:dict,a:linefu)
    for i in range(a:start+1,a:end-1)
      cal s:IterL(i,a:dict,a:linefu)
    endfor
    cal s:IterV(a:end,l:colmin,l:colmax,a:dict,a:linefu)
  elseif l:mode==?""
    let l:colmin=min([col('.'),col('v')])-1
    let l:colmax=max([col('.'),col('v')])
    for i in range(a:start,a:end)
      cal s:IterV(i,l:colmin,l:colmax,a:dict,a:linefu)
    endfor
  endif
endfu



if has('python3')
  let s:pyfile = 'py3file'
  let s:python = 'python3'
elseif has('python')
  let s:pyfile = 'pyfile'
  let s:python = 'python'
endif

if exists('s:python')
  let s:script_path = expand('<sfile>:p:h') . '/pixelpng.py'
  execute(s:pyfile) s:script_path

  if !exists('g:pxl_colormap')
     exe 'so '.expand('<sfile>:p:h:h') . '/autoload/pixelcolormap.vim'
  endif

  fu! pixel#ExportBufferToPNG(preserve_ratio,fname)
    if len(a:fname) > 0
      let l:fname=a:fname
    else
      let l:fname=bufname('%')
    endif
    if l:fname !~ '\.png$'
      let l:fname .= '.png'
    endif

    if s:python == 'python3'
    python3 << _EOF_
import vim
factor = 1 + int(vim.eval('a:preserve_ratio'))
fname = vim.eval('l:fname')
b = vim.current.buffer
colormap = {k: tuple(map(lambda a: int(a), v[2])) for k, v in vim.eval('g:pxl_colormap').items()}
export_as_png(b,fname,colormap,factor)
_EOF_
    else
    python << _EOF_
import vim
factor = 1 + int(vim.eval('a:preserve_ratio'))
fname = vim.eval('l:fname')
b = vim.current.buffer
colormap = {k: tuple(map(lambda a: int(a), v[2])) for k, v in vim.eval('g:pxl_colormap').items()}
export_as_png(b,fname,colormap,factor)
_EOF_
    endif
    return l:fname
  endfu

 fu! pixel#ImportPNG(preserve_ratio,maxwidth,png,...)
    let l:method="nearest_color_hsl"
    if len(a:000)>0
      let l:method=a:000[0]
    endif
    if s:python == 'python3'
    python3 << _EOF_
import vim
b = vim.current.buffer
fpath = vim.eval("a:png")
limit = vim.eval("a:png")
factor = 1 + int(vim.eval('a:preserve_ratio'))
maxwidth = int(vim.eval('a:maxwidth'))
method = vim.eval('l:method')
if method == "noauto":
  b.vars['_import_png_pxl_lines']=import_png(fpath,maxwidth,trpix2chr,COLORTOCHR,factor)
else:
  func=globals()[method]
  colormap = {k: tuple(map(lambda a: int(a), v[2])) for k, v in vim.eval('g:pxl_colormap').items()}
  b.vars['_import_png_pxl_lines']=import_png(fpath,maxwidth,func, colormap,factor)
_EOF_
    else
    python << _EOF_
b = vim.current.buffer
fpath = vim.eval("a:png")
factor = 1 + int(vim.eval('a:preserve_ratio'))
maxwidth = int(vim.eval('a:maxwidth'))
method = vim.eval('l:method')
if method == "noauto":
  b.vars['_import_png_pxl_lines']=import_png(fpath,maxwidth,trpix2chr,COLORTOCHR,factor)
else:
  func=globals()[method]
  colormap = {k: tuple(map(lambda a: int(a), v[2])) for k, v in vim.eval('g:pxl_colormap').items()}
  b.vars['_import_png_pxl_lines']=import_png(fpath,maxwidth,func, colormap,factor)
_EOF_
    endif
    let l:ret=b:_import_png_pxl_lines
    call remove(b:,'_import_png_pxl_lines')
    return l:ret
  endfu

  "" Completion function for commands
  function! s:_CompletePng(A,L,P)
    if a:A =~ '/$'
      let l:file=""
      let l:dir=a:A
    else
      let l:path=split(a:A,'/')
      if a:A =~ '^/'
        let l:file=remove(l:path,-1)
        let l:dir="/".(join(l:path,"/"))
      elseif a:A =~ '^~/'
        let l:file=remove(l:path,-1)
        let l:dir=join(l:path,"/")
      else
        let l:dir=getcwd()
        let l:file=a:A
      endif
    endif
    return filter(map(globpath(l:dir, l:file.'*\c', 1, 1),
          \'v:val.(isdirectory(v:val)?"/":"")'),
          \'v:val =~ "\\(\\.png\\|\\.jpeg\\|\\.gif\\|\\.jpg\\|/\\)\\c$"')
  endfunction
  if exists('g:png_editor')
    command! -bar -complete=file -nargs=? ExportEditPng call system(g:png_editor.' '.pixel#ExportBufferToPNG(1,<q-args>).'&')
  endif
  if has('mac')
    command! -bar -complete=file -nargs=? ExportOptnPng call system('open '.pixel#ExportBufferToPNG(1,<q-args>).'&')
  elseif has('win32')
    command! -bar -complete=file -nargs=? ExportOpenPng call system(pixel#ExportBufferToPNG(1,<q-args>).'&')
  else 
    command! -bar -complete=file -nargs=? ExportOpenPng call system('xdg-open '.pixel#ExportBufferToPNG(1,<q-args>).'&')
  endif
  command! -bar -complete=file -nargs=? ExportToPng exe 'echo "Saved as '.pixel#ExportBufferToPNG(1,<q-args>).'"'
  
  command! -bar -complete=customlist,<SID>_CompletePng -nargs=+ ImportPng
        \ tabnew | set ft=pxl |
        \ cal setline(1,pixel#ImportPNG(1,get(g:,'pxl_image_maxwidth',399),<f-args>))
  command! -bar -complete=customlist,<SID>_CompletePng -nargs=+ ImportPngFitted
        \ tabnew | set ft=pxl |
        \ cal setline(1,pixel#ImportPNG(1,get(g:,'pxl_image_maxwidth',winwidth('%')),<f-args>))
  command! -bar -complete=customlist,<SID>_CompletePng -nargs=+ ImportPngComplete
        \ tabnew | set ft=pxl |
        \ cal setline(1,pixel#ImportPNG(0,get(g:,'pxl_image_maxwidth',399),<f-args>))
endif

if has('gui')
function! s:chZoom(nb)
  let s:guifont=&guifont
  exe 'set guifont='.substitute(substitute(s:guifont,' \d*$',' '.a:nb,''),' ','\\ ','g')
  redraw
endfu
function! s:resetZoom()
  exe 'set guifont='.substitute(s:guifont,' ','\\ ','g')
  redraw
endfu
function! s:bestZoom()
  let s:guifont=&guifont
  let l:maxw=max(map(getline(0,line('$')),'len(v:val)'))
  let l:w=winwidth('%')
  let l:z=12
  exe 'set guifont='.substitute(substitute(s:guifont,' \d*$',' '.l:z,''),' ','\\ ','g')
  while l:w<l:maxw
    let l:z-=1
    exe 'set guifont='.substitute(substitute(s:guifont,' \d*$',' '.l:z,''),' ','\\ ','g')
    let l:w=winwidth('%')
  endwhile
  redraw
endfu
command! -bar -nargs=1 TmpZoom  cal s:chZoom(<args>) | sleep 2 | cal s:resetZoom()
command! -bar ZoomReset  cal s:resetZoom()
command! -bar -nargs=1 Zoom  cal s:chZoom(<args>)
command! -bar ZoomFitToWindow  cal s:bestZoom()
command! -bar TmpZoomFitToWindow  cal s:bestZoom() | sleep 2 | cal s:resetZoom()
endif

command! -bar -range AsciiMirror cal s:Iter('s:MirrorFun',<line1>,<line2>, s:AsciiMirrorTr)
command! -bar -range CharMirror  cal s:Iter('s:MirrorFun', <line1>,<line2>, {})
command! -bar -range CharRefill  cal s:Iter('s:LineColorsReFill', <line1>,<line2>, {'magic':'.'})
command! -bar -range CharUnfill  cal s:Iter('s:LineColorsUnFill', <line1>,<line2>, {'magic':'.'})
command! -bar -range=% Reverse <line1>,<line2>g/^/m<line1>-1

