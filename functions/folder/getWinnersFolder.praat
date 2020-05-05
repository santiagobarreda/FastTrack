
procedure getWinnersFolder
	.winners = Read Table from comma-separated file: folder$ + "/winners.csv"
	.files = Read from file: folder$ + "/fileList.Strings"
	.nfiles = Get number of strings
	.basename$ = Get string: 1

	## read file list
  .strs = Read from file: folder$ +"/fileList.Strings"
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


	createDirectory: folder$ + "/images_winners"

	daySecond = 0
	@daySecond
  .startSecond = daySecond

	for .iii from 1 to .nfiles
		totalerror = 0
		.winner = 0
		.cutoff = 0
		.minerror = 999

	  selectObject: .files
	  .basename$ = Get string: .iii
	  .basename$ = .basename$ - ".wav"
		.info = Read Strings from raw text file: folder$ + "/infos/" + .basename$-".wav" + "_info.txt"

	  selectObject: .winners
	  .winner = Get value: .iii, "winner"
	  .wf1 = Get value: .iii, "F1"
	  .wf2 = Get value: .iii, "F2"
	  .wf3 = Get value: .iii, "F3"
		if number_of_formants == 3
	  	.wf4 = .wf3
		endif
		if number_of_formants == 4
			.wf4 = Get value: .iii, "F4"
		endif

    selectObject: .info
		if number_of_formants == 3
			Set string: 11, string$(.wf1)+" "+string$(.wf2)+" "+string$(.wf3)
		endif
		if number_of_formants == 4
			Set string: 11, string$(.wf1)+" "+string$(.wf2)+" "+string$(.wf3)+" "+string$(.wf4)
		endif

		writeInfoLine: "Getting winners (step 3): " + string$(.iii) +" of " + string$(.nfiles) + ", " + .basename$
		if .iii > 10 and .nfiles > 60
			daySecond = 0
			@daySecond
			.nowSecond = daySecond
			.elapsedTime = .nowSecond - .startSecond
	    .totalTime = .elapsedTime * (.nfiles / .iii)
	    .endGuess = round (.totalTime / 60)
	    appendInfoLine: "Process should take about " + string$(.endGuess) + " more minutes at current rate."
	  endif

		if (.winner = .wf1) & (.wf1 = .wf2) & (.wf3 = .wf3) & (.wf3 = .wf4)
	  	.tmp_fr = Read from file: folder$ + "/formants/"+ .basename$ + "_" + string$(.winner) + "_.Formant"
	   	Save as short text file: folder$ + "/formants_winners/" + .basename$ + "_winner_.Formant"

		  @findError: .tmp_fr
			for .jj from 1 to (number_of_coefficients_for_formant_prediction+1)
				winf1coeffs#[.jj] = f1coeffs[.jj]
				winf2coeffs#[.jj] = f2coeffs[.jj]
				winf3coeffs#[.jj] = f3coeffs[.jj]
				if number_of_formants == 4
					winf4coeffs#[.jj] = f4coeffs[.jj]
				endif
			endfor
		  selectObject: "Table output"
		  .tbl = selected ("Table")

  		.snd = Read from file: folder$ + "/sounds/" + .basename$ + ".wav"
			.sp = noprogress To Spectrogram: 0.007, maximum_plotting_frequency, 0.002, 5, "Gaussian"

			Erase all
		  Select outer viewport: 0, 7.5, 0, 4.5
		  @plotTable: .sp, .tbl, maximum_plotting_frequency
			Save as 300-dpi PNG file: folder$ + "/images_winners/" + .basename$ + "_winner_.png"

			@addAcousticInfoToTable: .tbl, .snd
		  selectObject: "Table output"
		  Save as comma-separated file: folder$ + "/csvs/"+ .basename$ + ".csv"

			nocheck removeObject: .tbl, .snd, .tmp_fr, .sp
		endif

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
	      Formula (frequencies): "if row = 3 and col=" + string$(.j) +" then " + string$(.tf3) + " else self endif"
	      Formula (bandwidths): "if row = 3 and col=" + string$(.j) +" then " + string$(.tb3) + " else self endif"
				if number_of_formants == 4
					selectObject: .tmp_f4
					.tf4 = Get value at time: 4, .tmp_time, "hertz", "Linear"
					.tb4 = Get bandwidth at time: 4, .tmp_time, "hertz", "Linear"
	      	Formula (frequencies): "if row = 4 and col=" + string$(.j) +" then " + string$(.tf4) + " else self endif"
	      	Formula (bandwidths): "if row = 4 and col=" + string$(.j) +" then " + string$(.tb4) + " else self endif"
				endif

	    endfor

	    selectObject: .tmp_f1
	    Save as short text file: folder$ + "/formants_winners/" + .basename$ + "_winner_.Formant"

			if (save_images = 1) or (save_csvs = 1)
				snd = Read from file: folder$ + "/sounds/" + .basename$ + ".wav"
				@makeFormantTable: .tmp_fr
			  @findError
				for .jj from 1 to (number_of_coefficients_for_formant_prediction+1)
					winf1coeffs#[.jj] = f1coeffs[.jj]
					winf2coeffs#[.jj] = f2coeffs[.jj]
					winf3coeffs#[.jj] = f3coeffs[.jj]
					if number_of_formants == 4
						winf4coeffs#[.jj] = f4coeffs[.jj]
					endif
				endfor
			  selectObject: "Table output"
			  .tbl = selected ("Table")
			  #nrows = Get number of rows   #delete?
			endif
	  	if save_images = 1
				selectObject: .snd
				.sp = noprogress To Spectrogram: 0.007, maximum_plotting_frequency, 0.002, 5, "Gaussian"

				Erase all
			  Select outer viewport: 0, 7.5, 0, 4.5
			  @plotTable: .sp, .tbl, maximum_plotting_frequency
				Save as 300-dpi PNG file: folder$ + "/images_winners/" + .basename$ + "_winner_.png"
			endif
			if save_csvs = 1
				@addAcousticInfoToTable: .tbl
			  selectObject: "Table output"
			  Save as comma-separated file: folder$ + "/csvs/" + .basename$ + ".csv"
			endif

			nocheck removeObject: .tbl, .snd, .tmp_f1, .tmp_f2, .tmp_f3, .tmp_f4, .sp
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
