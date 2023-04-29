
########################################################################################################################################################
########################################################################################################################################################
## Initial setup

include utils/trackAutoselectProcedure.praat
include utils/importFunctions.praat
include folder/trackFolder.praat
include folder/autoSelectFolder.praat
include folder/getWinnersFolder.praat

# this is the initial state of many of the flag variables in the function
return_formant = 0
save_formant = 0
save_csv = 0
save_all_formants = 0
return_table = 0
analyze_selection = 0
what_to_track= 2
make_winner_images = 0

@getSettings

sound_folder$ = folder$

beginPause: "Set Parameters"
  optionMenu: "", 1
    option: "[Click to Read Additional Information]"
    option: "Folder: Indicate where you want any output files to go. An image of the output is always saved."
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

  sentence: "Folder:", sound_folder$
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
  positive: "Maximum plotting frequency (Hz): ", maximum_plotting_frequency
  optionMenu: "Number of bins:", number_of_bins
  			option: "1"
  			option: "3"
  			option: "5"
        option: "7"
        option: "9"
        option: "11"
	 optionMenu: "Statistic", 1
  	        option: "median"
  					option: "mean"
 	boolean: "make winner images", make_winner_images
nocheck endPause: "Ok", 1

number_of_steps = number(number_of_steps$)
number_of_formants = number(number_of_formants$)

sound_folder$ = folder$

# re-check sound file name in case this is second run (given that the form is a loop)
numberOfSelectedSounds  = numberOfSelected ("Sound")
if numberOfSelectedSounds == 1
  snd = selected ()
  basename$ = selected$ ("Sound")
endif

ending$ = right$ (sound_folder$,1)
if ending$ == "/"
  sound_folder$ = sound_folder$ - "/"
endif
if ending$ == "\"
  sound_folder$ = sound_folder$ - "\"
endif

# settings are saved out tp the text file during each iteration
@saveSettings

file_info = Read Table from comma-separated file: sound_folder$ + "/file_information.csv"
selectObject: file_info
Append column: "omit"
.nfiles = Get number of rows

# I need to change this to something more useful like the winning regression coefficients or something
writeInfoLine: "Analyzing..."
image = 1
output_formant = 0
output_table = 1
folder$ = sound_folder$ + "/output"
createDirectory: sound_folder$ + "/output"
writeInfoLine: sound_folder$ + "/output"

for .iii from 1 to .nfiles

  selectObject: file_info
  .basename$ = Get value: .iii, "file"
  .snd = Read from file: sound_folder$ + "/sounds/" + .basename$
  .totdur = Get total duration
  if (.totdur - 0.050) > (number_of_coefficients_for_formant_prediction*2*time_step)
    selectObject: file_info
    Set numeric value: .iii, "omit", 0
    .basename$ = .basename$ - ".wav"

    sound_to_analyse = .snd
    sound_to_plot = .snd
    plot_current_view = 0
    # do the analysis and get the output
    @trackAutoselect: sound_to_analyse, folder$, lowest_analysis_frequency, highest_analysis_frequency, number_of_steps, number_of_coefficients_for_formant_prediction, number_of_formants, tracking_method$, image, sound_to_plot, plot_current_view, maximum_plotting_frequency, output_formant, output_table, save_all_formants

  if (.totdur - 0.050) < (number_of_coefficients_for_formant_prediction*2*time_step)
    selectObject: file_info
    Set numeric value: .iii, "omit", 1
  endif

  removeObject: .snd

endfor
