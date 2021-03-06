let s:messages = []
let s:errors = []
let s:done = 0
let s:fail = 0

fun! RunTheTest(test)
  let l:message = a:test . '… '
  let s:done += 1
  try
    exe 'call ' . a:test
  catch
    call add(v:errors, 'Caught exception in ' . a:test . ': ' . v:exception . ' @ ' . v:throwpoint)
  endtry

  if len(v:errors) > 0
    let s:fail += 1
    let l:message .= 'FAILED'
    call add(s:errors, a:test)
    call extend(s:errors, v:errors)
    let v:errors = []
  else
    let l:message .= 'ok'
  endif
  call add(s:messages,  l:message)
endfunc

fun! FinishTesting()
  call add(s:messages, '')
  call add(s:messages, 'Run ' . s:done . (s:done > 1 ? ' tests' : ' test'))
  if s:fail == 0
    call add(s:messages, 'ALL TESTS PASSED!')
  else
    call add(s:messages, s:fail . (s:fail > 1 ? ' tests' : ' test') . ' failed')
  endif

  botright new +setlocal\ buftype=nofile\ bufhidden=wipe\ nobuflisted\ noswapfile\ wrap
  call append(line('$'), s:messages)
  call append(line('$'), '')
  call append(line('$'), s:errors)
endf

fun! RunBabyRun(...)
  " Locate Test_ functions and execute them.
  redir @q
  execute 'silent function /^Test_'.(a:0 > 0 ? a:1 : '')
  redir END
  let s:tests = split(substitute(@q, 'function \(\k*()\)', '\1', 'g'))

  for s:test in sort(s:tests)
    call RunTheTest(s:test)
  endfor

  call FinishTesting()
endf
