
procedure saveSettings

  .tmp_str = Read Strings from raw text file: "../settings/settings.txt"
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

  Save as raw text file: "../settings/settings.txt"
  removeObject: .tmp_str


  ## heuristics

  .tmp_str = Read Strings from raw text file: "../settings/heuristics.txt"

  enable_F1_frequency_heuristic$ = string$(enable_F1_frequency_heuristic)
  Set string: 1, enable_F1_frequency_heuristic$

  maximum_F1_frequency_value$ = string$(maximum_F1_frequency_value)
  Set string: 2, maximum_F1_frequency_value$

  enable_F1_bandwidth_heuristic$ = string$(enable_F1_bandwidth_heuristic)
  Set string: 3, enable_F1_bandwidth_heuristic$

  maximum_F1_bandwidth_value$ = string$(maximum_F1_bandwidth_value)
  Set string: 4, maximum_F1_bandwidth_value$

  enable_F2_bandwidth_heuristic$ = string$(enable_F2_bandwidth_heuristic)
  Set string: 5, enable_F2_bandwidth_heuristic$

  maximum_F2_bandwidth_value$ = string$(maximum_F2_bandwidth_value)
  Set string: 6, maximum_F2_bandwidth_value$

  enable_F3_bandwidth_heuristic$ = string$(enable_F3_bandwidth_heuristic)
  Set string: 7, enable_F3_bandwidth_heuristic$

  maximum_F3_bandwidth_value$ = string$(maximum_F3_bandwidth_value)
  Set string: 8, maximum_F3_bandwidth_value$

  enable_F4_frequency_heuristic$ = string$(enable_F4_frequency_heuristic)
  Set string: 9, enable_F4_frequency_heuristic$

  minimum_F4_frequency_value$ = string$(minimum_F4_frequency_value)
  Set string: 10, minimum_F4_frequency_value$

  enable_rhotic_heuristic$ = string$(enable_rhotic_heuristic)
  Set string: 11, enable_rhotic_heuristic$

  enable_F3F4_proximity_heuristic$ = string$(enable_F3F4_proximity_heuristic)
  Set string: 12, enable_F3F4_proximity_heuristic$

  Save as raw text file: "../settings/heuristics.txt"
  removeObject: .tmp_str


  ## CSV output

  .tmp_str = Read Strings from raw text file: "../settings/CSVoutput.txt"

  output_bandwidth$ = string$(output_bandwidth)
  Set string: 1, output_bandwidth$

  output_predictions$ = string$(output_predictions)
  Set string: 2, output_predictions$

  output_pitch$ = string$(output_pitch)
  Set string: 3, output_pitch$

  output_intensity$ = string$(output_intensity)
  Set string: 4, output_intensity$
  
  output_harmonicity$ = string$(output_harmonicity)
  Set string: 5, output_harmonicity$
  
  output_normalized_time$ = string$(output_normalized_time)
  Set string: 6, output_normalized_time$
  
  Save as raw text file: "../settings/CSVoutput.txt"
  removeObject: .tmp_str


endproc
