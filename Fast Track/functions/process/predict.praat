
procedure predict

Read Table from whitespace-separated file: "E:\H95\big\coefficients.txt"
View & Edit
Down to TableOfReal: "vowel"

To Discriminant
selectObject: "TableOfReal coefficients"
plusObject: "Discriminant coefficients"
To ClassificationTable: "yes", "no"
To Table: "rowLabel"
View & Edit

selectObject: "ClassificationTable coefficients_coefficients"
To Strings (max. prob.)
View & Edit

selectObject: "ClassificationTable coefficients_coefficients"

writeInfoLine: "winners and probs:"
for i from 1 to 540

  win_index = Get class index at maximum in row: i
  winp = Get value: i, win_index

  winv$ = Get class label at maximum in row: i
  actv$ = Get row label: i
  act_index = Get column index: actv$
  actp = Get value: i, act_index

  error = 1
  if winv$ == actv$
    error = 0
  endif

  appendInfoLine: i," ",actv$," ", actp, " ", winv$," ", winp," ",error

endfor

endproc
