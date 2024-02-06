
procedure advancedAggregate 
  @getSettings

  if autorun == 0
  beginPause: "Set Parameters"
    comment: "Indicate your working directory. This folder should contain a folder inside of it"
    comment: "called 'csvs' that contains all of the files you wish to aggregate."
    sentence: "Folder:", folder$
    comment: "How many sections should signal be divided into? 1 returns the overall aggregated value. 3 returns"
    comment: "aggregated results for the first third, midle third, and final third, and so on."
    optionMenu: "Number of formants:", number_of_formants
  			option: "3"
  			option: "4"
    optionMenu: "Number of bins:", number_of_bins
  			option: "1"
  			option: "3"
  			option: "5"
        option: "7"
        option: "9"
        option: "11"
    optionMenu: "Statistic", 1
  	    option: "median"
  	  	option: "mean"
    choice: "Value to collect", 1
        button: "Observed formant"
        button: "Predicted (smooth) formant"
  endPause: "Ok", 1
  endif

  ending$ = right$ (folder$,1)
  if ending$ == "/"
    folder$ = folder$ - "/"
  endif
  if ending$ == "\"
    folder$ = folder$ - "\"
  endif
  
  @saveSettings

  number_of_bins = 1 + (number_of_bins-1)*2
  number_of_formants = number(number_of_formants$)
  createDirectory: folder$ + "/processed_data/"

  if !fileReadable: folder$ + "/file_information.csv"
    @prepareFileInfo: 1
  endif

  .file_info = Read Table from comma-separated file: folder$ + "/file_information.csv"
  .nfiles = Get number of rows

  ## add columns to ouput table
  Create Table with column names: "output", .nfiles, "file"
  .output = selected ("Table")
  Append column: "f0"
  Append column: "duration"
  Append column: "label"
  Append column: "group"
  Append column: "color"
  Append column: "number"
  Append column: "cutoff"
  for j from 1 to number_of_bins
    for i from 1 to number_of_formants
      Append column: "f"+string$(i)+string$(j)
    endfor
  endfor
   
  for .iii from 1 to .nfiles
    selectObject: .file_info
    .basename$ = Get value: .iii, "file"
    .basename$ = .basename$ - ".wav"

    .tbl = Read Table from comma-separated file: folder$ + "/csvs/" + .basename$ + ".csv"
    .nframes = Get number of rows
    Append column: "ntime"
    for .j from 1 to .nframes
      tmp = .j / (.nframes/number_of_bins)
      Set numeric value: .j, "ntime", ceiling( tmp )
    endfor

    ## section about gettin best cutoff frequency
    .info = Read Strings from raw text file: folder$ + "/infos/" + .basename$ + "_info.txt"
    .tmp$ = Get string: 11
    stringToVector_output# = zero#(number_of_formants)
    @stringToVector: .tmp$
    .cutoff = stringToVector_output#[1] 
    removeObject: .info

    selectObject: .tbl
    .firstFrameTime = Get value: 1, "time"
    .lastFrameTime = Get value: .nframes, "time"
    .duration = .lastFrameTime - .firstFrameTime
    .duration = round(.duration * 1000) / 1000

    selectObject: .output
    Set numeric value: .iii, "duration", .duration
    Set numeric value: .iii, "cutoff", .cutoff

    selectObject: .tbl
    .mf0 = Get mean: "f0"

    if .mf0 > 0
      .tmp_tbl = Extract rows where column (number): "f0", "greater than", 0
      .mf0 = Get mean: "f0"
      .mf0 = round(.mf0 * 10) / 10
      removeObject: .tmp_tbl
    endif    
    selectObject: .output
    Set numeric value: .iii, "f0", .mf0


    for .j from 1 to number_of_bins
      selectObject: .tbl
      .tmp_tbl = Extract rows where column (number): "ntime", "equal to", .j
      for .k from 1 to number_of_formants
        if statistic == 2
          .mf'.k''.j' = Get mean: "f"+string$(.k)
        endif
        if statistic == 1
          .mf'.k''.j' = Get quantile: "f"+string$(.k), 0.5
        endif
      endfor
      removeObject: .tmp_tbl
    endfor

    selectObject: .output
    Set string value... .iii file '.basename$'
    for .j from 1 to number_of_bins
      for .i from 1 to number_of_formants
        Set numeric value... .iii f'.i''.j' round(.mf'.i''.j')
      endfor
    endfor

      selectObject: .file_info
      group$ = Get value: .iii, "group"
      label$ = Get value: .iii, "label"
      color$ = Get value: .iii, "color"
      number$ = Get value: .iii, "number"
      selectObject: .output
      Set string value: .iii, "group", group$
      Set string value: .iii, "label", label$
      Set string value: .iii, "color", color$
      Set string value: .iii, "number", number$
    endif

    nocheck removeObject: .tbl
  endfor

  selectObject: .output
  Save as comma-separated file: folder$ + "/processed_data/aggregated_data.csv"
  Rename: "aggregated"

  removeObject: .file_info

endproc
