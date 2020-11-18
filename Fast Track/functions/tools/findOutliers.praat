
procedure findOutliers


folder$ = "C:\Users\santi\Desktop\sounds"
.agg = Read Table from comma-separated file: folder$ + "/processed_data/aggregated_data.csv"
.coeffs = Read Table from comma-separated file: folder$ + "/processed_data/coefficients.csv"
nfiles = Get number of rows

for i from 1 to nfiles
  selectObject: .agg
  tmp$ = Get value: i, "label"
  selectObject: .coeffs
  Set string value: i, "file", tmp$
endfor

for i from 1 to 3
  for j from 3 to 6
    Remove column: "c" + string$(i) + string$(j)
  endfor
endfor



.tblofrl = Down to TableOfReal: "file"
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
for i from 1 to nfiles

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
