
procedure makeModelMatrix .tbl

  .tbl = selected: "Table"
  selectObject: .tbl
  Sort rows: "vowel"
  .nfiles = Get number of rows

  .tmpInfo = Copy: "tmp-info"

  # gets first vowel label
  selectObject: .tbl
  .lastvowel$ = Get value: 1, "vowel"  
  vnum = 1

  ## will contain all the dummy variables
  .modelMatrix = Create Table with column names: "model-matrix", .nfiles, "v1"
  Formula: "v1", "0"

  # first pass is vowels
  selectObject: .tbl
  Sort rows: "vowel"
  selectObject: .tmpInfo
  Sort rows: "vowel"
  for .i from 1 to .nfiles  
    selectObject: .tbl
    .tmpvowel$ = Get value: .i, "vowel"
  
    if .lastvowel$ <> .tmpvowel$ 
      vnum = vnum + 1
      selectObject: .modelMatrix
      Append column: "v" + string$(vnum)
      Formula: "v" + string$(vnum), "0"
      .lastvowel$ = .tmpvowel$
    endif

    selectObject: .tmpInfo
    Set numeric value: .i, "vowel", vnum

  endfor 

  if 2 < 1
    # second pass is speakers
    selectObject: .tbl
    .lastspeaker$ = Get value: 1, "speaker"  
    snum = 1
    Sort rows: "speaker"
    selectObject: .tmpInfo
    Sort rows: "speaker"

    selectObject: .modelMatrix
    Append column: "s1"
    Formula: "s1", "0"

    for .i from 1 to .nfiles  
      selectObject: .tbl
      .tmpspeaker$ = Get value: .i, "speaker"

      if .lastspeaker$ <> .tmpspeaker$
        snum = snum + 1
        selectObject: .modelMatrix
        Append column: "s" + string$(snum)
        Formula: "s" + string$(snum), "0"
        .lastspeaker$ = .tmpspeaker$
      endif

      selectObject: .tmpInfo
      Set numeric value: .i, "speaker", snum
    endfor 
  endif

  selectObject: .tmpInfo
  Sort rows: "file"

  selectObject: .modelMatrix

  for .i from 1 to .nfiles 
    ## set dummy
    selectObject: .tmpInfo  
    .tmpv = Get value: .i, "vowel"
    ;.tmps = Get value: .i, "speaker"

    selectObject: .modelMatrix  
    Set numeric value: .i, "v"+string$(.tmpv), 1
    ;Set numeric value: .i, "s"+string$(.tmps), 1
  endfor 
  Remove column: "v1"
  ;Remove column: "s1"

endproc