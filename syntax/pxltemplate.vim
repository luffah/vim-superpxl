
syn include @pxlIncl syntax/pxlcolors.vim
syn match PixelArtBegin "pxl{" contained
syn match PixelArtEnd "}" contained
syn region PxlTop start=+pxl{+ end=+}+ contains=PixelArtBegin,PixelArtEnd,@pxlIncl keepend extend
hi def link PixelArtBegin Ignore
hi def link PixelArtEnd Ignore

syn include @vimIncl syntax/vim.vim
syn region tmpVarBlock start="{{" end="}}" contains=@vimIncl display keepend extend
