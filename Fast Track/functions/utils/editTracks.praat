procedure editTracks: fr
  selectObject: fr
  #.nframes = Get number of frames

  .clicked = 0
  while .clicked <> 1
    totalerror = 0
    @findError: fr
    selectObject: "Table output"
    tbl = selected ("Table")
    .nrows = Get number of rows

    selectObject: "Table output"
    ## this erases 'fake' observations resulting from conversion of formantgrig
    ## object back into formant object
    .stoploop = 0
    while .stoploop = 0
      .t1 = Get value... 1 f1
      .t1n = Get value... 2 f1
      .t2 = Get value... 1 f2
      .t2n = Get value... 2 f2
      .t3 = Get value... 1 f3
      .t3n = Get value... 2 f3
      .t4 = .t3
      .t4n = .t3n
      if number_of_formants == 4
        .t4 = Get value... 1 f4
        .t4n = Get value... 2 f4
      endif
      if (.t1-.t1n) = 0 or (.t2-.t2n) = 0 or (.t3-.t3n) = 0 or (.t4-.t4n) = 0
        Remove row: 1
        .nrows = Get number of rows
      else
        .stoploop = 1
      endif
    endwhile

    selectObject: "Table output"
    .nrows = Get number of rows
    .stoploop = 0
    while .stoploop = 0
      .t1 = Get value... .nrows f1
      .t1n = Get value... .nrows-1 f1
      .t2 = Get value... .nrows f2
      .t2n = Get value... .nrows-1 f2
      .t3 = Get value... .nrows f3
      .t3n = Get value... .nrows-1 f3
      .t4 = .t3
      .t4n = .t3n
      if number_of_formants == 4
        .t4 = Get value... 1 f4
        .t4n = Get value... 2 f4
      endif
      if (.t1-.t1n) = 0 or (.t2-.t2n) = 0 or (.t3-.t3n) = 0 or (.t4-.t4n) = 0
        Remove row: .nrows
       .nrows = Get number of rows
      else
        .stoploop = 1
      endif
    endwhile

    Erase all
    Select outer viewport: 0, 7.5, 0, 4.5
    @plotTable: sp, tbl, maximum_plotting_frequency, 1, ""
    #selectObject: snd
    #Play

    beginPause: "Is the tracking acceptable?"
    .clicked = endPause: "Finish", "Edit", 1

    if .clicked = 2
      selectObject: fr
      .basename$ = selected$ ("Formant")
      .gr = Down to FormantGrid
      View & Edit
      beginPause: "Done Editing"
      endPause: "OK", 1

      removeObject: fr
      fr = To Formant: 0.002, 0.1
      Rename: .basename$ + "_edited_"
      removeObject: .gr
      removeObject: "Table output"
    endif
  endwhile
  .clicked = 0

endproc
