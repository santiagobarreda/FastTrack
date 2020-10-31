
procedure getWinnersFolder
  .winners = Read Table from comma-separated file: folder$ + "/winners.csv"
  .files = Read from file: folder$ + "/fileList.Strings"
  .nfiles = Get number of strings
  .basename$ = Get string: 1


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

	for .counter from 1 to .nfiles
		totalerror = 0
		.winner = 0
		.cutoff = 0
		.minerror = 99999

	  selectObject: .files
	  .basename$ = Get string: .counter
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

		if (.winner = .wf1) & (.wf1 = .wf2) & (.wf3 = .wf3) & (.wf3 = .wf4)
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

  		.snd = Read from file: folder$ + "/sounds/" + .basename$ + ".wav"
			.sp = noprogress To Spectrogram: 0.007, maximum_plotting_frequency, 0.002, 5, "Gaussian"

			Erase all
		  Select outer viewport: 0, 7.5, 0, 4.5
		  @plotTable: .sp, .tbl, maximum_plotting_frequency, 1
			Save as 300-dpi PNG file: folder$ + "/images_winners/" + .basename$ + "_winner_.png"

			@addAcousticInfoToTable: .tbl, .snd
		  selectObject: "Table output"
		  Save as comma-separated file: folder$ + "/csvs/"+ .basename$ + ".csv"

			nocheck removeObject: .tbl, .snd, .tmp_fr, .sp

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

  		.snd = Read from file: folder$ + "/sounds/" + .basename$ + ".wav"
			.sp = noprogress To Spectrogram: 0.007, maximum_plotting_frequency, 0.002, 5, "Gaussian"

			Erase all
		  Select outer viewport: 0, 7.5, 0, 4.5
		  @plotTable: .sp, .tbl, maximum_plotting_frequency, 1
			Save as 300-dpi PNG file: folder$ + "/images_winners/" + .basename$ + "_winner_.png"

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
			nocheck removeObject: .tbl, .snd, .sp, .tmp_f1, .tmp_f2, .tmp_f3, .tmp_f4
	  endif

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
	removeObject: .winners, .files

endproc
