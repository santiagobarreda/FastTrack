
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

  ## heuristics

  enable_F1_bandwidth_heuristic$ = string$(enable_F1_bandwidth_heuristic)
  Set string: 12, enable_F1_bandwidth_heuristic$

  maximum_F1_bandwidth_value$ = string$(maximum_F1_bandwidth_value)
  Set string: 13, maximum_F1_bandwidth_value$

  enable_F2_bandwidth_heuristic$ = string$(enable_F2_bandwidth_heuristic)
  Set string: 14, enable_F2_bandwidth_heuristic$

  maximum_F2_bandwidth_value$ = string$(maximum_F2_bandwidth_value)
  Set string: 15, maximum_F2_bandwidth_value$

  enable_F4_frequency_heuristic$ = string$(enable_F4_frequency_heuristic)
  Set string: 16, enable_F4_frequency_heuristic$

  minimum_F4_value$ = string$(minimum_F4_value)
  Set string: 17, minimum_F4_value$

  Save as raw text file: "../settings.txt"
  removeObject: .tmp_str

endproc
