if version < 600
  syntax clear
"elseif exists("b:current_syntax")
  "finish
endif

runtime syntax/pxlcolors.vim
syn include @vimIncl syntax/vim.vim
syn region tmpVarBlock start="{{"ms=s+2 end="}}"me=e-2 contains=@vimIncl display keepend extend
set commentstring="%s
setlocal nowrap

hi IndentGuidesOdd  guibg=NONE ctermbg=0

hi IndentGuidesEven guibg=NONE ctermbg=0

syn sync fromstart
"let b:current_syntax = "zim"
