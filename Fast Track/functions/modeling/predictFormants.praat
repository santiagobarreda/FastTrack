
procedure predictFormants .ff
  ## this makes predictors, cosine waves. adding a column in a table with this name
  selectObject: "Table output"
  Copy: "regression"
  Remove column... frame
  Remove column... time
  Append column... formant
  Formula... formant self[row,"f"+string$(.ff)]

  for .i from 1 to number_of_formants
    Remove column... f'.i'
    Remove column... b'.i'
    Remove column... f'.i'p
  endfor

  select Table regression
  .linreg = To linear regression
  info$ = Info
  intercept = extractNumber (info$, "Intercept: ")
  select Table output
  Formula... f'.ff'p intercept
  for .c from 1 to number_of_coefficients_for_formant_prediction
    coeff'.c' = extractNumber (info$, "Coefficient of factor time" + string$(.c)+ ": ")
    Formula... f'.ff'p self + self[row,"time"+string$(.c)] * coeff'.c'
  endfor

  selectObject: .linreg
  Remove
  removeObject: "Table regression"

endproc
