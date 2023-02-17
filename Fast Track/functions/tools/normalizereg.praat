
procedure normalizereg ;autorun
  @getSettings

  ;if autorun == 0
  beginPause: "Set Parameters"

   optionMenu: "", 1
    option: "[**IMPORTANT** Click to Read]"
    option: ""
    option: "This function performs log mean normalization using the regression approach outlined in paper 1 below. "
    option: "To make outputs compatible with ANAE normalization, just add an arbitrary scaling value and exponentiate"  
    option: "the results. Other normalization methods are not implemented because these demonstrably erase "
    option: "phonetic/linguistic/social information from vowel production data. This is demonstrated in paper 2,"
    option: "and the theoretical basis for this expectation is presented in paper 3."
    option: ""
    option: "Folder: Indicate your working directory. This folder should contain a folder inside of it"
    option:  "called 'processed_data' that contains the aggregated data you wish to normalize."
    option: " "
    option: "Number of formants: Indicate how many formants the aggregated data has."
    option: "Number of bins: Indicate how times slices the aggregated data has."
    option: " "
    option: "Arbitrary scaling: an arbitrary number can be added back to the normalized files, as in ANAE normalization."
    option: "Exponetiate: if checked, normalized values will be changed back into Hertz values."
    sentence: "Paper 1", "https://santiagobarreda.com/cvfiles/2018_Barreda_Nearey.pdf"
    sentence: "Paper 2", "https://santiagobarreda.com/cvfiles/Barreda_LVAC_2021.pdf"
    sentence: "Paper 3", "https://santiagobarreda.com/cvfiles/2020_Barreda.pdf"
    comment: " "
    comment: " "
    sentence: "Folder:", folder$
    optionMenu: "Number of formants:", number_of_formants
  			option: "3"
  			option: "4"
    optionMenu: "Number of bins:", number_of_bins
  			option: "1"
  			option: "3"
  			option: "5"
        option: "7"
        option: "9"
        option: "10"
    real: "Arbitrary scaling:", 0
    boolean: "Exponentiate:", 0
  endPause: "Ok", 1
  ;endif

  nformants = number (number_of_formants$)
  nbins = number (number_of_bins$)

  ending$ = right$ (folder$,1)
  if ending$ == "/"
    folder$ = folder$ - "/"
  endif
  if ending$ == "\"
    folder$ = folder$ - "\"
  endif
  
  @saveSettings


  aggdat = Read Table from comma-separated file: folder$ + "/processed_data/aggregated_data.csv"
  nfiles = Get number of rows
  ncat = Get maximum: "group"

  Copy: "ffdat"
  nocheck Remove column: "file"
  nocheck Remove column: "f0"
  nocheck Remove column: "duration"
  nocheck Remove column: "label"
  nocheck Remove column: "group"
  nocheck Remove column: "color"
  nocheck Remove column: "number"
  nocheck Remove column: "cutoff"
  ffdatt = Transpose

  if ncat == 1
    beginPause: "Set Parameters"
      comment: "Please note that your aggregated data file only distinguishes one group (category)."
      comment: "This is likely incorrect and will mean your estimates of the average formant produced by this talker"
      comment: "will be biased towards those categories that are represented most often."
    endPause: "Ok", 1
  endif

  if arbitrary_scaling > 10
    arbitrary_scaling = ln (arbitrary_scaling)
  endif



  #################################################################################################
  ## now there is a gbar column in coefficients. this needs to be aded to the regression table
  ## along with the dummy variable info

  Create Table with column names: "regression", nfiles, "v1"
  Formula: "v1",  "0"
  for i from 2 to ncat
    Append column: "v" + string$(i)
    Formula: "v" + string$(i),  "0"
  endfor
  Append column: "gbar"

  for i from 1 to nfiles
    # copy gbar
    selectObject: ffdatt
    Set column label (index): i+1, string$(i)
    Formula: string$(i), "ln(self)"
    tmp = Get mean: string$(i)

    selectObject: "Table regression"  
    Set numeric value: i, "gbar", tmp

    ## set dummy
    ## this now can be taken from the file info csv file
    selectObject: aggdat  
    tmpv = Get value: i, "group"

    selectObject: "Table regression"  
    Set numeric value: i, "v"+string$(tmpv), 1
  endfor 
  Remove column: "v1"

  #################################################################################################
  ## normalization part

  linreg = To linear regression
  info$ = Info
  intercept = extractNumber (info$, "Intercept: ")

  total = intercept
  for i from 2 to ncat
  v'i' = extractNumber (info$, "Coefficient of factor v" + string$(i)+ ": ")
  tmp = intercept + v'i'
  total = total + tmp
  endfor
  gbar = total / ncat

  ## copy aggregate, loop through data columns and log and subtract. provide optional unlogging value. 

  selectObject: aggdat
  Copy: "normalized"

  for i from 1 to nformants
    for j from 1 to nbins
      selectObject: "Table normalized"  
      Formula: "f"+string$(i)+string$(j), "ln(self)"
      Formula: "f"+string$(i)+string$(j), "self - gbar + arbitrary_scaling"
      if exponentiate = 1
        Formula: "f"+string$(i)+string$(j), "exp(self)"
      endif
    endfor
  endfor 

  Save as comma-separated file: folder$ + "/processed_data/normalized_aggregated_data.csv"
  
  nocheck removeObject: aggdat
  nocheck removeObject: linreg
  nocheck removeObject: "Table regression"
  nocheck removeObject: "Table regression"
  nocheck removeObject: "Table ffdat"
  nocheck removeObject: "Table ffdat_transposed"

endproc




