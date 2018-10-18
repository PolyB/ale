" Author: Adrien Stalain <adrien.stalain@epita.fr>
" Description: gcc linter for ada files

call ale#Set('ada_gcc_executable', 'gcc')
call ale#Set('ada_gcc_options', '')

function! ale_linters#ada#gcc#GetCommand(buffer) abort
    return 'gcc -c -x ada -gnatc -gnaty '
    \   . '-iquote ' . ale#Escape(fnamemodify(bufname(a:buffer), ':p:h'))
    \   . ' ' . ale#Var(a:buffer, 'ada_gcc_options') . ' %s'
endfunction

function! ale_linters#ada#gcc#Handle(buffer, lines) abort
    let l:pattern = '^.\+:\(\d\+\):\(\d\+\): \(.\+\)$'
    let l:output = []
    echo a:lines

    for l:match in ale#util#GetMatches(a:lines, l:pattern)
        call add(l:output, {
        \ 'lnum': l:match[1] + 0,
        \ 'col' : l:match[2],
        \ 'type': l:match[3] =~? '^(style)' ? 'W' : 'E',
        \ 'text': l:match[3],
        \})
    endfor

    return l:output
endfunction

call ale#linter#Define('ada', {
\    'name': 'gcc',
\    'output_stream': 'stderr',
\    'executable_callback': ale#VarFunc('ada_gcc_executable'),
\    'command_callback': 'ale_linters#ada#gcc#GetCommand',
\    'callback': 'ale_linters#ada#gcc#Handle',
\    'lint_file': 1,
\})
