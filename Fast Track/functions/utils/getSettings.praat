
procedure getSettings

  .settings = Read Strings from raw text file: "../settings/settings.txt"

  folder$ = Get string: 1

  if folder$ == "--please set your folder--"
    exitScript: "Please set your default working folder before proceeding."
  endif

  ending$ = right$ (folder$,1)
  if ending$ == "/"
    folder$ = folder$ - "/"
  endif
  if ending$ == "\"
    folder$ = folder$ - "\"
  endif

  number_of_steps$ = Get string: 2
  number_of_steps = number(number_of_steps$)
  number_of_steps = (number_of_steps-4) / 4

  number_of_coefficients_for_formant_prediction$ = Get string: 3
  number_of_coefficients_for_formant_prediction = number(number_of_coefficients_for_formant_prediction$)

  lowest_analysis_frequency$ = Get string: 4
  lowest_analysis_frequency = number(lowest_analysis_frequency$)

  highest_analysis_frequency$ = Get string: 5
  highest_analysis_frequency = number(highest_analysis_frequency$)

  maximum_plotting_frequency$ = Get string: 6
  maximum_plotting_frequency = number(maximum_plotting_frequency$)

  time_step$ = Get string: 7
  time_step = number(time_step$)

  tracking_method$ = Get string: 8

  number_of_formants$ = Get string: 9
  number_of_formants = 1
  if number_of_formants$ == "4"
    number_of_formants = 2
  endif

  basis_functions$ = Get string: 10

  error_method$ = Get string: 11

  number_of_bins$ = Get string: 12
  number_of_bins = number (number_of_bins$)

  removeObject: .settings



  ###  ### HEURISTICS

  .settings = Read Strings from raw text file: "../settings/heuristics.txt"

  enable_F1_frequency_heuristic$ = Get string: 1
  enable_F1_frequency_heuristic = number(enable_F1_frequency_heuristic$)

  maximum_F1_frequency_value$ = Get string: 2
  maximum_F1_frequency_value = number(maximum_F1_frequency_value$)

  ###
  enable_F1_bandwidth_heuristic$ = Get string: 3
  enable_F1_bandwidth_heuristic = number(enable_F1_bandwidth_heuristic$)

  maximum_F1_bandwidth_value$ = Get string: 4
  maximum_F1_bandwidth_value = number(maximum_F1_bandwidth_value$)

  ###
  enable_F2_bandwidth_heuristic$ = Get string: 5
  enable_F2_bandwidth_heuristic = number(enable_F2_bandwidth_heuristic$)

  maximum_F2_bandwidth_value$ = Get string: 6
  maximum_F2_bandwidth_value = number(maximum_F2_bandwidth_value$)

  ###
  enable_F3_bandwidth_heuristic$ = Get string: 7
  enable_F3_bandwidth_heuristic = number(enable_F3_bandwidth_heuristic$)

  maximum_F3_bandwidth_value$ = Get string: 8
  maximum_F3_bandwidth_value = number(maximum_F3_bandwidth_value$)

  ###
  enable_F4_frequency_heuristic$ = Get string: 9
  enable_F4_frequency_heuristic = number(enable_F4_frequency_heuristic$)

  minimum_F4_frequency_value$ = Get string: 10
  minimum_F4_frequency_value = number(minimum_F4_frequency_value$)

  ###
  enable_rhotic_heuristic$ = Get string: 11
  enable_rhotic_heuristic = number(enable_rhotic_heuristic$)
 
  enable_F3F4_proximity_heuristic$ = Get string: 12
  enable_F3F4_proximity_heuristic = number(enable_F3F4_proximity_heuristic$)

  removeObject: .settings


  ### CSV output

  .settings = Read Strings from raw text file: "../settings/CSVoutput.txt"

  output_bandwidth$ = Get string: 1
  output_bandwidth = number(output_bandwidth$)

  output_predictions$ = Get string: 2
  output_predictions = number(output_predictions$)

  output_pitch$ = Get string: 3
  output_pitch = number(output_pitch$)

  output_intensity$ = Get string: 4
  output_intensity = number(output_intensity$)

  output_harmonicity$ = Get string: 5
  output_harmonicity = number(output_harmonicity$)

  output_normalized_time$ = Get string: 6
  output_normalized_time = number(output_normalized_time$)

  removeObject: .settings


endproc
