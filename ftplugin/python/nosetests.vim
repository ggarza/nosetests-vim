"
" Python filetype plugin for running nosetests
" Language:     Python (ft=python)
" Maintainer:   Vincent Driessen <vincent@datafox.nl>
" Version:      Vim 7 (may work with lower Vim versions, but not tested)
" URL:          http://github.com/nvie/vim-nosetests
"
" Only do this when not done yet for this buffer
if exists("b:loaded_nosetests_ftplugin")
    finish
endif
let b:loaded_nosetests_ftplugin = 1

let s:nosetests_cmd="nosetests"

hi RedBar ctermfg=white ctermbg=red guibg=red
hi GreenBar ctermfg=white ctermbg=green guibg=green

function! RedBar()
    echohl RedBar
    echon repeat(" ",&columns - 1)
    echohl
endfunction

function! GreenBar()
    echohl GreenBar
    echon repeat(" ",&columns - 1)
    echohl
endfunction

if !exists("*Nosetests()")
    function Nosetests()
        if !executable(s:nosetests_cmd)
            echoerr "File " . s:nosetests_cmd . " not found. Please install it first."
            return
        endif

        set lazyredraw   " delay redrawing
        cclose           " close any existing cwindows

        " store old grep settings (to restore later)
        let l:old_gfm=&grepformat
        let l:old_gp=&grepprg

        " write any changes before continuing
        if &readonly == 0
            silent update
        endif

        " perform the grep itself
        let &grepformat="%f:%l:\ fail:\ %m,%f:%l:\ error:\ %m"
        let &grepprg=s:nosetests_cmd . " --with-machineout"
        " let &grepformat="%-C\ %.%#,%A\ \ File\ \"%f\"\\,\ line\ %l%.%#,%Z%[%^\ ]%\\@=%m,%-G%.%#"
        " let &grepprg="nosetests"
        silent! grep!

        " restore grep settings
        let &grepformat=l:old_gfm
        let &grepprg=l:old_gp

        if getqflist() != []
            for error in getqflist()
                if error['valid']
                    break
                endif
            endfor
            let error_message = substitute(error['text'], '^ *', '', 'g')
            " silent exec ":sbuffer " . error['bufnr']
            " silent 2cc!
            " call RedBar()
            echohl RedBar
            echomsg error_message
            echohl
        else
            " call GreenBar()
            let error_message = "All tests OK!"
            echohl GreenBar
            echomsg error_message
            " echomsg "All tests OK!"
            echohl
        endif

        " open cwindow
        " let has_results=getqflist() != []
        " if has_results
        "     " execute 'belowright copen'
        "     " setlocal wrap
        "     " nnoremap <buffer> <silent> c :cclose<CR>
        "     " nnoremap <buffer> <silent> q :cclose<CR>
        "     hi Red guibg=red guifg=black
        "     echohl Green
        "     echon "All tests OK!"
        "     echohl
        " endif
" 
        " set nolazyredraw
        " redraw!
" 
        " if has_results == 0
        "     " Show OK status
        "     hi Green guibg=green guifg=black
        "     echohl Green
        "     echon "All tests OK!"
        "     echohl
        " endif
    endfunction
endif

" Add mappings, unless the user didn't want this.
" The default mapping is registered under to <F6> by default, unless the user
" remapped it already (or a mapping exists already for <F6>)
" if !exists("no_plugin_maps") && !exists("no_nosetests_maps")
"     if !hasmapto('Nosetests(')
"         noremap <buffer> <F6> :call Nosetests()<CR>
"         noremap! <buffer> <F6> :call Nosetests()<CR>
"     endif
" endif
