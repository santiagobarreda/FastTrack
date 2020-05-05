
## these help read and write vectors to the info files

procedure stringToVector .string$
  .done = 0
  .i = 1
  while .done == 0
    .index = index_regex (.string$, " ")
    if .index > 0
      tmp$ = left$ (.string$, .index-1)
      tmp = number (tmp$)
      stringToVector_output#[.i] = tmp
      .length = length(.string$)
      .string$ = right$ (.string$, .length - .index)
      .i = .i + 1
    endif
    if .index == 0
      tmp = number (.string$)
      stringToVector_output#[.i] = tmp
      .done = 1
    endif
  endwhile
endproc


procedure vectorToString .vector#

  vectorToString_output$ = string$(.vector#[1])
  for .i from 2 to size (.vector#)
    vectorToString_output$ = vectorToString_output$ + " " + string$(.vector#[.i])
  endfor
endproc
