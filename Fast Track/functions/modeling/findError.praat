
procedure findError .fr

  ####################################################################################
  # sets up table called output that will contain all information abotu values, prediction, error, etc.
  selectObject: .fr
  .tmp_tbl = Down to Table: "yes", "yes", 6, "no", 1, "yes", 1, "yes"
  .tbl = Extract rows where column (number): "nformants", "greater than", 3
  Rename: "output"
  number_of_frames = Get number of rows
  Remove column: "nformants"
  Remove column: "F5(Hz)"
  Remove column: "B5(Hz)"
  Remove column: "F6(Hz)"
  Remove column: "B6(Hz)"
  Set column label (label): "time(s)", "time"

  for .i from 1 to 4
    Set column label (label): "F"+string$(.i)+"(Hz)", "f"+string$(.i)
    Set column label (label): "B"+string$(.i)+"(Hz)", "b"+string$(.i)
  endfor

  if number_of_formants == 3
    Remove column: "b4"
    Remove column: "f4"
  endif

  Append column: "f1p"
  Append column: "f2p"
  Append column: "f3p"

  if number_of_formants == 4
    Append column: "f4p"
  endif

  removeObject: .tmp_tbl

  ####################################################################################
  # adds predictors to output table using formulas
  # creates table called regression analysis used for the actual regression

  select Table output
  Append column: "time1"
  Formula: "time1", "row / number_of_frames"
  Formula: "time1", "cos(( self )*pi*2*(1*0.5))"

  for .c from 2 to number_of_coefficients_for_formant_prediction
    select Table output
    Append column... time'.c'
    Formula: "time"+string$(.c), "row / " + string$(number_of_frames)
    Formula: "time"+string$(.c), "cos(( self )*pi*2*(.c*0.5))"
  endfor

  ####################################################################################
  ## prediction of formant values and collections of prediction coefficients
  for .fnum from 1 to number_of_formants
    @predictFormants: .fnum
    f'.fnum'coeffs[1] = round (intercept * 10) / 10
    for .cnum from 1 to number_of_coefficients_for_formant_prediction
      f'.fnum'coeffs[.cnum+1] = round(coeff'.cnum' * 10) / 10
    endfor
  endfor

  ## predictor information no longer needed in output. it was only there to speed up prediction
  select Table output
  for .ff from 1 to number_of_coefficients_for_formant_prediction
    Remove column... time'.ff'
  endfor

  ###############################################################################
  ### Here is where the error is calculated. add interquartile range and variance.


  ## difference between predicted and observed
  for .ff from 1 to number_of_formants
    Append difference column... f'.ff' f'.ff'p error'.ff'
    Formula... error'.ff' abs (self)
    Formula... f'.ff'p round (self*10)/10
  endfor

  formantError# = zero#(number_of_formants)
  totalerror = 0
  select Table output
  Formula: "error1", "abs (self)"
  Formula: "error2", "abs (self)"
  Formula: "error3", "abs (self)"
  if number_of_formants == 4
    Formula: "error4", "abs (self)"
  endif
  .tmp = Get quantile: "error1", 0.5
  formantError#[1]  = round(.tmp*10)/10
  .tmp = Get quantile: "error2", 0.5
  formantError#[2] = round(.tmp*10)/10
  .tmp = Get quantile: "error3", 0.5
  formantError#[3] = round(.tmp*10)/10
  if number_of_formants == 4
    .tmp = Get quantile: "error4", 0.5
    formantError#[4] = round(.tmp*10)/10
  endif

  for .ff from 1 to number_of_formants
    Remove column... error'.ff'
  endfor
  Remove column... frame

endproc
