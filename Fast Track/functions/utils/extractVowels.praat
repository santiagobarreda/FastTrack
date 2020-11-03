

# saves sounds in folder$
# requires vwlTbl, segment_tier, word_tier

procedure extractVowels

    selectObject: tg
    nIntervals = Get number of intervals: segment_tier
    count = 0

    ## loop to go through all segment intervals
    for i from 1 to nIntervals
    selectObject: tg
    vowel$ = Get label of interval: segment_tier, i
    stress$ = right$ (vowel$, 1)
    stress = number (stress$)
    vowel$ = left$ (vowel$, 2)

    ## get info about current (and previous and next) word and segment
    vowelStart = Get start time of interval: segment_tier, i
    vowelEnd = Get end time of interval: segment_tier, i
    if word_tier > 0
        wordNum = Get interval at time: word_tier, (vowelStart+vowelEnd)/2
        word$ = Get label of interval: word_tier, wordNum
        wordStart = Get start time of interval: word_tier, wordNum
        wordEnd = Get end time of interval: word_tier, wordNum
    endif

    ## check if vowel should be analyzed
    analyze = 0

    selectObject: vwl_tbl
    num = Search column: "label", vowel$
    if num > 0
        analyze = 1
    endif

    ## check for skippable word here
    if words_to_skip = 1
        selectObject: wordTbl
        num = Search column: "word", word$
        if num > 0
        analyze = 0
        endif
    endif

    if stress <> 1 and select_stress = 1
        analyze = 0
    endif
    if stress = 0 and (select_stress = 1 or select_stress = 2)
        analyze = 0
    endif

    ## if segment should be analyzed....
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
    
        ## extract and save sound
        count = count + 1
        selectObject: snd
        snd_small = Extract part: vowelStart - buffer, vowelEnd + buffer, "rectangular", 1, "no"
        if count > 999
        filename$ = basename$ + "_" + string$(count)
        endif
        if count > 99 and count < 1000
        filename$ = basename$ + "_0" + string$(count)
        endif
        if count > 9 and count < 100
        filename$ = basename$ + "_00" + string$(count)
        endif
        if count < 10
        filename$ = basename$ + "_000" + string$(count)
        endif
        Save as WAV file: folder$ + "/" + filename$ + ".wav"
        removeObject: snd_small
        
        ## write information to table
        selectObject: tbl
        Append row
        Set numeric value: count, "file", count
        Set string value: count, "filename", filename$
        Set numeric value: count, "duration", vowelEnd-vowelStart
        Set numeric value: count, "start", vowelStart
        Set numeric value: count, "end", vowelEnd
        Set string value: count, "vowel", vowel$
        Set numeric value: count, "interval", i
        Set string value: count, "previous_sound", previous_sound$
        Set string value: count, "next_sound", next_sound$
        Set string value: count, "stress", stress$

        
        selectObject: vwl_tbl
        spot = Search column: "label", vowel$
        tmp_clr$ = Get value: spot, "color"

        selectObject: file_info
        Append row
        Set numeric value: count, "number", count
        Set string value: count, "file", filename$ + ".wav"
        Set string value: count, "label", vowel$
        Set numeric value: count, "group", spot
        Set string value: count, "color", tmp_clr$

        selectObject: tbl
        if word_tier > 0
          Set string value: count, "word", word$
          Set numeric value: count, "word_interval", wordNum
          Set numeric value: count, "word_start", wordStart
          Set numeric value: count, "word_end", wordEnd
          Set string value: count, "previous_word", previous_word$
          Set string value: count, "next_word", next_word$
          endif

        if comment_tier1 > 0
          Set string value: count, "comment1", comment1$
        endif
        if comment_tier2 > 0
          Set string value: count, "comment2", comment2$
        endif
        if comment_tier3 > 0
          Set string value: count, "comment3", comment3$
        endif

    endif
    endfor

endproc