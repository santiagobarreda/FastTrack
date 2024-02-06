
procedure autoSelectFolder
  createDirectory: folder$ + "/csvs"
  createDirectory: folder$ + "/images_comparison"
  createDirectory: folder$ + "/regression_infos"

  ## read file list
  .file_info = Read Table from comma-separated file: folder$ +"/file_information.csv"
  .nfiles = Get number of rows
  .basename$ = Get value: 1, "file"

  ## get information about previous analysis using the first info file
  .info = Read Strings from raw text file: folder$ + "/infos/" + .basename$-".wav" + "_info.txt"
  .tmp$ = Get string: 3
  number_of_steps = number (.tmp$)

  .tmp$ = Get string: 5
  stringToVector_output# = zero#(number_of_steps)
   @stringToVector: .tmp$
  .cutoffs# = stringToVector_output#

  # this needs to overwrite if user specifies a different order after tracking. 
  # check if new matches old if not re-write.
  .tmp$ = Get string: 7
  number_of_coefficients_for_formant_prediction = number (.tmp$)

  .tmp$ = Get string: 9
  number_of_formants = number (.tmp$)

  winf1coeffs# = zero# (number_of_coefficients_for_formant_prediction+1)
  winf2coeffs# = zero# (number_of_coefficients_for_formant_prediction+1)
  winf3coeffs# = zero# (number_of_coefficients_for_formant_prediction+1)
  
  if number_of_formants == 4
    winf4coeffs# = zero# (number_of_coefficients_for_formant_prediction+1)
  endif

  ## table containing best analysis according to automati selection
  if number_of_formants == 3
    Create Table with column names: "winners", .nfiles, "file winner F1 F2 F3 edit"
  endif
  if number_of_formants == 4
    Create Table with column names: "winners", .nfiles, "file winner F1 F2 F3 F4 edit"
  endif
  ## comparison plot layout information
  .width = 2.85
  .xlims# = {0,.width,.width*2,.width*3,0,.width,.width*2,.width*3,0,.width,.width*2,.width*3,0,.width,.width*2,.width*3,0,.width,.width*2,.width*3,0,.width,.width*2,.width*3}
  .ylims# = {0,0,0,0,2,2,2,2,4,4,4,4,6,6,6,6,8,8,8,8,10,10,10,10}

  ## information for compute time estimate
  daySecond = 0
  @daySecond
  .startSecond = daySecond


  all_errors = Create Table with column names: "allerrors", .nfiles, "e1"
  for .i from 2 to number_of_steps
    Append column: "e" + string$(.i)
  endfor

  all_f1s = Create Table with column names: "allf1s", .nfiles, "a1"
  for .i from 2 to number_of_steps
    Append column: "a" + string$(.i)
  endfor
  all_f2s = Create Table with column names: "allf2s", .nfiles, "a1"
  for .i from 2 to number_of_steps
    Append column: "a" + string$(.i)
  endfor
  all_f3s = Create Table with column names: "allf3s", .nfiles, "a1"
  for .i from 2 to number_of_steps
    Append column: "a" + string$(.i)
  endfor

  #########################################################################################################################
  #########################################################################################################################
  ## main for loop
  for .ii from 1 to .nfiles
    .totalerror# = zero#(number_of_steps)
    .f1Error# = zero#(number_of_steps)
    .f2Error# = zero#(number_of_steps)
    .f3Error# = zero#(number_of_steps)
    if number_of_formants == 4
      .f4Error# = zero#(number_of_steps)
    endif
    formantError# = zero#(4)

    ## to keep track of f4 intercept for roving f4 option
    .f4ints# = zero#(number_of_steps)
    .f4bws# = zero#(number_of_steps)


    .winner = 0
    .cutoff = 0
    .minerror = 9999999999

    selectObject: .file_info 
    .basename$ = Get value: .ii, "file"
    .basename$ = .basename$ - ".wav"
	
	##Optionally show progress
	if show_progress
		writeInfoLine: "Selecting winners (step 2): " +string$(.ii) +" of " + string$(.nfiles) + ", " + .basename$

		## timing part
		if .ii > 10 and .nfiles > 60
		  @daySecond
		  .nowSecond = daySecond
		  .elapsedTime = .nowSecond - .startSecond
		  .totalTime = .elapsedTime * (.nfiles / .ii)
		  .endGuess = .totalTime - .elapsedTime
		  .endGuess = round (.endGuess / 60) ; minus elapsed time?
		  appendInfoLine: "Process should take about " + string$(.endGuess) + " more minutes at current rate."
		  #appendInfoLine: .totalTime
		  #appendInfoLine: .elapsedTime
		endif
	endif
	
    # read in sound and make spectrogram
    .snd = Read from file: folder$ +"/sounds/" + .basename$+ ".wav"
    if save_image = 1
      .sp = noprogress To Spectrogram: 0.007, maximum_plotting_frequency, 0.002, 5, "Gaussian"
      viewstart = Get start time
      viewend = Get end time
      middleTime = (viewstart + viewend) / 2
      Erase all
    endif

    writeFileLine: folder$ + "/regression_infos/" + .basename$ + ".txt","Regression analysis information for: " + .basename$
    appendFileLine: folder$ + "/regression_infos/" + .basename$ + ".txt","number of formants: " + string$(number_of_formants)
    appendFileLine: folder$ + "/regression_infos/" + .basename$ + ".txt","number of coefficients: " + string$(number_of_coefficients_for_formant_prediction)

    ##########################################################################################################
    ## loop across number of analysis steps
    for .z from 1 to number_of_steps
  	  totalerror = 0
      .fr = Read from file: folder$ +"/formants/" + .basename$+ "_" + string$(.z)+"_.Formant"
  	  number_of_frames = Get number of frames

      ##################################################################################
      ## this part determines the winner

  	  @findError: .fr, number_of_coefficients_for_formant_prediction, number_of_formants
      .totalerror#[.z] = sum(formantError#)
      .totalerror#[.z] = round (.totalerror#[.z] * 10) / 10
      .f1Error#[.z] = formantError#[1]
      .f2Error#[.z] = formantError#[2]
      .f3Error#[.z] = formantError#[3]
      if number_of_formants == 4
        .f4Error#[.z] = formantError#[4]
      endif

      selectObject: all_errors
      Set numeric value: .ii, "e"+string$(.z), .totalerror#[.z]

      #.f4ints#[.z] = f4coeffs#[1]
      #.f4bws#[.z] = f4bandwidth

      # creates regression information text files
      appendFileLine: folder$ + "/regression_infos/" + .basename$ + ".txt", formantError#
      appendFileLine: folder$ + "/regression_infos/" + .basename$ + ".txt", f1coeffs#
      appendFileLine: folder$ + "/regression_infos/" + .basename$ + ".txt", f2coeffs#
      appendFileLine: folder$ + "/regression_infos/" + .basename$ + ".txt", f3coeffs#
      if number_of_formants == 4
        appendFileLine: folder$ + "/regression_infos/" + .basename$ + ".txt", f4coeffs#
      endif
      
      # for winning f3 intercept
      winf3 = 0
  	  if .totalerror#[.z] < .minerror
        .minerror = .totalerror#[.z]
        .winner = .z
        .cutoff = .cutoffs#[.z]

        ## get winning f3 intercept
         winf3 = f3coeffs#[1]
        for .jj from 1 to (number_of_coefficients_for_formant_prediction+1)
          winf1coeffs#[.jj] = f1coeffs#[.jj]
          winf2coeffs#[.jj] = f2coeffs#[.jj]
          winf3coeffs#[.jj] = f3coeffs#[.jj]
          if number_of_formants == 4
            winf4coeffs#[.jj] = f4coeffs#[.jj]
          endif
        endfor
        if save_csvs = 1
          nocheck removeObject: "Table tmp"
          selectObject: "Table output"
          Copy: "tmp"
        endif
      endif


      ## writing to files for alternate analysis selection. 
      selectObject: all_f1s
      Set numeric value: .ii, "a"+string$(.z), f1coeffs#[1]
      selectObject: all_f2s
      Set numeric value: .ii, "a"+string$(.z), f2coeffs#[1]
      selectObject: all_f3s
      Set numeric value: .ii, "a"+string$(.z), f3coeffs#[1]

      

      ##################################################################################
      ## makes analysis plot if plot will be made

      if save_image = 1
        Select outer viewport: .xlims#[.z], .xlims#[.z]+3.2, .ylims#[.z], .ylims#[.z]+2
        selectObject: "Table output"
        .tbl = selected ("Table")
        Font size: 8
        @plotTable: .sp, .tbl, maximum_plotting_frequency, 0.5, "Step " + string$(.z) + ", " + string$(.cutoffs#[.z]) + " Hz"
      endif

      removeObject: .fr
      removeObject: "Table output"
    endfor
    appendFileLine: folder$ + "/regression_infos/" + .basename$ + ".txt", "winner is: " + string$(.winner)

    ### secondary selection of an independent F4 winner
    #.f4winner = 0
    #.minf4error = 9999999999
    # go through again and find winning f4. above 2900 and 55 Hz above F3 and bw under 900 and sharpests
    #for .z from 1 to number_of_steps
    #  #if (.f4bws#[.z] < .minf4error) and ((.f4ints#[.z]-winf3)>450)
   	#  if (.f4Error#[.z] < .minf4error) and ((.f4ints#[.z]-winf3)>450)
    #    .minf4error = .f4Error#[.z]
    #    #.minf4error = .f4bws#[.z]
    #    .f4winner = .z
    #  endif
    #endfor


    ##########################################################################################################

    ## saves csv file
    if save_csvs = 1
      selectObject: "Table tmp"
      .tbl = selected ("Table")
      @addAcousticInfoToTable: .tbl, .snd
          
      for .i from 1 to number_of_formants
        if output_bandwidth == 0
          Remove column... b'.i'
        endif
        if output_predictions == 0
          Remove column... f'.i'p
        endif
      endfor
      #add normalized time here

      if output_normalized_time == 0
        Insert column: 2, "ntime"
        Formula: "ntime", "row / nrow"
      endif

      Save as comma-separated file: folder$ + "/csvs/" + .basename$ + ".csv"
      removeObject: "Table tmp"
    endif

    ## adds to winners table
    selectObject: "Table winners"
    Set string value... .ii file '.basename$'
    Set numeric value... .ii winner .winner
    Set numeric value... .ii F1 .winner
    Set numeric value... .ii F2 .winner
    Set numeric value... .ii F3 .winner
    if number_of_formants == 4
  	   #Set numeric value... .ii F4 .f4winner
  	   Set numeric value... .ii F4 .winner
    endif
    Set numeric value... .ii edit 0

    ## add information to info file
    writeFileLine:  folder$ + "/infos/" + .basename$ + "_info.txt", .basename$ + " analysis information:"
    appendFileLine: folder$ + "/infos/" + .basename$ + "_info.txt", "Number of steps:"
    appendFileLine: folder$ + "/infos/" + .basename$ + "_info.txt", number_of_steps
    appendFileLine: folder$ + "/infos/" + .basename$ + "_info.txt", "Cutoff frequencies were: "
    appendFileLine: folder$ + "/infos/" + .basename$ + "_info.txt", .cutoffs#
    appendFileLine: folder$ + "/infos/" + .basename$ + "_info.txt", "Number of coefficients for prediction: "
    appendFileLine: folder$ + "/infos/" + .basename$ + "_info.txt",  number_of_coefficients_for_formant_prediction
    appendFileLine: folder$ + "/infos/" + .basename$ + "_info.txt", "Number of formants: "
    appendFileLine: folder$ + "/infos/" + .basename$ + "_info.txt",  number_of_formants
    appendFileLine: folder$ + "/infos/" + .basename$ + "_info.txt", "Winner is:"
    appendFileLine: folder$ + "/infos/" + .basename$ + "_info.txt", .winner
    ;appendFileLine: folder$ + "/infos/" + .basename$ + "_info.txt", "Best cutoff is:"
    ;appendFileLine: folder$ + "/infos/" + .basename$ + "_info.txt", .cutoff
    if number_of_formants == 3
    appendFileLine: folder$ + "/infos/" + .basename$ + "_info.txt", "Errors (total,f1,f2,f3): "
    endif
    if number_of_formants == 4
    appendFileLine: folder$ + "/infos/" + .basename$ + "_info.txt", "Errors (total,f1,f2,f3,f4): "
    endif
    appendFileLine: folder$ + "/infos/" + .basename$ + "_info.txt", .totalerror#
    appendFileLine: folder$ + "/infos/" + .basename$ + "_info.txt", .f1Error#
    appendFileLine: folder$ + "/infos/" + .basename$ + "_info.txt", .f2Error#
    appendFileLine: folder$ + "/infos/" + .basename$ + "_info.txt", .f3Error#
    if number_of_formants == 4
      appendFileLine: folder$ + "/infos/" + .basename$ + "_info.txt", .f4Error#
    endif
    appendFileLine: folder$ + "/infos/" + .basename$ + "_info.txt", "Coefficients are (row-wise by formant):"
    appendFileLine: folder$ + "/infos/" + .basename$ + "_info.txt", winf1coeffs#
    appendFileLine: folder$ + "/infos/" + .basename$ + "_info.txt", winf2coeffs#
    appendFileLine: folder$ + "/infos/" + .basename$ + "_info.txt", winf3coeffs#
    if number_of_formants == 4
      appendFileLine: folder$ + "/infos/" + .basename$ + "_info.txt", winf4coeffs#
    endif

    ## save image if desired
    if save_image = 1

      Select outer viewport: .xlims#[.winner], .xlims#[.winner]+3.2, .ylims#[.winner], .ylims#[.winner]+2
      Line width: 4
      Draw inner box
      Line width: 1

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
      Save as 300-dpi PNG file: folder$ + "/images_comparison/" + .basename$+"_comparison.png"
    endif

    nocheck removeObject: .snd
    nocheck removeObject: .sp

  endfor
  #########################################################################################################################
  #########################################################################################################################

  createDirectory: folder$ + "/infos_aggregated/"
  
  selectObject: all_errors
  Save as comma-separated file: folder$ + "/infos_aggregated/all_errors.csv"

  selectObject: all_f1s
  Save as comma-separated file: folder$ + "/infos_aggregated/all_f1s.csv"
  selectObject: all_f2s
  Save as comma-separated file: folder$ + "/infos_aggregated/all_f2s.csv"
  selectObject: all_f3s
  Save as comma-separated file: folder$ + "/infos_aggregated/all_f3s.csv"




  selectObject: "Table winners"
  Save as comma-separated file: folder$ + "/winners.csv"
  Save as comma-separated file: folder$ + "/winners_backup.csv"

  removeObject: "Table winners"
  removeObject: .file_info, .info
	removeObject: all_f1s, all_f2s, all_f3s, all_errors

endproc
