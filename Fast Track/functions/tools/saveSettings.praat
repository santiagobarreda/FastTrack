
procedure saveSettings

  .tmp_str = Read Strings from raw text file: "../settings.txt"

  Set string: 1, folder$

  if number_of_steps < 8
    number_of_steps = (number_of_steps*4) + 4
  endif
  number_of_steps$ = string$(number_of_steps)
  Set string: 2, number_of_steps$

  number_of_coefficients_for_formant_prediction$ = string$(number_of_coefficients_for_formant_prediction)
  Set string: 3, number_of_coefficients_for_formant_prediction$

  lowest_analysis_frequency$ = string$(lowest_analysis_frequency)
  Set string: 4, lowest_analysis_frequency$

  highest_analysis_frequency$ = string$(highest_analysis_frequency)
  Set string: 5, highest_analysis_frequency$

  maximum_plotting_frequency$ = string$(maximum_plotting_frequency)
  Set string: 6, maximum_plotting_frequency$

  time_step$ = string$(time_step)
  Set string: 7, time_step$

  Set string: 8, tracking_method$

  Set string: 9, number_of_formants$

  Set string: 10, basis_functions$
  Set string: 11, error_method$

  Save as raw text file: "../settings.txt"
  removeObject: .tmp_str

endproc
