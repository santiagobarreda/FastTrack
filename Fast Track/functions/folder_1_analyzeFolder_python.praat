
## collect all regression coefficients in one big csv file. recreate after, collect winners,

include utils/getSettings_python.praat
include utils/importFunctions.praat
include folder/trackFolder.praat
include folder/autoSelectFolder.praat
include folder/getWinnersFolder.praat

form Set Parameters  
    sentence folder
#	positive number_of_steps
#	positive number_of_coefficients_for_formant_prediction
#    	positive lowest_analysis_frequency
#	positive highest_analysis_frequency
#	positive maximum_plotting_frequency
#	positive time_step
#	sentence tracking_method
#	positive number_of_formants
#	sentence basis_functions
#	sentence error_method
#	positive number_of_bins
#	positive make_images_comparing_analyses
#	positive make_images_showing_winners
#	sentence statistic
#	positive show_progress
#	positive track_formants
#	positive autoselect_winners
#	positive get_winners
#	positive aggregate
endform
sepIndex = index(folder$, "\")
if sepIndex == 0
	sep$ = "/"
	writeInfoLine: sepIndex
	writeInfoLine: folder$
	writeInfoLine: sep$

else
	sep$ = "\"
	writeInfoLine: sepIndex
	writeInfoLine: folder$
	writeInfoLine: sep$

ending$ = right$ (folder$,1)
if ending$ == "/"
  folder$ = folder$ - "/"
endif
if ending$ == "\"
  folder$ = folder$ - "\"
endif

@getSettings_python

writeInfoLine: "Analysis settings found in folder"
appendInfoLine: "Folder: ", folder$
appendInfoLine: "Number of steps: ", number_of_steps
appendInfoLine: "Number of coefficients for formant prediction: ", number_of_coefficients_for_formant_prediction
appendInfoLine: "Lowest analysis frequency (Hz): ", lowest_analysis_frequency
appendInfoLine: "Highest analysis frequency (Hz): ", highest_analysis_frequency
appendInfoLine: "Maximum frequency to plot: ", maximum_plotting_frequency
appendInfoLine: "Analysis time step: ", time_step
appendInfoLine: "Tracking method: ", tracking_method$
appendInfoLine: "Number of formants to track: ", number_of_formants
appendInfoLine: "Basis function: ", basis_functions$
appendInfoLine: "Error method: ", error_method$
appendInfoLine: "Number of bins for formant track: ", number_of_bins
appendInfoLine: "Make images comparing analysis: ", make_images_comparing_analyses
appendInfoLine: "Make images showing winners: ", make_images_showing_winners
appendInfoLine: "Statistic: ", statistic$
appendInfoLine: "Show progress: ", show_progress
appendInfoLine: "Track formants: ", track_formants
appendInfoLine: "Autoselect winners: ", autoselect_winners
appendInfoLine: "Get winners: ", get_winners
appendInfoLine: "Aggregate: ", aggregate 


daySecond = 0
save_csvs = 1

@daySecond
overAllStart = daySecond


if track_formants = 1
  @trackFolder
endif
if autoselect_winners = 1
  save_image = make_images_comparing_analyses
  @autoSelectFolder
endif
if get_winners = 1
  save_images = make_images_showing_winners
  @getWinnersFolder
endif

if aggregate = 1
  @aggregate: 1
  selectObject: "Table aggregated"
  tbl = selected()

  plotting_symbols$ = "--"
  font_size = 28
  add_axes = 1
  erase = 1
  which_bin_to_plot = 3
  all_points = 0
  line_width = 2
  type_of_plot = 1
  arrow_size = 1
  point_size = 1.5
  draw_grid = 0
  minimum_F1 = 200
  maximum_F1 = 1200
  minimum_F2 = 500
  maximum_F2 = 3000
  @plotAggregate: 1
  Save as 300-dpi PNG file: folder$ + "/contours.png"
  
  plotting_symbols$ = "--"
  font_size = 14
  add_axes = 1
  erase = 1
  which_bin_to_plot = 3
  all_points = 0
  line_width = 2
  type_of_plot = 2
  arrow_size = 1
  point_size = 1.5
  draw_grid = 0
  minimum_F1 = 200
  maximum_F1 = 1200
  minimum_F2 = 500
  maximum_F2 = 3000
  @plotAggregate: 1
  Save as 300-dpi PNG file: folder$ + "/label.png"

  tbl = selected()
  plotting_symbols$ = "--"
  font_size = 14
  add_axes = 1
  erase = 1
  which_bin_to_plot = 3
  all_points = 0
  line_width = 2
  type_of_plot = 2
  arrow_size = 1
  point_size = 1.5
  draw_grid = 1
  label_column$ = "number"
  minimum_F1 = 200
  maximum_F1 = 1200
  minimum_F2 = 500
  maximum_F2 = 3000
  @plotAggregate: 1
  Save as 300-dpi PNG file: folder$ + "/number.png"

  @getCoefficients: 1
  removeObject: "Table aggregated"
endif


@daySecond
overAllEnd = daySecond
totalTime = overAllEnd - overAllStart
appendInfoLine: "Finished!"
appendInfoLine: "Process took: " + string$(totalTime) + " seconds."
