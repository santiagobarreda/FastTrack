
procedure trackFolder
  createDirectory: folder$ + "/infos/"
  createDirectory: folder$ + "/formants"

  @daySecond
  .startSecond = daySecond
  .stepSize = (highest_analysis_frequency-lowest_analysis_frequency) / (number_of_steps-1)

  .cutoffs# = zero#(number_of_steps)
  for .i from 1 to number_of_steps
    .cutoffs#[.i] = round (lowest_analysis_frequency+.stepSize*(.i-1))
  endfor

  if !fileReadable: folder$ + "/file_information.csv"
    @prepareFileInfo: 1
  endif

  file_info = Read Table from comma-separated file: folder$ + "/file_information.csv"
  selectObject: file_info
  Append column: "omit"
  .nfiles = Get number of rows

  for .iii from 1 to .nfiles
    selectObject: file_info
    .basename$ = Get value: .iii, "file"
    .snd = Read from file: folder$ + "/sounds/" + .basename$
    .totdur = Get total duration
  
    if (.totdur - 0.050) > (number_of_coefficients_for_formant_prediction*2*time_step)
      selectObject: file_info
      Set numeric value: .iii, "omit", 0

      .basename$ = .basename$ - ".wav"

      ## message about expected computing time
	  if show_progress
		  writeInfoLine: "Tracking formants (step 1): " + string$(.iii) +" of " + string$(.nfiles) + ", " + .basename$
		  if .iii > 10 and .nfiles > 60
			@daySecond
			.nowSecond = daySecond
			.elapsedTime = .nowSecond - .startSecond
			.totalTime = .elapsedTime * (.nfiles / .iii)
			.endGuess = round (.totalTime / 60)
			appendInfoLine: "Process should take about " + string$(.endGuess) + " more minutes at current rate."
		  endif
      endif

      for .z from 1 to number_of_steps
        selectObject: .snd
        if tracking_method$ == "burg"
          noprogress To Formant (burg): time_step, 5.5, .cutoffs#[.z], 0.025, 50
        endif
        if tracking_method$ == "robust"
          noprogress To Formant (robust): time_step, 5.5, .cutoffs#[.z], 0.025, 50, 1.5, 5, 1e-006
        endif

        Save as short text file: folder$ + "/formants/" + .basename$ + "_" + string$(.z) +"_.Formant"
        Remove

        writeFileLine:  folder$ + "/infos/" + .basename$ + "_info.txt", .basename$ + ".wav"
        appendFileLine: folder$ + "/infos/" + .basename$ + "_info.txt", "Number of steps:"
        appendFileLine: folder$ + "/infos/" + .basename$ + "_info.txt", number_of_steps
        appendFileLine: folder$ + "/infos/" + .basename$ + "_info.txt", "Cutoff frequencies were: "
        appendFileLine: folder$ + "/infos/" + .basename$ + "_info.txt",  .cutoffs#
        appendFileLine: folder$ + "/infos/" + .basename$ + "_info.txt", "Number of coefficients for prediction: "
        appendFileLine: folder$ + "/infos/" + .basename$ + "_info.txt",  number_of_coefficients_for_formant_prediction
        appendFileLine: folder$ + "/infos/" + .basename$ + "_info.txt", "Number of formants: "
        appendFileLine: folder$ + "/infos/" + .basename$ + "_info.txt",  number_of_formants
      endfor
    endif
    if (.totdur - 0.050) < (number_of_coefficients_for_formant_prediction*2*time_step)
      selectObject: file_info
      Set numeric value: .iii, "omit", 1
    endif
    removeObject: .snd
  endfor

  selectObject: file_info
  analyzed = Extract rows where column (number): "omit", "not equal to", 1
  Remove column: "omit"
  Save as comma-separated file: folder$ + "/file_information.csv"

  removeObject: file_info, analyzed
endproc
