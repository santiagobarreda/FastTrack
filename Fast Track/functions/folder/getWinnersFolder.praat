
procedure getWinnersFolder
  .winners = Read Table from comma-separated file: folder$ + "/winners.csv"
  
  .file_info = Read Table from comma-separated file: folder$ +"/file_information.csv"
  .nfiles = Get number of rows
  .basename$ = Get value: 1, "file"

  winf1coeffs# = zero# (number_of_coefficients_for_formant_prediction+1)
  winf2coeffs# = zero# (number_of_coefficients_for_formant_prediction+1)
  winf3coeffs# = zero# (number_of_coefficients_for_formant_prediction+1)
  winf4coeffs# = zero# (number_of_coefficients_for_formant_prediction+1)

  ## get information about previous analysis using the first info file
  .info = Read Strings from raw text file: folder$ + "/infos/" + .basename$-".wav" + "_info.txt"
  .tmp$ = Get string: 3
  number_of_steps = number (.tmp$)

  .tmp$ = Get string: 5
  stringToVector_output# = zero#(number_of_steps)
   @stringToVector: .tmp$
  .cutoffs# = stringToVector_output#

  .tmp$ = Get string: 7
  number_of_coefficients_for_formant_prediction = number (.tmp$)

  .tmp$ = Get string: 9
  number_of_formants = number (.tmp$)

  .tmp$ = Get string: 13
  @stringToVector: .tmp$
  .totalerror# = stringToVector_output#

  removeObject: .info
		
  createDirectory: folder$ + "/images_winners"

  daySecond = 0
  @daySecond
  .startSecond = daySecond

	bounds_specified = 0
	if fileReadable ("/../dat/formantbounds.csv")
		.formant_bounds = Read Table from comma-separated file: "/../dat/formantbounds.csv"	
		.all_errors = Read Table from comma-separated file: folder$ +"/infos_aggregated/all_errors.csv"
		.all_f1s = Read Table from comma-separated file: folder$ +"/infos_aggregated/all_f1s.csv"
		.all_f2s = Read Table from comma-separated file: folder$ +"/infos_aggregated/all_f2s.csv"
		.all_f3s = Read Table from comma-separated file: folder$ +"/infos_aggregated/all_f3s.csv"
		bounds_specified = 1		
	endif

  for .counter from 1 to .nfiles
		totalerror = 0
		.winner = 0
		.cutoff = 0
		.minerror = 99999

    selectObject: .file_info 
    .basename$ = Get value: .counter, "file"
    .basename$ = .basename$ - ".wav"
		.info = Read Strings from raw text file: folder$ + "/infos/" + .basename$-".wav" + "_info.txt"

		selectObject: .winners
		.winner = Get value: .counter, "winner"
		.wf1 = Get value: .counter, "F1"
		.wf2 = Get value: .counter, "F2"
		.wf3 = Get value: .counter, "F3"
		if number_of_formants == 3
	  	.wf4 = .wf3
	  endif
	  if number_of_formants == 4
	    .wf4 = Get value: .counter, "F4"
	  endif

    selectObject: .info
	  if number_of_formants == 3
	 		Set string: 11, string$(.wf1)+" "+string$(.wf2)+" "+string$(.wf3)
	  endif
	  if number_of_formants == 4
	 		Set string: 11, string$(.wf1)+" "+string$(.wf2)+" "+string$(.wf3)+" "+string$(.wf4)
	  endif

	  writeInfoLine: "Getting winners (step 3): " + string$(.counter) +" of " + string$(.nfiles) + ", " + .basename$
	  if .counter > 10 and .nfiles > 60
			daySecond = 0
			@daySecond
			.nowSecond = daySecond
			.elapsedTime = .nowSecond - .startSecond
	    .totalTime = .elapsedTime * (.nfiles / .counter)
	    .endGuess = round (.totalTime / 60)
	    appendInfoLine: "Process should take about " + string$(.endGuess) + " more minutes at current rate."
	  endif

		.tmp_info = Read Strings from raw text file: folder$ + "/infos/" + .basename$ + "_info.txt"
    .tmp$ = Get string: 11
    stringToVector_output# = zero#(number_of_formants)
    @stringToVector: .tmp$
    .winning_cutoff = stringToVector_output#[1] 
    removeObject: .tmp_info

		## read in the sound file being considered
  	.snd = Read from file: folder$ + "/sounds/" + .basename$ + ".wav"

		##### This block is for the basic situation where all formants are from the same cutoff.
		if (.winner = .wf1) & (.wf1 = .wf2) & (.wf3 = .wf3) & (.wf3 = .wf4)
   		## I should add heuristics here. do other check here and affect winners not errors. add column in winners column where smoothest
  		## was not chosen due to some reason. never need to redo analyses

			if bounds_specified == 1 
				selectObject: .file_info
				current_label$ = Get value: .counter, "label"
				selectObject: .formant_bounds 
				spot = Search column: "label", current_label$

        #writeInfoLine: current_label$
				#1+i
				if spot > 0
					selectObject: .formant_bounds 
					f1lower = Get value: spot, "f1lower"
					f1upper = Get value: spot, "f1upper"
					f2lower = Get value: spot, "f2lower"
					f2upper = Get value: spot, "f2upper"
					f3lower = Get value: spot, "f3lower"
					f3upper = Get value: spot, "f3upper"

					selectObject: .all_f1s 
					wf1 = Get value: .counter, "a" + string$(.winner)
					selectObject: .all_f2s 
					wf2 = Get value: .counter, "a" + string$(.winner)
					selectObject: .all_f3s 
					wf3 = Get value: .counter, "a" + string$(.winner)

          ## if any of the winning formants fall outside the bounds set, look for any alternative. 
					## the smoothest alternative will be chosen, this may be terrible!
					
					writeInfoLine: wf1, " ",wf2, " ",wf3, " "
					appendInfoLine: f1lower, " ",f1upper, " ",f2lower, " ",f2upper, " ",f3lower, " ",f3upper, " "

					if (f1lower>wf1) or (f1upper<wf1) or (f2lower>wf2) or (f2upper<wf2) or (f3lower>wf3) or (f3upper<wf3)
					  tmpMinError = 1000000

						for .j from 1 to number_of_steps
							selectObject: .all_errors 
							tmpe = Get value: .counter, "e" + string$(.j) 
							selectObject: .all_f1s 
							tmpf1 = Get value: .counter, "a" + string$(.j)
							selectObject: .all_f2s 
							tmpf2 = Get value: .counter, "a" + string$(.j)
							selectObject: .all_f3s 
							tmpf3 = Get value: .counter, "a" + string$(.j)

							## check if a candidate has ALL permissible formant estimates and if so take the analysis with the lowest error as new winner. 
							if (f1lower<tmpf1) and (f1upper>tmpf1) and (f2lower<tmpf2) and (f2upper>tmpf2) and (f3lower<tmpf3) and (f3upper>tmpf3)
                if tmpe < tmpMinError
									.winner = .j
									.winning_cutoff = .cutoffs#[.j]
									tmpMinError = tmpe
								endif
							endif		
						endfor
					endif
				endif
			endif


	  	.tmp_fr = Read from file: folder$ + "/formants/"+ .basename$ + "_" + string$(.winner) + "_.Formant"
	   	Save as short text file: folder$ + "/formants_winners/" + .basename$ + "_winner_.Formant"

		  @findError: .tmp_fr
			for .jj from 1 to (number_of_coefficients_for_formant_prediction+1)
				winf1coeffs#[.jj] = f1coeffs#[.jj]
				winf2coeffs#[.jj] = f2coeffs#[.jj]
				winf3coeffs#[.jj] = f3coeffs#[.jj]
				if number_of_formants == 4
					winf4coeffs#[.jj] = f4coeffs#[.jj]
				endif
			endfor
		  selectObject: "Table output"
		  .tbl = selected ("Table")
			@addAcousticInfoToTable: .tbl, .snd
		  selectObject: "Table output"
		  Save as comma-separated file: folder$ + "/csvs/"+ .basename$ + ".csv"

			nocheck removeObject: .tmp_fr

		##### This is for the more ocmplicated situation where different formants are taken from different analyses.
		else

	    .tmp_f1 = Read from file: folder$ + "/formants/"+ .basename$ + "_" + string$(.wf1) + "_.Formant"
	    .number_of_frames = Get number of frames
	    .tmp_f2 = Read from file: folder$ + "/formants/"+ .basename$ + "_" + string$(.wf2) + "_.Formant"
	    .tmp_f3 = Read from file: folder$ + "/formants/"+ .basename$ + "_" + string$(.wf3) + "_.Formant"
	    .tmp_f4 = Read from file: folder$ + "/formants/"+ .basename$ + "_" + string$(.wf4) + "_.Formant"

			for .j from 1 to .number_of_frames
	      selectObject: .tmp_f1
	      .tmp_time = Get time from frame number: .j
	      selectObject: .tmp_f2
	      .tf2 = Get value at time: 2, .tmp_time, "hertz", "Linear"
	      .tb2 = Get bandwidth at time: 2, .tmp_time, "hertz", "Linear"
	      selectObject: .tmp_f3
	      .tf3 = Get value at time: 3, .tmp_time, "hertz", "Linear"
	      .tb3 = Get bandwidth at time: 3, .tmp_time, "hertz", "Linear"

	      selectObject: .tmp_f1
        Formula (frequencies): "if row = 2 and col=" + string$(.j) +" then " + string$(.tf2) + " else self endif"
        Formula (bandwidths): "if row = 2 and col=" + string$(.j) +" then " + string$(.tb2) + " else self endif"
        if (.tf3 <> undefined)
          Formula (frequencies): "if row = 3 and col=" + string$(.j) +" then " + string$(.tf3) + " else self endif"
          Formula (bandwidths): "if row = 3 and col=" + string$(.j) +" then " + string$(.tb3) + " else self endif"
        endif
				if (number_of_formants == 4) 
					selectObject: .tmp_f4
          .tf4 = Get value at time: 4, .tmp_time, "hertz", "Linear"
          .tb4 = Get bandwidth at time: 4, .tmp_time, "hertz", "Linear"
          if (.tf4 <> undefined)
     	      selectObject: .tmp_f1
            Formula (frequencies): "if row = 4 and col=" + string$(.j) +" then " + string$(.tf4) + " else self endif"
            Formula (bandwidths): "if row = 4 and col=" + string$(.j) +" then " + string$(.tb4) + " else self endif"
          endif
				endif
	    endfor

	    selectObject: .tmp_f1
	    Save as short text file: folder$ + "/formants_winners/" + .basename$ + "_winner_.Formant"
			@findError: .tmp_f1
			for .jj from 1 to (number_of_coefficients_for_formant_prediction+1)
				winf1coeffs#[.jj] = f1coeffs#[.jj]
				winf2coeffs#[.jj] = f2coeffs#[.jj]
				winf3coeffs#[.jj] = f3coeffs#[.jj]
				if number_of_formants == 4
					winf4coeffs#[.jj] = f4coeffs#[.jj]
				endif
			endfor
		  selectObject: "Table output"
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
      
      if output_normalized_time == 0
        Insert column: 2, "ntime"
        Formula: "ntime", "row / nrow"
      endif

		  selectObject: "Table output"
		  Save as comma-separated file: folder$ + "/csvs/"+ .basename$ + ".csv"
			nocheck removeObject: .tmp_f1, .tmp_f2, .tmp_f3, .tmp_f4
	  endif
		#### alternate formant collection ends here



    if save_images == 1
			selectObject: .snd
			.sp = noprogress To Spectrogram: 0.007, maximum_plotting_frequency, 0.002, 5, "Gaussian"
			Erase all
			Select outer viewport: 0, 7.5, 0, 4.5
			@plotTable: .sp, .tbl, maximum_plotting_frequency, 1 ,"Maximum formant = " + string$(.winning_cutoff) + " Hz"			
			Save as 300-dpi PNG file: folder$ + "/images_winners/" + .basename$ + "_winner_.png"
			removeObject: .sp
		endif 
		removeObject: .snd, .tbl

		selectObject: .info
		if number_of_formants==3
			Set string: 11, string$(.cutoffs#[.wf1]) + " " + string$(.cutoffs#[.wf2]) + " " + string$(.cutoffs#[.wf3])
	  endif
		if number_of_formants==4
		  Set string: 11, string$(.cutoffs#[.wf1]) + " " + string$(.cutoffs#[.wf2]) + " " + string$(.cutoffs#[.wf3])+ " " + string$(.cutoffs#[.wf4])
		endif

		if number_of_formants==3
			@vectorToString: winf1coeffs#
			Set string: 18, vectorToString_output$
			@vectorToString: winf2coeffs#
			Set string: 19, vectorToString_output$
			@vectorToString: winf3coeffs#
			Set string: 20, vectorToString_output$
		endif
		if number_of_formants==4
			@vectorToString: winf1coeffs#
			Set string: 19, vectorToString_output$
			@vectorToString: winf2coeffs#
			Set string: 20, vectorToString_output$
			@vectorToString: winf3coeffs#
			Set string: 21, vectorToString_output$
			@vectorToString: winf4coeffs#
			Set string: 22, vectorToString_output$
		endif
		Save as raw text file: folder$ + "/infos/" + .basename$ + "_info.txt"

		removeObject: .info
	endfor
	removeObject: .winners, .file_info, .all_f1s, .all_f2s, .all_f3s, .all_errors

endproc
