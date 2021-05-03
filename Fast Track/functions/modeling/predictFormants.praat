
procedure predictFormants .ff, .number_of_coefficients_for_formant_prediction, .number_of_formants
  selectObject: "Table output"
  Copy: "regression"
  Remove column... frame
  Remove column... time
  Append column... formant
  Formula... formant self[row,"f"+string$(.ff)]

  for .i from 1 to .number_of_formants
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
  #select Table regression
  #Append column... f'.ff'p
  #Formula... f'.ff'p intercept

  for .c from 1 to .number_of_coefficients_for_formant_prediction
    coeff'.c' = extractNumber (info$, "Coefficient of factor time" + string$(.c)+ ": ")
    select Table output
    Formula... f'.ff'p self + self[row,"time"+string$(.c)] * coeff'.c'
    #select Table regression
    #Formula... f'.ff'p self + self[row,"time"+string$(.c)] * coeff'.c'
  endfor

  selectObject: .linreg
  Remove

  select Table output
  Append difference column... f'.ff' f'.ff'p error'.ff'
  Formula... f'.ff'p round (self*10)/10

  #######################################################################

  #select Table regression
  #Append difference column... formant f'.ff'p error'.ff'
  #Formula... formant self - (self[row,"error"+string$(.ff)]  / 2)  
  #Remove column... error'.ff'

  #######################################################################

  #select Table regression
  #.linreg = To linear regression
  #info$ = Info
  #intercept = extractNumber (info$, "Intercept: ")
  #select Table output
  #Formula... f'.ff'p intercept

  #for .c from 1 to .number_of_coefficients_for_formant_prediction
  #  coeff'.c' = extractNumber (info$, "Coefficient of factor time" + string$(.c)+ ": ")
  #  select Table output
  #  Formula... f'.ff'p self + self[row,"time"+string$(.c)] * coeff'.c'
  #endfor

  #selectObject: .linreg
  #Remove

  removeObject: "Table regression"
endproc
