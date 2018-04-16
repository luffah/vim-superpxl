
runtime syntax/pxlcolors.vim
syn include @vimIncl syntax/vim.vim
syn region tmpVarBlock start="{{"ms=s+2 end="}}"me=e-2 contains=@vimIncl display keepend extend
set commentstring="%s

hi IndentGuidesOdd  guibg=NONE ctermbg=0

hi IndentGuidesEven guibg=NONE ctermbg=0

