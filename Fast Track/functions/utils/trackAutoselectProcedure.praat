include utils/importFunctions.praat

# procedure for performing analysis with no user interaction
# parameters:
# - .snd: sound object to analyse.
# - .folder$: path to directory for temporary files and final results files.
# - .lowest_analysis_frequency: Lowest analysis frequency (Hz).
# - .highest_analysis_frequency: Highest analysis frequency (Hz).
# - .number_of_steps: the analyses between low and high analysis limits. More analysis
#      steps may improve results, but will increase.
# - .number_of_coefficients_for_formant_prediction: More coefficients allow for more
#      sudden, and 'wiggly' formant motion.
# - .number_of_formants: The best analysis will be found on average across all desired
#      formants. Often, F4 can be difficult to track so that the best analysis including F4.
# - .tracking_method$: "burg" or "robust"
# - .image: image to show after analysis is complete - values can be:
#      0: Don't show an image
#      1: Show image of winner
#      2: Show image comparing of all analyses
# - .snd_to_plot: sound object for plotting.
# - .plot_current_view: if image > 0, whether to plot the view of the current window (1) or not (0)
# - .maximum_plotting_frequency: if image > 0, maximum frequency for image.
# - .output_formant: how to return the winning formant object - values can be:
#      0: Don't return the winning formant
#      1: Save a formant object to a file named after the sound
#      2: Leave a formant object named after the sound in the Objects list
#      3: Both 1 and 2
# - .output_table: how to return the table of winning formant measurements - values can be:
#      0: Don't return the winning formant
#      1: Save the measurements to a CVS file named after the sound
#      2: Leave a table object named after the sound in the Objects list
#      3: Both 1 and 2
# - .output_all_candidates: how to return all formant objects - values can be:
#      0: Don't return the all candidate formants
#      1: Save all formant candidates to files named after the sound
# outputs:
# Apart from the output objects/files specified by the parameters, the procedure also sets the
# following output variabls:
# - trackAutoselect.cutoff
# - trackAutoselect.f1coeffs# - Vector of coefficients for F1
# - trackAutoselect.f2coeffs# - Vector of coefficients for F2
# - trackAutoselect.f3coeffs# - Vector of coefficients for F3
# - trackAutoselect.f4coeffs# - Vector of coefficients for F4 (if .number_of_formants = 4)

procedure trackAutoselect: .snd, .folder$, .lowest_analysis_frequency, .highest_analysis_frequency, .number_of_steps, .number_of_coefficients_for_formant_prediction, .number_of_formants, .tracking_method$, .image, .snd_to_plot, .plot_current_view, .maximum_plotting_frequency, .output_formant, .output_table, .output_all_candidates

  # make sure the given sound object is selected
  selectObject: .snd
  .basename$ = selected$ ("Sound")
  
  ########################################################################################################################################################
  ########################################################################################################################################################
  ## Error estimation section
  
  # error related variables
  # this is a global variable output from modeling/findError
  formantError# = zero#(.number_of_formants)
  .minerror = 999999
  .error# =  zero# (.number_of_steps)
  .cutoffs# = zero#(.number_of_steps)
  
  # determine analysis frequencies given number of steps and cutoffs
  .stepSize = (.highest_analysis_frequency-.lowest_analysis_frequency) / (.number_of_steps-1)
  for i from 1 to .number_of_steps
    .cutoffs#[i] = round (.lowest_analysis_frequency+.stepSize*(i-1))
  endfor
    
  .winner = 1
  
  ## loop that performs the analyses
  for z from 1 to .number_of_steps
    selectObject: .snd
  
    # analysis of sounds
    if .tracking_method$ == "burg"
      noprogress To Formant (burg): time_step, 5.5, .cutoffs#[z], 0.025, 50
    endif
    if .tracking_method$ == "robust"
      noprogress To Formant (robust): time_step, 5.5, .cutoffs#[z], 0.025, 50, 1.5, 5, 1e-006
    endif
    Rename: "formants_" + string$(z)
    .formantObject = selected ("Formant")
  
    # this is where the contours actually get modeled. check this function out for info.
    # it also created a lot of useful variables like the coefficient and error vectors that get used below.
    # in praat these are all global variables, functions dont return results. 
    @findError: .formantObject, .number_of_coefficients_for_formant_prediction
    Rename: "formants_" + string$(z)
  
    # if current step minimizes the error, make it the new winner
    if .error#[z] <  .minerror
      .winner = z
      .cutoff = .cutoffs#[z]
      .minerror = .error#[z]
  
      # store regression coefficients for output in info window
      # TODO f1coeffs#, f2coeffs#, f3coeffs#, f4coeffs# are outputs of findError
      .f1coeffs# = f1coeffs#
      .f2coeffs# = f2coeffs#
      .f3coeffs# = f3coeffs#
      if .number_of_formants == 4
        .f4coeffs# = f4coeffs#
      endif
    endif
  
    .error#[z] = sum(formantError#)
    .error#[z] = round (.error#[z] * 10) / 10
    
  endfor
    
  ########################################################################################################################################################
  ########################################################################################################################################################
  ## Plot
  
  if .image = 1
    Erase all
    Select outer viewport: 0, 7.5, 0, 4.5
    selectObject: "Table formants_" + string$(.winner)
    .tbl = selected ("Table")
    selectObject: .snd_to_plot
  
    ## if NOT current view
    if .plot_current_view = 0
      .sp = To Spectrogram: 0.007, .maximum_plotting_frequency, 0.002, 5, "Gaussian"
      @plotTable: .sp, .tbl, .maximum_plotting_frequency, 1, "Maximum formant = " + string$(.cutoff) + " Hz"
      removeObject: .sp
    endif
  
    # if YEs current view, this needs to grab the current spectrogram from the view window and plot it.
    # analysis also needs to be scaled to the frequency limit of the view so that these match. 
    if .plot_current_view = 1
      editor: .snd_to_plot 
      .sp = Extract visible spectrogram
      info$ = Editor info
      .maximum_plotting_frequency = extractNumber (info$, "Spectrogram view to: ")
      endeditor
      selectObject: .sp
      @plotTable: .sp, .tbl, .maximum_plotting_frequency, 1, "Maximum formant = " + string$(.cutoff) + " Hz"
      removeObject: .sp
    endif
    # change to save with filename or not
    Save as 300-dpi PNG file: .folder$ + "/file_winner.png"
  endif
  
  # this is for the comparison images. pretty straightforward
  if .image = 2
    Erase all
    selectObject: .snd_to_plot
   
    .sp = To Spectrogram: 0.007, .maximum_plotting_frequency, 0.002, 5, "Gaussian"
  
    width = 2.85
    .xlims# = {0,width, width*2,width*3,0,width, width*2,width*3,0,width, width*2, width*3,0,width, width*2, width*3,0,width, width*2, width*3,0,width, width*2, width*3}
    .ylims# = {0,0,0,0,2,2,2,2,4,4,4,4,6,6,6,6,8,8,8,8,10,10,10,10}
    
    for z from 1 to .number_of_steps
      Select outer viewport: .xlims#[z], .xlims#[z]+3.2, .ylims#[z], .ylims#[z]+2
      selectObject: "Table formants_" + string$(z)
      .tbl = selected ("Table")
      Font size: 8
      @plotTable: .sp, .tbl, .maximum_plotting_frequency, 1, "Maximum formant = " + string$(.cutoffs#[z]) + " Hz"
  
      if z = .winner
         Line width: 4
         Draw inner box
         Line width: 1
      endif
    endfor
  
    Font size: 10
    if .number_of_steps = 8
      Select outer viewport: 0, 12, 0, 4
    elsif .number_of_steps = 12
      Select outer viewport: 0, 12, 0, 6
    elsif .number_of_steps = 16
      Select outer viewport: 0, 12, 0, 8
    elsif .number_of_steps = 20
      Select outer viewport: 0, 12, 0, 10
    elsif .number_of_steps = 24
      Select outer viewport: 0, 12, 0, 12
    endif
    Save as 300-dpi PNG file: .folder$ + "/file_comparison.png"
  endif
  nocheck removeObject: .sp
  
  ########################################################################################################################################################
  ########################################################################################################################################################
  ## Save data and delete backup files. nothing fancy here. a lot of removing objects
  
  
  for z from 1 to .number_of_steps
  	# (.output_...: 1=save, 2=return, 3=both)
  	if (.output_formant = 1 or .output_formant = 3 or .output_all_candidates = 1) and z = .winner
  		selectObject: "Formant formants_" + string$(z)
  		Save as short text file: .folder$ + "/" + .basename$ + "_" + string$(.winner) +"_.Formant"
  	endif
  	if .output_all_candidates = 1 and z <> .winner
  		selectObject: "Formant formants_" + string$(z)
  		Save as short text file: .folder$ + "/" + .basename$ + "_" + string$(z) +"_.Formant"
  	endif
  endfor

  # (.output_...: 1=save, 2=return, 3=both)
  if .output_table > 0
    selectObject: "Table formants_" + string$(.winner)
    .tbl = selected ("Table")
    @addAcousticInfoToTable: .tbl, .snd  
    
    for .i from 1 to .number_of_formants
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

  # (.output_...: 1=save, 2=return, 3=both)
  if .output_table = 1 or .output_table = 3
  	selectObject: "Table formants_" + string$(.winner)
  	Save as comma-separated file: .folder$ + "/" + .basename$ + ".csv"
  endif  
  if .output_table >= 2
  	selectObject: "Table formants_" + string$(.winner)
  	Rename: .basename$
  else
  	selectObject: "Table formants_" + string$(.winner)
  	Remove
  endif
  
  for z from 1 to .number_of_steps
   if z = .winner
  	 # (.output_...: 1=save, 2=return, 3=both)
  	 if .output_formant >= 2
  		 selectObject: "Formant formants_" + string$(z)
  		 Rename: .basename$
  	 endif
   endif
   nocheck removeObject: "Formant formants_" + string$(z)
   nocheck removeObject: "Table formants_" + string$(z)
  endfor
    
endproc
