

# saves sounds in folder$
# requires vwlTbl, segment_tier, word_tier

procedure extractVowels

  selectObject: tg
  nIntervals = Get number of intervals: segment_tier
  segmentcount = 0
  filecount = 0
  
  ## loop to go through all segment intervals
  for i from 1 to nIntervals
    selectObject: tg
    vowel$ = Get label of interval: segment_tier, i
    
    if stress == 1
      stress$ = right$ (vowel$, 1)
      len = length (vowel$)
      vowel$ = left$ (vowel$, len-1)
    endif

    ## get info about current (and previous and next) word and segment
    vowelStart = Get start time of interval: segment_tier, i
    vowelEnd = Get end time of interval: segment_tier, i
    if word_tier > 0
      wordNum = Get interval at time: word_tier, (vowelStart+vowelEnd)/2
      word$ = Get label of interval: word_tier, wordNum
      wordStart = Get start time of interval: word_tier, wordNum
      wordEnd = Get end time of interval: word_tier, wordNum
    endif

    ## check if vowel should be analyzed and extracted
    analyze = 0
    extract = 0

    selectObject: vwl_tbl
    num = Search column: "label", vowel$
    if num > 0
      analyze = 1
      extract = 1
    endif

    ## check for skippable word here
    if words_to_skip = 1
      selectObject: wordTbl
      num = Search column: "word", word$
      if num > 0
        analyze = 0
        extract = 0
      endif
    endif

    ## make this into table object. stress_to_extract$
    ## look for label in column. extract of yes. thats it. 
    
    if stress == 1
      selectObject: stresses
      analyze = Has word: stress$
      extract = analyze
    endif

    ## check duration and omit tier
    if omit_tier > 0
      selectObject: tg
      omitnum = Get interval at time: omit_tier, (vowelStart+vowelEnd)/2
      omit$ = Get label of interval: omit_tier, omitnum
      if omit$ <> ""
        extract = 0
      endif
    endif    
    
    ## check that vowel is longer than 30 ms
    if (vowelEnd-vowelStart) < 0.03
      extract = 0
    endif

    ## if segment should be analyzed....
    ## add functionality to not extract but add to omit column, and not to file info!
    if analyze == 1
      selectObject: tg

      next_sound$ = "--"
      previous_sound$ = "--"
      if i > 1
        previous_sound$ = Get label of interval: segment_tier, i-1
        if previous_sound$ == ""
          previous_sound$ = "-"
        endif
      endif
      if i < nIntervals
        next_sound$ = Get label of interval: segment_tier, i+1
        if next_sound$ == ""
          next_sound$ = "-"
        endif
      endif

      if comment_tier1 > 0
        commentNum1 = Get interval at time: comment_tier1, (vowelStart+vowelEnd)/2
        comment1$ = Get label of interval: comment_tier1, commentNum1
      endif
      if comment_tier2 > 0
        commentNum2 = Get interval at time: comment_tier2, (vowelStart+vowelEnd)/2
        comment2$ = Get label of interval: comment_tier2, commentNum2
      endif
      if comment_tier3 > 0
        commentNum3 = Get interval at time: comment_tier3, (vowelStart+vowelEnd)/2
        comment3$ = Get label of interval: comment_tier3, commentNum3
      endif

      ## only do this block if there is a word tier
      if word_tier > 0
        next_word$ = "-"
        previous_word$ = "-"
        if wordNum > 1
          previous_word$ = Get label of interval: word_tier, wordNum-1
          if previous_word$ == ""
            previous_word$ = "-"
          endif
        endif
        maxwords = Get number of intervals: word_tier
        if wordNum < maxwords
          next_word$ = Get label of interval: word_tier, wordNum+1
          if next_word$ == ""
            next_word$ = "-"
          endif
        endif
      endif
      

      ##### Sound extraction and adding to file info
      ## extract and save sound

      if extract == 1

        filecount = filecount + 1
        selectObject: snd
        snd_small = Extract part: vowelStart - buffer, vowelEnd + buffer, "rectangular", 1, "no"
        if filecount > 999
          filename$ = basename$ + "_" + string$(filecount)
        endif
        if filecount > 99 and filecount < 1000
          filename$ = basename$ + "_0" + string$(filecount)
        endif
        if filecount > 9 and filecount < 100
          filename$ = basename$ + "_00" + string$(filecount)
        endif
        if filecount < 10
          filename$ = basename$ + "_000" + string$(filecount)
        endif

        if maintain_separate == 1
          Save as WAV file: output_folder$ + "/" + basename$ + "/" + filename$ + ".wav"
        endif
        if maintain_separate == 0
          Save as WAV file: output_folder$ + "/sounds/" + filename$ + ".wav"
        endif
        removeObject: snd_small
            
        selectObject: vwl_tbl
        spot = Search column: "label", vowel$
        tmp_clr$ = Get value: spot, "color"

        selectObject: file_info
        Append row
        Set string value: filecount, "file", filename$ + ".wav"
        Set string value: filecount, "label", vowel$
        Set numeric value: filecount, "group", spot
        Set string value: filecount, "color", tmp_clr$

      endif

    
      segmentcount = segmentcount + 1
      ## write information to table
      selectObject: tbl
      Append row
      Set string value: segmentcount, "inputfile", basename$
      Set string value: segmentcount, "outputfile", "--"
      if extract == 1
        Set string value: segmentcount, "outputfile", filename$
      endif

      Set numeric value: segmentcount, "duration", vowelEnd-vowelStart
      Set numeric value: segmentcount, "start", vowelStart
      Set numeric value: segmentcount, "end", vowelEnd
      Set string value: segmentcount, "vowel", vowel$
      Set numeric value: segmentcount, "interval", i
      Set string value: segmentcount, "previous_sound", previous_sound$
      Set string value: segmentcount, "next_sound", next_sound$

      if stress == 1
        Set string value: segmentcount, "stress", stress$
      endif

      omitted = (extract == 0)
      Set numeric value: segmentcount, "omit", omitted


      if word_tier > 0
        Set string value: segmentcount, "word", word$
        Set numeric value: segmentcount, "word_interval", wordNum
        Set numeric value: segmentcount, "word_start", wordStart
        Set numeric value: segmentcount, "word_end", wordEnd
        Set string value: segmentcount, "previous_word", previous_word$
        Set string value: segmentcount, "next_word", next_word$
      endif

      if comment_tier1 > 0
        Set string value: segmentcount, "comment1", comment1$
      endif
      if comment_tier2 > 0
        Set string value: segmentcount, "comment2", comment2$
      endif
      if comment_tier3 > 0
        Set string value: segmentcount, "comment3", comment3$
      endif  
    endif

  endfor

endproc