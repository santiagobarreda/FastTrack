
procedure findError .fr

  ####################################################################################
  # sets up table called output that will contain all information abotu values, prediction, error, etc.
  selectObject: .fr
  .tmp_tbl = Down to Table: "yes", "yes", 6, "no", 1, "yes", 1, "yes"
  .tbl = Extract rows where column (number): "nformants", "greater than", 3
  Rename: "output"
  number_of_frames = Get number of rows
  Remove column: "nformants"
  nocheck Remove column: "F5(Hz)"
  nocheck Remove column: "B5(Hz)"
  nocheck Remove column: "F6(Hz)"
  nocheck Remove column: "B6(Hz)"
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

  f1coeffs# = zero# (number_of_coefficients_for_formant_prediction+1)
  f2coeffs# = zero# (number_of_coefficients_for_formant_prediction+1)
  f3coeffs# = zero# (number_of_coefficients_for_formant_prediction+1)
  if number_of_formants == 4
    f4coeffs# = zero# (number_of_coefficients_for_formant_prediction+1)
  endif

  for .fnum from 1 to number_of_formants
    @predictFormants: .fnum
    f'.fnum'coeffs#[1] = round (intercept * 10) / 10
    for .cnum from 1 to number_of_coefficients_for_formant_prediction
      f'.fnum'coeffs#[.cnum+1] = round(coeff'.cnum' * 10) / 10
    endfor
  endfor

  ## predictor information no longer needed in output. it was only there to speed up prediction
  select Table output
  for .ff from 1 to number_of_coefficients_for_formant_prediction
    Remove column... time'.ff'
  endfor

  ###############################################################################
  ### Here is where the error is calculated. add interquartile range and variance.

  formantError# = zero#(number_of_formants)
  totalerror = 0
  select Table output
  Formula: "error1", "abs (self)"
  Formula: "error2", "abs (self)"
  Formula: "error3", "abs (self)"
  if number_of_formants == 4
    Formula: "error4", "abs (self)"
  endif
  ;.tmp = Get quantile: "error1", 0.5
  .tmp = Get mean: "error1"
  formantError#[1]  = round(.tmp*10)/10
  ;.tmp = Get quantile: "error2", 0.5
  .tmp = Get mean: "error2"
  formantError#[2] = round(.tmp*10)/10
  ;.tmp = Get quantile: "error3", 0.5
  .tmp = Get mean: "error3"
  formantError#[3] = round(.tmp*10)/10
  if number_of_formants == 4
    ;.tmp = Get quantile: "error4", 0.5
    .tmp = Get mean: "error4"
    formantError#[4] = round(.tmp*10)/10
  endif
  

  ### HEURISTICS
  select Table output
  tmp = Get quantile: "f1", 0.5
  if tmp > maximum_F1_frequency_value and enable_F1_frequency_heuristic == 1
    formantError#[1] = formantError#[1] + 10000
  endif

  tmp = Get quantile: "b2", 0.5
  if tmp > maximum_F2_bandwidth_value and enable_F2_bandwidth_heuristic == 1
    formantError#[2] = formantError#[2] + 10000
  endif

  tmp = Get quantile: "b3", 0.5
  if tmp > 600 ;maximum_F2_bandwidth_value and enable_F2_bandwidth_heuristic == 1
    formantError#[2] = formantError#[2] + 10000
  endif

  if number_of_formants == 4
    tmp = Get quantile: "b4", 0.5
    if tmp > 900 ;maximum_F2_bandwidth_value and enable_F2_bandwidth_heuristic == 1
      formantError#[2] = formantError#[2] + 10000
    endif
    #f4bandwidth= Get quantile: "b4", 0.5
    #f4bandwidth= Get mean: "b4"
    tmp4= Get quantile: "f4", 0.5
    tmp1 = Get quantile: "f1", 0.5
    tmp3 = Get quantile: "f3", 0.5
    if tmp4 < minimum_F4_value and enable_F4_frequency_heuristic == 1
      formantError#[4] = formantError#[4] + 10000
    endif
    if tmp1 > 500 and (tmp4-tmp3) < 500
      formantError#[4] = formantError#[4] + 10000
    endif
    #if tmp4 > 4700 ;and enable_F4_frequency_heuristic == 1
    #  formantError#[4] = formantError#[4] + 10000
    #endif
  endif

  for .ff from 1 to number_of_formants
    Remove column... error'.ff'
  endfor
  Remove column... frame

endproc
