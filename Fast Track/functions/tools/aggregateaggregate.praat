
procedure aggregateAggregate autorun
  @getSettings

  .tbl = selected("Table")

  if autorun == 0
  beginPause: "Set Parameters"
    comment: "How many sections should signal be divided into? 1 returns the overall aggregated value. 3 returns"
    comment: "aggregated results for the first third, midle third, and final third, and so on."
    optionMenu: "Number of formants:", number_of_formants
  			option: "3"
  			option: "4"
    optionMenu: "Number of bins:", 3
  			option: "1"
  			option: "3"
  			option: "5"
        option: "7"
        option: "9"
        option: "10"
    word: "Grouping column:"
    positive: "Number of groups:", 1
    word: "Label column:"
    word: "Color column:"

   	optionMenu: "Statistic", 1
  	        option: "median"
  					option: "mean"
  nocheck endPause: "Ok", 1
  endif
 
  @saveSettings

  number_of_bins = number(number_of_bins$)
  number_of_formants = number(number_of_formants$)

  Create Table with column names: "output", number_of_groups, "file"
  .output = selected ("Table")

  Append column: "f0"
  Append column: "duration"
  for j from 1 to number_of_bins
    for i from 1 to number_of_formants
      Append column: "f"+string$(i)+string$(j)
    endfor
  endfor


  for .iii from 1 to number_of_groups

    selectObject: .tbl
    .tmp_tbl = Extract rows where column (number): "group", "is equal to", .iii

    if statistic == 2
      .mf0 = Get mean: "f0"
      .mduration = Get mean: "duration"
    endif
    if statistic == 1
      .mf0 = Get quantile: "f0", 0.5
      .mduration = Get quantile: "duration", 0.5
    endif

    #selectObject: .output
    #Set numeric value: .iii, "duration", .duration
    #.mf0 = round(.mf0 * 10) / 10

    for .j from 1 to number_of_bins
      selectObject: .tmp_tbl
      for .k from 1 to number_of_formants
        if statistic == 2
          .mf'.k''.j' = Get mean: "f"+string$(.k)
        endif
        if statistic == 1
          .mf'.k''.j' = Get quantile: "f"+string$(.k), 0.5
        endif
      endfor
    endfor

    selectObject: .tmp_tbl
    ## get color and vowel in first row if these exist


    selectObject: .output
    Set string value... .iii "vowel" vowel$
    for .j from 1 to number_of_bins
      for .i from 1 to number_of_formants
        Set numeric value... .iii f'.i''.j' round(.mf'.i''.j')
      endfor
    endfor

    Set numeric value... .iii "duration" round(.mduration)
    Set numeric value... .iii "f0" round(.mf0)

    removeObject: .tbl
  endfor
  selectObject: .output
  Save as comma-separated file: folder$ + "/processed_data/aggregated_data.csv"
  Rename: "aggregated"
endproc
