if version < 600
  syntax clear
"elseif exists("b:current_syntax")
  "finish
endif

runtime syntax/pxlcolors.vim
syn include @vimIncl syntax/vim.vim
syn region tmpVarBlock start="{{"ms=s+2 end="}}"me=e-2 contains=@vimIncl display keepend extend
syn match pxlLineStatement "^{% .* %}$" contained
syn region pxlVarBlock start="\"\?{% code .*%}" end="\"\?{% end code %}" contains=@vimIncl,pxlLineStatement display keepend extend
syn region pxlVarBlock start="\"\?{% head .*%}" end="\"\?{% end head %}" contains=@vimIncl,pxlLineStatement keepend extend
syn region pxlVarBlock start="\"\?{% subst\(itute\)\? .*%}" end="\"\?{% end subst\(itute\)\? %}" contains=@vimIncl,pxlLineStatement display keepend extend
syn region pxlBlockComment start="{% comment .*%}" end="{% end comment %}"
syn match pxlLineComment "{# .* #}"
hi def link pxlBlockComment Comment
hi def link pxlLineComment Comment
hi def link pxlLineStatement Question
set commentstring="%s
setlocal nowrap

hi IndentGuidesOdd  guibg=NONE ctermbg=0

hi IndentGuidesEven guibg=NONE ctermbg=0

syn sync fromstart
"let b:current_syntax = "zim"
