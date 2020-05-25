
procedure trackFolder
  createDirectory: folder$ + "/infos/"
  createDirectory: folder$ + "/formants_edited"
  createDirectory: folder$ + "/formants_winners"
  createDirectory: folder$ + "/formants"

  .strs = Create Strings as file list: "list", folder$ + "/sounds/*.wav"
  .nfiles = Get number of strings
  .strsOut = Create Strings as tokens: "", ""

  .analyzed = Create Table with column names: "skipped", .nfiles, "file analyzed"
  Formula: "analyzed", "0"

  @daySecond
  .startSecond = daySecond
  .stepSize = (highest_analysis_frequency-lowest_analysis_frequency) / (number_of_steps-1)

  .cutoffs# = zero#(number_of_steps)
  for .i from 1 to number_of_steps
    .cutoffs#[.i] = round (lowest_analysis_frequency+.stepSize*(.i-1))
  endfor


  for .iii from 1 to .nfiles
  ;for .iii from 6 to 6
    selectObject: "Strings list"
    .basename$ = Get string: .iii
    .snd = Read from file: folder$ + "/sounds/" + .basename$
    .totdur = Get total duration

    selectObject: .analyzed
    Set string value: .iii, "file", .basename$

    
    #writeInfoLine: .totdur, "  ", (number_of_coefficients_for_formant_prediction*2*time_step)
    #appendInfoLine: .totdur > (number_of_coefficients_for_formant_prediction*2*time_step)
    #1+a

    if (.totdur - 0.050) > (number_of_coefficients_for_formant_prediction*2*time_step)
      selectObject: .analyzed
      Set numeric value: .iii, "analyzed", 1

      selectObject: .strsOut
      Insert string: 0, .basename$
      .basename$ = .basename$ - ".wav"

      ## message about expected computing time
      writeInfoLine: "Tracking formants (step 1): " + string$(.iii) +" of " + string$(.nfiles) + ", " + .basename$
      if .iii > 10 and .nfiles > 60
        @daySecond
        .nowSecond = daySecond
        .elapsedTime = .nowSecond - .startSecond
        .totalTime = .elapsedTime * (.nfiles / .iii)
        .endGuess = round (.totalTime / 60)
        appendInfoLine: "Process should take about " + string$(.endGuess) + " more minutes at current rate."
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

    removeObject: .snd
  endfor

  selectObject: .analyzed
  .skipped = Search column: "analyzed", "0"
  if .skipped > 0
    Save as comma-separated file: folder$ +"/skip-log.csv"
  endif

  selectObject: .strsOut
  Save as short text file: folder$ +"/fileList.Strings"
  removeObject: .strs, .strsOut, .analyzed
endproc
