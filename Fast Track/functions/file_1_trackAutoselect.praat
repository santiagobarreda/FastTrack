
########################################################################################################################################################
########################################################################################################################################################
## Initial setup

include utils/importFunctions.praat


snd = selected ()
basename$ = selected$ ("Sound")
total_duration = Get total duration

View & Edit

clicked = 2
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


numberOfSelectedSounds  = numberOfSelected ("Sound")
if numberOfSelectedSounds == 1
  snd = selected ()
  basename$ = selected$ ("Sound")
endif

@saveSettings

if what_to_track > 1
  analyze_selection = 1
endif
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
    exitScript: "Selection is less than 30 milliseconds, please select more sound."
  endif
endif



if analyze_selection == 1	
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



#endif

########################################################################################################################################################
########################################################################################################################################################
## Error estimation section

formantError# = zero#(number_of_formants)
totalError = 0
minerror = 999999
error# =  zero# (number_of_steps)
cutoffs# = zero#(number_of_steps)

stepSize = (highest_analysis_frequency-lowest_analysis_frequency) / (number_of_steps-1)
for i from 1 to number_of_steps
  cutoffs#[i] = round (lowest_analysis_frequency+stepSize*(i-1))
endfor

writeInfoLine: "Median absolute error for frequency (total,F1 F2 F3 F4):"

for z from 1 to number_of_steps
	selectObject: snd

    if analyze_selection == 1
      selectObject: tmp_snd
    endif

  ## add buffer here. make silence, make copy of sound, make nother silence. concatenate, then erase everything!
	if tracking_method$ == "burg"
    noprogress To Formant (burg): time_step, 5.5, cutoffs#[z], 0.025, 50
  endif
  if tracking_method$ == "robust"
    noprogress To Formant (robust): time_step, 5.5, cutoffs#[z], 0.025, 50, 1.5, 5, 1e-006
  endif
  Rename: "formants_" + string$(z)
  formantObject = selected ("Formant")

	@findError: formantObject
	Rename: "formants_" + string$(z)

  error#[z] = sum(formantError#)
  error#[z] = round (error#[z] * 10) / 10

  appendInfoLine: ""
  appendInfo: "cutoff " + string$(cutoffs#[z]) + " Hz: "
  appendInfo: string$(error#[z]) + ", "
  appendInfo: formantError#
endfor

winner = 1
for z from 2 to number_of_steps
  if error#[z] <  minerror
	  winner = z
	  cutoff = cutoffs#[z]
	  minerror = error#[z]
  endif
endfor

appendInfoLine: ""
appendInfoLine: ""
appendInfoLine: "Best cutoff is: " + string$(cutoff)

########################################################################################################################################################
########################################################################################################################################################
## Plot

if image = 1
  Erase all
  Select outer viewport: 0, 7.5, 0, 4.5
  selectObject: "Table formants_" + string$(winner)
  tbl = selected ("Table")
  selectObject: snd
  if plot_in_context == 0
    selectObject: tmp_snd
  endif

  if what_to_track <> 2
    sp = To Spectrogram: 0.007, maximum_plotting_frequency, 0.002, 5, "Gaussian"
	  @plotTable: sp, tbl, maximum_plotting_frequency, 1, "Maximum formant = " + string$(cutoff) + " Hz"
    removeObject: sp
  endif
  if what_to_track == 2
    editor: snd
	  sp = Extract visible spectrogram
	  info$ = Editor info
  	maximum_plotting_frequency = extractNumber (info$, "Spectrogram view to: ")
    endeditor
    selectObject: sp
	  @plotTable: sp, tbl, maximum_plotting_frequency, 1, "Maximum formant = " + string$(cutoff) + " Hz"
    removeObject: sp
	endif
  # change to save with filename or not
  Save as 300-dpi PNG file: folder$ + "/file_winner.png"
 endif

 if image = 2
	  Erase all
	  ### here is where it would need to write out to a plot
	  selectObject: snd

    if analyze_selection == 1
      selectObject: tmp_snd
    endif

	 sp = To Spectrogram: 0.007, maximum_plotting_frequency, 0.002, 5, "Gaussian"

	 width = 2.85
	 xlims# = {0,width, width*2,width*3,0,width, width*2,width*3,0,width, width*2, width*3,0,width, width*2, width*3,0,width, width*2, width*3,0,width, width*2, width*3}
	 ylims# = {0,0,0,0,2,2,2,2,4,4,4,4,6,6,6,6,8,8,8,8,10,10,10,10}

	 for z from 1 to number_of_steps
		 Select outer viewport: xlims#[z], xlims#[z]+3.2, ylims#[z], ylims#[z]+2
		 selectObject: "Table formants_" + string$(z)
		 tbl = selected ("Table")
     Font size: 8
	   @plotTable: sp, tbl, maximum_plotting_frequency, 1, "Maximum formant = " + string$(cutoffs#[z]) + " Hz"

		 if z = winner
       Line width: 4
       Draw inner box
       Line width: 1
		 endif
	 endfor

	 Font size: 10
	 if number_of_steps = 8
		 Select outer viewport: 0, 12, 0, 4
	 elsif number_of_steps = 12
		 Select outer viewport: 0, 12, 0, 6
	 elsif number_of_steps = 16
		 Select outer viewport: 0, 12, 0, 8
	 elsif number_of_steps = 20
		 Select outer viewport: 0, 12, 0, 10
	 elsif number_of_steps = 24
		 Select outer viewport: 0, 12, 0, 12
	 endif
	 Save as 300-dpi PNG file: folder$ + "/file_comparison.png"
 endif
nocheck removeObject: sp

########################################################################################################################################################
########################################################################################################################################################
## Save data and delete backup files


for z from 1 to number_of_steps
	if (save_formant = 1 or save_all_formants = 1) and z = winner
		selectObject: "Formant formants_" + string$(z)
		Save as short text file: folder$ + "/" + basename$ + "_" + string$(winner) +"_.Formant"
	endif
	if save_all_formants = 1 and z <> winner
		selectObject: "Formant formants_" + string$(z)
		Save as short text file: folder$ + "/" + basename$ + "_" + string$(z) +"_.Formant"
	endif
endfor

if save_csv = 1 or return_table = 1
	selectObject: "Table formants_" + string$(winner)
	tbl = selected ("Table")
	@addAcousticInfoToTable: tbl, snd  

  for .i from 1 to number_of_formants
    if output_bandwidth == 0
      Remove column... b'.i'
    endif
    if output_predictions == 0
      Remove column... f'.i'p
    endif
  endfor

  if output_normalized_time == 0
    Insert column: 2, "ntime"
    Formula: "ntime", "row / nrow"
  endif

endif

if save_csv = 1
	selectObject: "Table formants_" + string$(winner)
	Save as comma-separated file: folder$ + "/" + basename$ + ".csv"
endif

if return_table = 0
	selectObject: "Table formants_" + string$(winner)
	Remove
else
	selectObject: "Table formants_" + string$(winner)
	Rename: basename$
endif

for z from 1 to number_of_steps
 if z = winner
	 if return_formant = 1
		 selectObject: "Formant formants_" + string$(z)
		 Rename: basename$
	 endif
 endif
 nocheck removeObject: "Formant formants_" + string$(z)
 nocheck removeObject: "Table formants_" + string$(z)
endfor

if analyze_selection == 1
  removeObject: tmp_snd
endif

selectObject: snd




endwhile

