
########################################################################################################################################################
########################################################################################################################################################
## Initial setup

include utils/trackAutoselectProcedure.praat

snd = selected ()
basename$ = selected$ ("Sound")
total_duration = Get total duration

## If I knew how to check if one was already open for this file I would. 
## but I dont know how. if anyone knows please let me know!
View & Edit

# the form is in a loop so that multiple analyses can be run
clicked = 2

# this is the initial state of many of the flag variables in the function
return_formant = 0
save_formant = 0
save_csv = 0
save_all_formants = 0
return_table = 0
analyze_selection = 0
what_to_track= 2

while clicked == 2

@getSettings

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

optionMenu: "What to track:", what_to_track
  option: "Entire sound"
	option: "Selection in Edit Window (plot visible)"
	option: "Selection in Edit Window (plot only selection)"
	option: "Selection in Edit Window (plot whole sound)"

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
  positive: "Maximum plotting frequency (Hz): ", maximum_plotting_frequency
	optionMenu: "Image", 1
	  option: "Show image of winner"
		option: "Show image comparing of all analyses"
		comment: "Choose which data to save and/or return."
		boolean: "return formant", return_formant ;
    boolean: "save formant", save_formant ;
		boolean: "save csv", save_csv ;
		boolean: "save all formants", save_all_formants
		boolean: "return table", return_table
    
nocheck clicked = endPause: "Ok","Apply", 1
number_of_steps = number(number_of_steps$)
number_of_formants = number(number_of_formants$)

# re-check sound file name in case this is second run (given that the form is a loop)
numberOfSelectedSounds  = numberOfSelected ("Sound")
if numberOfSelectedSounds == 1
  snd = selected ()
  basename$ = selected$ ("Sound")
endif

# settings are saved out tp the text file during each iteration
@saveSettings

# is = whole sound so >1 is a selection
if what_to_track > 1
  analyze_selection = 1
endif
# plot in context determines whether the whole spectrogram needs to be used
# or just a selection
plot_in_context = 1
if what_to_track == 3
  plot_in_context = 0
endif

if analyze_selection == 1	
  editor: snd
    start = Get start of selection
    end = Get end of selection
  endeditor
  ## if selection is greater than 30 milliseconds
  if (end - start) < 0.03 
    analyze_selection = 0
    #exitScript: "Selection is less than 30 milliseconds, please select more sound."
  endif
endif


if analyze_selection == 1	
  # this first part nudges selection edges if they are too close to the end of the file
  # and moves selection edges further to acomodate the window length. Then the sound is 
  # extracted and selected
  if start < 0.025
    start = 0
  endif
  if start > 0.025
    start = start - 0.025
  endif
  if (end + 0.025) > total_duration
    end = total_duration
  endif
  if (end + 0.025) < total_duration
    end = end + 0.025
  endif
  selectObject: snd
  if plot_in_context == 1
    Extract part: start, end, "rectangular", 1, "yes"
  endif
  if plot_in_context == 0
    Extract part: start, end, "rectangular", 1, "no"
  endif
  tmp_snd = selected()
endif


sound_to_plot = snd
sound_to_analyse = snd
if analyze_selection == 1
  sound_to_analyse = tmp_snd
  if plot_in_context == 0
    sound_to_plot = tmp_snd
  endif
endif

# what kind of output is selected? 1=save, 2=return, 3=both
output_formant = save_formant
if return_formant = 1
  output_formant = output_formant + 2
endif
output_table = save_csv
if return_table = 1
  output_table = output_table + 2
endif
plot_current_view = 0
if what_to_track = 2
  plot_current_view = 1
endif

# I need to change this to something more useful like the winning regression coefficients or something
writeInfoLine: "Analyzing..."

# do the analysis and get the output
@trackAutoselect: sound_to_analyse, folder$, lowest_analysis_frequency, highest_analysis_frequency, number_of_steps, number_of_coefficients_for_formant_prediction, number_of_formants, tracking_method$, image, sound_to_plot, plot_current_view, maximum_plotting_frequency, output_formant, output_table, save_all_formants

writeInfoLine: "Best cutoff is: " + string$(trackAutoselect.cutoff)
appendInfoLine: ""
appendInfoLine: "F1 coefficients: "
appendInfoLine: trackAutoselect.f1coeffs#
appendInfoLine: "F2 coefficients: "
appendInfoLine: trackAutoselect.f2coeffs#
appendInfoLine: "F3 coefficients: "
appendInfoLine: trackAutoselect.f3coeffs#
if number_of_formants == 4
  appendInfoLine: "F4 coefficients: "
  appendInfoLine: trackAutoselect.f4coeffs#
endif
appendInfoLine: ""
appendInfoLine: "The first number in each row (the intercept) is a good estimate of the"
appendInfoLine: "frequency of the formant at the analysis midpoint. The second number indicates"
appendInfoLine: "its linear slope, the third its quadratic component (u-shapedness), ... etc."

# tidy up
if analyze_selection == 1
  removeObject: tmp_snd
endif

selectObject: snd

endwhile

