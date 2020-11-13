
## collect all regression coefficients in one big csv file. recreate after, collect winners,

include utils/importfunctions.praat
include folder/trackFolder.praat
include folder/autoSelectFolder.praat
include folder/getWinnersFolder.praat

@getSettings

beginPause: "Set Parameters"
    optionMenu: "", 1
    option: "[Click to Read Additional Information]"
    option: "Folder: Indicate your working directory. This folder should contain a folder inside of it"
    option: "called 'sounds' that contains all of the sounds you wish to analyze."
    option: " "
    option: "Highest an lowest analysis frequencies: Appropriate highest and lowest frequencies will vary as a function of talker vocal-tract length,"
    option: "which is strongly related to height across all speakers. Talkers can be grouped into broad categories of:"
    option: "   tall (>5 foot 8): recommended range 4500-6500 Hz"
    option: "   medium (5 foot 8 >  > 5 foot 0): recommended range 5000-7000 Hz"
    option: "   short (<5 foot 0) recommended range 5500-7500 Hz"
    option: "These categories correspond roughly to adult males, adult females (and teenagers), and younger children. However, there is "
    option: "substantial overlap between categories and variation within-category, so that adjustments may be required for individual voices."		
    option: " "
    option: "Number of steps: the analyses between low and high analysis limits. More analysis steps may improve results, but will increase"
    option: "analysis time and the amount of data generated: 50% more steps means a 50% longer analysis time, and 50% more generated files."		
    option: " "
    option: "Number of Coefficients: More coefficients allow for more sudden, and 'wiggly' formant motion."
    option: " "
    option: "Number of formants: The best analysis will be found on average across all desired formants. Often, F4 can be difficult to track so that the best analysis including F4"
    option: "may not be the best analysis for F3 and below. If you only want 3 formants,tracking 3 will ensure the analysis is optimized for those formants."
    option: " "
    option: "Images: Images are recommended as they facilitate data validation and the selection of alternate analyses. Making images can add 10%-20% more time to the analysis."
    option: " "
    option: "Aggregation options: How many temporal bins should be used, and which statistic should be calculated in each bin?"
    
    sentence: "Folder:", folder$
    positive: "Lowest analysis frequency (Hz):", lowest_analysis_frequency
		positive: "Highest analysis frequency (Hz):", highest_analysis_frequency
    optionMenu: "Number of steps:", number_of_steps
			option: "8"
			option: "12"
			option: "16"
			option: "20"
			option: "24"
		positive: "Number of coefficients for formant prediction:", number_of_coefficients_for_formant_prediction
    optionMenu: "Number of formants", number_of_formants
            option: "3"
            option: "4"
    boolean: "Make images comparing analyses", 1
    boolean: "Make images showing winners", 1
    positive: "Maximum plotting frequency (Hz):", maximum_plotting_frequency
    optionMenu: "Number of bins:", 3
  			option: "1"
  			option: "3"
  			option: "5"
        option: "7"
        option: "9"
        option: "10"
    optionMenu: "Statistic", 1
  	        option: "median"
  					option: "mean"
     optionMenu: "", 1
    option: "[Click to Read]"
   option: "Uncheck to skip step. Individual steps can be carried out if previous step has been completed."
   boolean: "Track formants", 1
    boolean: "Autoselect winners", 1
    boolean: "Get winners", 1
    boolean: "Aggregate", 1
nocheck endPause: "Ok", 1

number_of_steps = number(number_of_steps$)
number_of_formants = number(number_of_formants$)

ending$ = right$ (folder$,1)
if ending$ == "/"
  folder$ = folder$ - "/"
endif
if ending$ == "\"
  folder$ = folder$ - "\"
endif

@saveSettings

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
  number_of_bins = 5
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
  number_of_bins = 5
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
  number_of_bins = 5
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


  #@getCoefficients: 1
endif


@daySecond
overAllEnd = daySecond
totalTime = overAllEnd - overAllStart
writeInfoLine: "Finished!"
appendInfoLine: "Process took: " + string$(totalTime) + " seconds."
