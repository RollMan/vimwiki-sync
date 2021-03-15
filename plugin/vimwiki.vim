augroup vimwiki
    if !exists('g:vimwiki_synced')
        let g:vimwiki_synced = 0
    endif

    if !exists('g:vimwiki_dir')
        "let g:vimwiki_dir = VimwikiGet('path',g:vimwiki_current_idx) 
        let g:vimwiki_dir = vimwiki#vars#get_wikilocal('path')
    endif

    if !exists('g:vimwiki_push_on_commit')
        let g:vimwiki_push_on_commit=0
    endif

    let g:vimwiki_dir_expanded = expand(g:vimwiki_dir)


    function! s:pull_exit(ch, msg)
        echomsg "Vimwiki: changes pulled from server"
        let g:vimwiki_synced=1
    endfunction

    function! s:pull_changes()
        if g:vimwiki_synced==0
            let l:command = "git -C " . g:vimwiki_dir_expanded . " pull origin master"
            let jobid = job_start(l:command, {'callback': function('s:pull_exit')})
        endif
    endfunction

    function! s:push_exit(ch, msg)
        echomsg "Vimwiki: changes pushed to server"
    endfunction

    " push changes
    " it seems that Vim terminates before it is executed, so it needs to be
    " fixed
    function! s:push_changes()
        let l:command1 = "git -C " . g:vimwiki_dir_expanded . " push origin master"
        call system(l:command1)
        let l:command2 = "git -C " . g:vimwiki_dir_expanded . " push gitlab master"
        call system(l:command2)
    endfunction

    function! s:commit_exit(ch, msg)
        echomsg "Vimwiki: changes commited"
        echomsg a:msg
        if g:vimwiki_push_on_commit == 1
            call s:push_changes()
        endif
    endfunction

    function! s:add_exit(ch, msg)
        echomsg "Vimwiki: changes added"
        echomsg a:msg
        echo a:msg
        let jobid = job_start(['/usr/bin/git', '-C', g:vimwiki_dir_expanded, 'commit', '-m', '"Auto Commit"'], {'callback': 's:commit_exit'})
        echom
    endfunction

    " commit chages to server
    function! s:commit_changes()
        let l:command = "/usr/bin/git -C " . g:vimwiki_dir_expanded . " add " . g:vimwiki_dir_expanded . " && /usr/bin/git -C " . g:vimwiki_dir_expanded . " commit -m \"Auto commit " . strftime("%FT%T%z") . "\""
        "let jobid = job_start(['/usr/bin/git', '-C', g:vimwiki_dir_expanded, 'add', g:vimwiki_dir_expanded], {'callback': 's:add_exit'})
        call system(l:command)
    endfunction

    " sync changes at the start
    au! VimEnter /home/yshimmyo/vimwiki_yshimmyo/*.wiki call s:pull_changes()
    au! BufRead /home/yshimmyo/vimwiki_yshimmyo/*.wiki call s:pull_changes()
    " auto commit changes on each file change
    au! BufWritePost *.wiki call s:commit_changes()
    " push changes only on at the end
    au! BufLeave *.wiki call s:push_changes()
    au! VimLeave *.wiki call s:push_changes()
augroup END
