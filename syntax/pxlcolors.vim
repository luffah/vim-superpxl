syn case match
if !exists('g:pxl_colormap')
   exe 'so '.expand('<sfile>:p:h:h') . '/autoload/pixelcolormap.vim'
endif

fu! s:regPix(name,w,color,num,guitext,termtext)
  exe 'syn match '.a:name.a:w.' /'.a:w.'\C\.*/'
  exe 'syn match '.a:name.'BG'.a:w.'in /.*/ contained'
  exe 'syn region '.a:name.'BG'.a:w
        \.' matchgroup='.a:name.a:w
        \.' start=/'.a:w.'\.*\\/'
        \.' end=/\\\.*/re=s contains='.a:name.'BG'.a:w.'in excludenl keepend extend'
  exe 'hi '.a:name.a:w
        \.' guibg='.a:color.' guifg='.a:color
        \.' ctermfg='.a:num.' ctermbg='.a:num 
  exe 'hi '.a:name.'BG'.a:w.'in'
        \.' guibg='.a:color.' ctermbg='.a:num
        \.' guifg='.a:guitext.' ctermfg='.a:termtext
endfu

for s:i in keys(g:pxl_colormap)
  let s:colo=g:pxl_colormap[s:i]
  cal s:regPix('PixelArt',s:i,s:colo[0],s:colo[1],s:colo[3],s:colo[4])
endfor

syn match textBlock /[^0-9A-F ]\(\w\+\s\)\+/ display keepend
hi def link textBlock Normal
