
########################################################################################################################################################
########################################################################################################################################################
## Initial setup

include utils/importfunctions.praat


snd = selected ()
basename$ = selected$ ("Sound")
#total_duration = Get total duration

clicked = 2

while clicked == 2

@getSettings

beginPause: "Set Parameters"
	#boolean: "Analyze selection", 0 ;
  optionMenu: "", 1
    option: "[Click to Read]"
    option: "Indicate where you want any output files to go. An image of the output is always saved."
  sentence: "Folder:", folder$
  optionMenu: "", 1
    option: "[Click to Read]"
	option: "Appropriate highest and lowest frequencies will vary as a function of talker vocal-tract length,"
	option: "which is strongly related to height across all speakers. Talkers can be grouped into broad categories of:"
	option: "   tall (>5 foot 8): recommended range 4500-6500 Hz"
	option: "   medium (5 foot 8 >  > 5 foot 0): recommended range 5000-7000 Hz"
	option: "   short (<5 foot 0) recommended range 5500-7500 Hz"
    option: "These categories correspond roughly to adult males, adult females (and some older children),"
    option: "and younger children. However, there is substantial overlap between categories and variation"
    option: "within-category, so that adjustments may be required for individual voices."
	positive: "Lowest analysis frequency (Hz):", lowest_analysis_frequency
	positive: "Highest analysis frequency (Hz):", highest_analysis_frequency
	optionMenu: "", 1
    option: "[Click to Read]"
    option: "Number of analyses between low and high analysis limits. More analysis steps may"
	  option: "improve results, but will increase analysis time and the amount of data generated: "
    option: "50% more steps means a 50% longer analysis time, and 50% more generated files."
	optionMenu: "Number of steps:", number_of_steps
		option: "8"
		option: "12"
		option: "16"
		option: "20"
		option: "24"
	optionMenu: "", 1
    option: "[Click to Read]"
    option: "More coefficients allow for more sudden, and 'wiggly' formant motion."
	positive: "Number of coefficients for formant prediction:", number_of_coefficients_for_formant_prediction
	optionMenu: "", 1
    option: "[Click to Read]"
    option: "The best analysis will be found on average across all desired formants."
    option: "Often, F4 can be difficult to track so that the best analysis including F4"
	  option: "may not be the best analysis for F3 and below. If you only want 3 formants,"
    option: "tracking 3 will ensure the analysis is optimized for those formants."
	optionMenu: "Number of formants", number_of_formants
		option: "3"
		option: "4"
  positive: "Maximum plotting frequency (Hz): ", maximum_plotting_frequency
	optionMenu: "Image", 1
	  option: "Show image of winner"
		option: "Show image comparing of all analyses"
		comment: "Choose which data to save and/or return."
		boolean: "return formant", 0 ;
    boolean: "save formant", 0 ;
		boolean: "save csv", 0 ;
		boolean: "save all formants", 0
		boolean: "return table", 0
    
clicked = endPause: "Ok","Apply", 1
number_of_steps = number(number_of_steps$)
number_of_formants = number(number_of_formants$)


numberOfSelectedSounds  = numberOfSelected ("Sound")
if numberOfSelectedSounds == 1
  snd = selected ()
  basename$ = selected$ ("Sound")
endif

@saveSettings


#if analyze_selection == 1
#	selectObject: snd
#  tmp_snd = Extract selected sound (time from 0)
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

  #if analyze_selection == 1
  #  selectObject: tmp_snd
  #endif

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
  sp = To Spectrogram: 0.007, maximum_plotting_frequency, 0.002, 5, "Gaussian"
  @plotTable: sp, tbl, maximum_plotting_frequency, 1
  removeObject: sp

  # change to save with filename or not
  Save as 300-dpi PNG file: folder$ + "/file_winner.png"
 endif

 if image = 2
	 Erase all
	 ### here is where it would need to write out to a plot
	 selectObject: snd
	 sp = To Spectrogram: 0.007, maximum_plotting_frequency, 0.002, 5, "Gaussian"

	 width = 2.85
	 xlims# = {0,width, width*2,width*3,0,width, width*2,width*3,0,width, width*2, width*3,0,width, width*2, width*3,0,width, width*2, width*3,0,width, width*2, width*3}
	 ylims# = {0,0,0,0,2,2,2,2,4,4,4,4,6,6,6,6,8,8,8,8,10,10,10,10}

	 for z from 1 to number_of_steps
		 Select outer viewport: xlims#[z], xlims#[z]+3.2, ylims#[z], ylims#[z]+2
		 selectObject: "Table formants_" + string$(z)
		 tbl = selected ("Table")
     Font size: 8
		 @plotTable: sp, tbl, maximum_plotting_frequency, 0.5
     #Text: 0.5, "centre", 0.1, "Top", string$(cutoffs#[z])

		 if z = winner
			 Select outer viewport: xlims#[z]-0.1, xlims#[z]+3.3, ylims#[z]-0.1, ylims#[z]+2.1
			 #Draw inner box
			 Select outer viewport: xlims#[z]-0.05, xlims#[z]+3.25, ylims#[z]-0.05, ylims#[z]+2.05
			 #Draw inner box
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

selectObject: snd




endwhile

