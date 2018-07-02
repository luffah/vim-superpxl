"TODO : support multiple char pattern 
let s:palette_rectangle=['┌','─','┐','│','┘','─','└','│']
let s:palette_rectangle_ascii=['.','-','.','|',"'",'-',"'",'|']
let g:superpxl_draw_palettes={}
let s:init_state=0

fu! s:init_palettes()
  let g:superpxl_draw_palettes={
        \'_favorites': get(g:,'superpxl_favorite_palette',[]),
        \'pxl':[ "0","1","2","3","4","5","6","7","8","9","A","B","C","E","D","F"],
        \'bloc':[" ", "░","▒","█","■","▮","■","█"],
        \'rectangle': s:palette_rectangle,
        \'rectangle_connector':["┤","┴","┬","├","┼","╪","╬",],
        \'arrows':["←","↑","→","↓"],
        \'round':["•","●","·","°","￮","ₒ","∅",'™','©','®',],
        \'accents' :['À','Á','Â','Ã','Ä','Å','Æ','Ç','È','É','Ê','Ë','Ё','Ì','Í','Î','İ','Ï','Ї','Ð','Ñ','Ø','Ò','Ó','Ô','Õ','Ö','Ù','Ú','Û','Ü','Ý','Þ','ß','à','á','â','ã','ä','å','æ','¢','ç','è','é','ê','ë','ё','ı','ì','í','î','ï','ї','ð','ñ','∅','ø','ò','ó','ô','õ','ö','ù','ú','û','ü','ý','þ','ÿ','Đ','Ğ','ğ','Œ','œ','Ş','ş','Š','š','Ÿ','Ž','ž',],
        \'sep':['§','¶','†','‡','¨','¸','¿',"´","¯","`","‘","“","’","”",",","„","‼","‿",'‹','›','«','»',],
        \'math':['¦','¤','ƒ','¬','÷','×','∈','−','≈','≠','≡','≤','≥','≪','≫','º','ª','¹','²','³','ⁿ','ˆ','ˉ','˜','±','¼','½','¾','‰','µ','μ','π',],
        \'money':['₧','₮','№','£','¥','€',],
        \}
  let s:init_state=1
endfu
call s:init_palettes()
fu! s:add_extra_extra_palettes()
    if s:init_state==1
     let g:superpxl_draw_palettes['bloc']+=['▀','▁','▂','▃','▄','▅','▆','▇','█','▉','▊','▋','▌','▍','▎','▏','▐','░','▒','▓',]
     let g:superpxl_draw_palettes['rectangle_connector']+=['━','┃','┍','┎','┏','┑','┒','┓','┕','┖','┗','┙','┚','┛','┝','┞','┟','┠','┡','┢','┣','┥','┦','┧','┨','┩','┪','┫','┬','┭','┮','┯','┰','┱','┲','┳','┵','┶','┷','┸','┹','┺','┻','┽','┾','┿','╀','╁','╂','╃','╄','╅','╆','╇','╈','╉','╊','╋','╴','╵','╶','╷','╸','╹','╺','╻','╼','╽','╾','╿']
     let g:superpxl_draw_palettes['music']=["♩","♪","♫","♬","♭","♮","♯","𝄆","𝄇","𝄐","𝄜","𝄞","𝄟","𝄠","𝄡","𝄢","𝄣","𝄤","𝄥","𝄦","𝇐","𝇑","𝄪","𝄴","𝄻","𝄼","𝄽","𝅗𝅥","𝅘𝅥𝅯","𝅘𝅥𝅰","𝅘𝅥𝅱","𝅘𝅥𝅲","𝆒",]
     let g:superpxl_draw_palettes['math']+=['∅','∈','−','⊕','⊖','⊘','⊙','⊚','⊛','⊜',]
     let g:superpxl_draw_palettes['drawmath']=['⎛','⎜','⎝','⎞','⎟',' ','⎠','⎡','⎢','⎣','⎤','⎥','⎦','⌠','⌡','⎧','⎨','⎩','⎪','⎫','⎬','⎭','⎮','⎯','⎰','⎱',]
     let g:superpxl_draw_palettes['electric']=["⑀","⑁","⑂","⑃","⌂","⑄","⏚","⌁","θ","‡"]
     let s:init_state=2
     return 1
   elseif s:init_state==2
     vnew
     setlocal statusline=%#StatusLineNC#
     let s:init_state=3
     set buftype=nowrite
     setlocal noswapfile
     setlocal nobuflisted
     setlocal undolevels=-1
     setlocal nowrap
     au! BufLeave <buffer> let s:init_state=2
     call setline(1,[                          
           \ 'Feel free to copy...⚉⚆⚇⚈☹☺☻⚐⚑    ',
           \ '┌───────────────┐■□▢▣▤▥▦▧▨▩▪▫⚰⚱☠☢☣☸  ',
           \ '│♖ ♘ ♙ ♕ ♔ ♙ ♘ ♖│☚☛☜☝☞☟👊✊✌✋👆👇👉👈',
           \ '│♗ ♗ ♗ ♗ ♗ ♗ ♗ ♗│☖☗☘☙☭☮☯⛭ ☀☁☔⛄    ',
           \ '│♠♡♢♣♤♥♦♧       │⛰ ⛱ ⛶ ⛷ ⛸ ⛹ ⛽⛴  ⛵⛟ ',
           \ '│⚀⚁⚂⚃⚄⚅         │❀⚘❃❁✼☀☃❄☘☕⚡   ',
           \ '│💙💗❤💔💓💘✨💢│❕❔💤💦⁇⁈⁉  ',
           \ '│💕💖           │🕛🕐🕑🕒🕓🕔🕕🕖🕗🕘🕙🕚 ',
           \ '│♝ ♝ ♝ ♝ ♝ ♝ ♝ ♝│🌑🌒🌓🌔🌕🌖🌗🌘       ',
           \ '│♜ ♞ ♟ ♛ ♚ ♟ ♞ ♜│☽☾✁✂✃✄',
           \ '└───────────────┘                         ',
           \ '⭕😄😊😃😉😍😘😚😳😌😁😜😝😒😏😓😔😖',
           \ '😥😰😨😣😢😭😂😲😱😞😠😡😪😷🐱🐭🐮🐵👀',
           \ ])
     nnoremap <buffer> q :bwipe<Cr>
     return 0
   endif
 endfu


let g:superpxl_current_palette=g:superpxl_draw_palettes['pxl']
let g:superpxl_current_brush=''
let s:idxinpalette = 0
let s:paletteidx = 0
let g:superpxl_current_group=' '

fu! superpxl#draw#(palette, idx, ope, ...)
  if a:idx =~ '[-+]\d*'
    let s:idxinpalette+=eval(a:idx)
  else
    let s:idxinpalette=eval(a:idx)
  endif
  let g:superpxl_current_brush=a:palette[ s:idxinpalette ]
  call feedkeys(printf(a:ope,g:superpxl_current_brush)."\<Esc>",'n')
endfu

fu! s:pick(extra)
  let s:paletteidx=line('.')-1
  let g:superpxl_current_palette=map(sort(keys(g:superpxl_draw_palettes)),'g:superpxl_draw_palettes[v:val]')[s:paletteidx]
  call superpxl#draw#(g:superpxl_current_palette, (virtcol('.')-1)/2, a:extra)
  q
endfu

fu! superpxl#draw#select(extra)
  let l:ft=&ft
  exe 'rightbelow '.get(g:,'superpxl_palette_window_height',len(g:superpxl_draw_palettes)).' split | enew'
   " exe 'leftabove '.get(g:,'superpxl_palette_window_height',len(g:superpxl_draw_palettes)).' vnew'
  call setline(1,map(sort(keys(g:superpxl_draw_palettes)),'" ".join(g:superpxl_draw_palettes[v:val]," ")." "'))
  setlocal nowrap 
  setlocal buftype=nofile
  setlocal bufhidden=wipe
  setlocal noswapfile
  setlocal nobuflisted
  setlocal undolevels=-1
  let l:keys=" '.' -> use ; 'a' -> favorite ; "
  if $TERM != 'linux'
    let l:keys.=" 'p' -> more; "
  endif
  let l:keys.="'q' -> quit"
  exe 'setlocal statusline=%#StatusLineNC#'.escape(l:keys,'%" ')
  au! BufLeave <buffer> q
  if len(l:ft)
    exe 'setf '.l:ft
  endif                                                                      
  let l:recall='<bar> call superpxl#draw#select("'.a:extra.'")'
  let l:map='noremap <buffer> '
  let l:pick='call <SID>pick("'.a:extra.'")'
  for l:i in ['<Enter>','<Space>','i','.','r','R', 'I','A','d','D']
    exe l:map.l:i.' :'.l:pick.'<Cr>'
  endfor
  for l:i in ['<Right>','l','e','w','t']
    exe l:map.l:i.' f<Space>'
  endfor
  for l:i in ['<Left>','h','b','W','T','F']
    exe l:map.l:i.' F<Space>'
  endfor
  for l:i in ['a','f']
    exe l:map.l:i.' :'.l:pick.'<bar>let g:superpxl_draw_palettes[''_favorites'']+=[g:superpxl_current_brush]'.l:recall.'<Cr>'
  endfor
  if $TERM != 'linux'
    for l:i in ['p']
      exe l:map.l:i.' :if <SID>add_extra_extra_palettes()<bar>q'.l:recall.'<bar> endif <Cr>'
    endfor
  endif
  exe l:map.' u :q'.l:recall.'<Cr>'
  map <buffer> q :q<Cr>
  call setpos('.', [0, s:paletteidx + 1 , len(join(g:superpxl_current_palette[0:s:idxinpalette]))-1, 0])
  " setlocal undolevels=10
endfu

fu! s:show_help()
   let l:t=[['.',"to repeat coloration (or simply '.')"],
        \['a',"to get next brush in palette"    ],
        \['x',"to get previous brush in palette"],
        \['p',"to select brush in all palettes" ],
        \]
  let l:tv=[['r',"to draw frame around selection"],
        \['+',"to enlarge selection"],
        \['-',"to reduce selection"],
        \]
  echohl WarningMsg
  echo   " # HELP # "
  echohl Title
  echo  " (normal and visual mode) "
  echohl None
  for l:i in l:t
    echohl None
    echo  " Use '"
    echohl String
    echon g:mapleader.l:i[0]
    echohl None
    echon "' ".l:i[1]
  endfor
  echohl Title
  echo  " (visual mode only) "
  echohl None
  for l:i in l:tv
    echohl None
    echo  " Use '"
    echohl String
    echon g:mapleader.l:i[0]
    echohl None
    echon "' ".l:i[1] 
  endfor
  let l:keys=" "
  if get(g:,'superpxl_verbose_status',1)
    let l:keys=" keys:".join(map(l:t,'"%#String#".g:mapleader.v:val[0]."%#None#"'),'/')
    let l:keys.=" vkeys:".join(map(l:tv,'"%#String#".g:mapleader.v:val[0]."%#None#"'),'/')
    let l:keys.=' '
  endif
  setlocal statusline=
  exe 'setlocal statusline=%#None#%{g:superpxl_current_brush}'.escape(l:keys,' ').escape(&statusline,' ')
  echo ""
  echohl Underlined
  echon "Avaible commands : "
  echohl None
  echon "DrawModeHelp, DrawModeExit"
  echo " Let's go ! " 
endfu

fu! s:map_draw_keys()
  map  <buffer> <leader>a :call superpxl#draw#(g:superpxl_current_palette, '+1', "r%s")<Cr>
  map  <buffer> <leader>x :call superpxl#draw#(g:superpxl_current_palette, '-1', "r%s")<Cr>
  map <buffer>  <leader>. :call superpxl#draw#(g:superpxl_current_palette, '+0', "r%s")<Cr>
  map  <buffer> <leader>p :call superpxl#draw#select("r%s")<Cr>
  map  <buffer> <leader>q :DrawModeExit<Cr>
  vmap <buffer>  <leader>a :call superpxl#draw#(g:superpxl_current_palette, '+1', "gvr%s")<Cr>
  vmap <buffer>  <leader>x :call superpxl#draw#(g:superpxl_current_palette, '-1', "gvr%s")<Cr>
  vmap <buffer>  <leader>. :call superpxl#draw#(g:superpxl_current_palette, '+0', "gvr%s")<Cr>
  vmap <buffer>  <leader>p :call superpxl#draw#select("gvr%s")<Cr>
  vmap <buffer>  <leader>r :cal <SID>EncadreSel(g:superpxl_draw_palettes['rectangle'])<Cr>
  vmap <buffer> <expr> <leader>+ (col('.')==col("'>")?"\<Right>O\<Left>O":"\<Left>O\<Right>O").(line('.')==line("'>")?"\<Down>o\<Up>o":"\<Up>o\<Down>o")
  vmap <buffer> <expr> <leader>- (col('.')==col("'<")?"\<Right>O\<Left>O":"\<Left>O\<Right>O").(line('.')==line("'<")?"\<Down>o\<Up>o":"\<Up>o\<Down>o")
endfu

fu! s:unmap_draw_keys()
  unmap  <buffer> <leader>a 
  unmap  <buffer> <leader>x
  unmap  <buffer> <leader>.
  unmap  <buffer> <leader>p
  unmap  <buffer> <leader>q
  vunmap <buffer> <leader>a
  vunmap <buffer> <leader>x
  vunmap <buffer> <leader>.
  vunmap <buffer> <leader>p
  vunmap <buffer> <leader>r
  vunmap <buffer> <leader>+
  vunmap <buffer> <leader>-
endfu

fu! superpxl#draw#i_want_keys_to_draw()
  call s:init_palettes()
  call s:show_help()
  let l:exit_proc='call <SID>unmap_draw_keys()'
  let l:virtualedit=&virtualedit 
  if &virtualedit != 'all'
    setlocal virtualedit=all
    let l:exit_proc.=' | exe "setlocal virtualedit='.l:virtualedit.'"' 
  endif
  call s:map_draw_keys()
  exe 'command! -buffer DrawModeExit '.l:exit_proc.' | delcommand  DrawModeExit | delcommand DrawModeHelp | setlocal statusline='
  command! -buffer DrawModeHelp call <SID>show_help()
endfu

fu! s:sort2num(a,b)
  return (a:a > a:b) ? [a:b, a:a] : [a:a, a:b]
endfu

fu! s:getVisualCoords()
  norm! gv
  let l:l=s:sort2num(line("'<"),line("'>"))
  let l:c=s:sort2num(virtcol("'<"),virtcol("'>"))
  return l:l + l:c 
endfu

fu! s:EncadreSel(rect) range
  let [ l:y, l:y2, l:x,  l:x2 ]=s:getVisualCoords()
  let l:h=(l:y2-l:y)+1
  let l:w=(l:x2-l:x)+1
  let l:sq=[ a:rect[0].repeat(a:rect[1],l:w).a:rect[2] ]
  for l:i in range(l:y,l:y2)
     let l:sq+=[ a:rect[7].repeat(' ',l:w).a:rect[3] ]
  endfor
  let l:sq+=[ a:rect[6].repeat(a:rect[5],l:w).a:rect[4] ]
  cal bot#pastePixels(l:x-2,l:y-2,l:w+2,l:h+2,l:sq)
endfu


" vim: set nowrap:
