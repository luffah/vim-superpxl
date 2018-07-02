syn case match
if !exists('g:pxl_colormap')
   exe 'so '.expand('<sfile>:p:h:h') . '/autoload/pixelcolormap.vim'
endif

fu! s:regPix(name,w,color,num,guitext,termtext)
  exe 'syn match '.a:name.a:w.' /'.a:w.'\C\.*/'
  exe 'hi '.a:name.a:w
        \.' guibg='.a:color.' guifg='.a:color
        \.' ctermfg='.a:num.' ctermbg='.a:num 
endfu

for s:i in keys(g:pxl_colormap)
  let s:colo=g:pxl_colormap[s:i]
  cal s:regPix('PixelArt',s:i,s:colo[0],s:colo[1],s:colo[3],s:colo[4])
endfor
