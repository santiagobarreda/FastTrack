
procedure getSettings

  .settings = Read Strings from raw text file: "../settings.txt"

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

  enable_F1_bandwidth_heuristic$ = Get string: 12
  enable_F1_bandwidth_heuristic = number(enable_F1_bandwidth_heuristic$)

  maximum_F1_bandwidth_value$ = Get string: 13
  maximum_F1_bandwidth_value = number(maximum_F1_bandwidth_value$)

  enable_F2_bandwidth_heuristic$ = Get string: 14
  enable_F2_bandwidth_heuristic = number(enable_F2_bandwidth_heuristic$)

  maximum_F2_bandwidth_value$ = Get string: 15
  maximum_F2_bandwidth_value = number(maximum_F2_bandwidth_value$)

  enable_F4_frequency_heuristic$ = Get string: 16
  enable_F4_frequency_heuristic = number(enable_F4_frequency_heuristic$)

  minimum_F4_value$ = Get string: 17
  minimum_F4_value = number(minimum_F4_value$)

  removeObject: .settings

  ### HEURISTICS

endproc
