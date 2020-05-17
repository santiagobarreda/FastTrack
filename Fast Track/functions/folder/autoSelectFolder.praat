
procedure autoSelectFolder
  createDirectory: folder$ + "/csvs"
  createDirectory: folder$ + "/images_comparison"
  createDirectory: folder$ + "/regression_infos"

  ## read file list
  .strs = Read from file: folder$ +"/fileList.Strings"
  .nfiles = Get number of strings
  .basename$ = Get string: 1

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

    .winner = 0
    .cutoff = 0
    .minerror = 9999999999

    selectObject: .strs
    .basename$ = Get string: .ii
    .basename$ = .basename$ - ".wav"
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
      appendInfoLine: .totalTime
      appendInfoLine: .elapsedTime
    endif

   # read in sound and make spectrogram
    .snd = Read from file: folder$ +"/sounds/" + .basename$+ ".wav"
    if save_image = 1
      .sp = noprogress To Spectrogram: 0.007, maximum_plotting_frequency, 0.002, 5, "Gaussian"
      Erase all
    endif

    writeFileLine: folder$ + "/regression_infos/" + .basename$ + ".txt","Regression analysis information for: " + .basename$
    appendFileLine: folder$ + "/regression_infos/" + .basename$ + ".txt","number of formants: " + string$(number_of_formants)
    appendFileLine: folder$ + "/regression_infos/" + .basename$ + ".txt","number of coeccicients: " + string$(number_of_coefficients_for_formant_prediction)

    ##########################################################################################################
    ## loop across number of analysis steps
    for .z from 1 to number_of_steps
  	  totalerror = 0
      .fr = Read from file: folder$ +"/formants/" + .basename$+ "_" + string$(.z)+"_.Formant"
  	  number_of_frames = Get number of frames

      ##################################################################################
      ## this part determines the winner

  	  @findError: .fr
      .totalerror#[.z] = sum(formantError#)
      .totalerror#[.z] = round (.totalerror#[.z] * 10) / 10
      .f1Error#[.z] = formantError#[1]
      .f2Error#[.z] = formantError#[2]
      .f3Error#[.z] = formantError#[3]
      if number_of_formants == 4
        .f4Error#[.z] = formantError#[4]
      endif

      # creates regression information text files
      appendFileLine: folder$ + "/regression_infos/" + .basename$ + ".txt", formantError#
      appendFileLine: folder$ + "/regression_infos/" + .basename$ + ".txt", f1coeffs#
      appendFileLine: folder$ + "/regression_infos/" + .basename$ + ".txt", f2coeffs#
      appendFileLine: folder$ + "/regression_infos/" + .basename$ + ".txt", f3coeffs#
      if number_of_formants == 4
        appendFileLine: folder$ + "/regression_infos/" + .basename$ + ".txt", f4coeffs#
      endif

  	  if .totalerror#[.z] < .minerror
        .minerror = .totalerror#[.z]
        .winner = .z
        .cutoff = .cutoffs#[.z]
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

      ##################################################################################
      ## makes analysis plot if plot will be made

      if save_image = 1
        Select outer viewport: .xlims#[.z], .xlims#[.z]+3.2, .ylims#[.z], .ylims#[.z]+2
        selectObject: "Table output"
        .tbl = selected ("Table")
        Font size: 8
        @plotTable: .sp, .tbl, maximum_plotting_frequency, 0.5
      endif

      removeObject: .fr
      removeObject: "Table output"
    endfor
    appendFileLine: folder$ + "/regression_infos/" + .basename$ + ".txt", "winner is: " + string$(.winner)

    ##########################################################################################################

    ## saves csv file
    if save_csvs = 1
      selectObject: "Table tmp"
      .tbl = selected ("Table")
      @addAcousticInfoToTable: .tbl, .snd
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

      Select outer viewport: .xlims#[.winner]-0.1, .xlims#[.winner]+3.3, .ylims#[.winner]-0.1, .ylims#[.winner]+2.1
      Draw inner box
      Select outer viewport: .xlims#[.winner]-0.05, .xlims#[.winner]+3.25, .ylims#[.winner]-0.05, .ylims#[.winner]+2.05
      Draw inner box

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

  selectObject: "Table winners"
  Save as comma-separated file: folder$ + "/winners.csv"
  removeObject: "Table winners"
  removeObject: .strs, .info
endproc
