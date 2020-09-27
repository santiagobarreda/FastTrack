segment_tier = 1
word_tier = 0

tg = selected ("TextGrid")
snd = selected ("Sound")
sndName$ = selected$ ("Sound")

include utils/importfunctions.praat
@getSettings

# set parameter for specifying vowels. make table
.vwl_str = Create Strings as tokens: "AA AE AH AO AW AX AY EH ER EY IH IX IY OW OY UH UW UX", " ,"
Rename: "vowels"

selectObject: tg
tmp$ = Get tier name: 1
if tmp$ = "words"
  word_tier = 1
  segment_tier= 2
endif
tmp$ = Get tier name: 2
if tmp$ = "words"
  word_tier = 2
endif


beginPause: "Set Parameters"
    optionMenu: "", 1
    option: "[**IMPORTANT** Click to Read]"
    option: "When this form is generated, a Strings object called vowels is created and appears in the"
    option: "Praat bject window.  Any vowels found here will be extracted. All arpabet vowels are included"
    option: "by default. Once this form is closed the strings object can no longer be edited."
    comment: "Files will be saved directly into the folder specified here."
    sentence: "Folder:", folder$
    comment: "Which tier contains segment information?"
    positive: "Segment tier:", segment_tier
    comment: "Which tier contains word information? (not necessary)"
		integer: "Word tier:", word_tier
    comment: "Optional tier containing comments that will also be collected."
		integer: "Comment tier:", 0
    comment: "Collect vowels with the following stress."
    optionMenu: "Select stress", 2
    option: "Only primary stress"
    option: "Primary and secondary stress"
    option: "Any"
    optionMenu: "", 1
    option: "[Click to Read]"
    option: "Vowels will not be extracted from any words specified here. Please spell"
    option: "words exactly as they will appear in the textgrid (including capitalization)."
    option: "Words should be separated by a space."
		sentence: "Words to skip:", "--"
    optionMenu: "", 1
    option: "[Click to Read]"
    option: "The first option returns a table with information about the vowels extracted."
    option: "For example, start and end times, and the current and previous words are saved."
    option: "The second option keeps a table with this information in Praat."
    boolean: "Return table:", 0
    boolean: "Save information:", 1
    optionMenu: "", 1
    option: "[Click to Read]"
    option: "How much time should be added to edges (0 = no padding)?"
    option: "Setting the buffer to 0.025 allows formant tracking to the edge of the sound when using"
    option: "a 50ms analysis window. Alternatively, sounds can be padded with zeros before analysis"
    option: "with another function provided by Fast Track."
    positive: "Buffer (s):", 0.025
endPause: "Ok", 1

words_to_skip = 0
## make table with words to skip
if words_to_skip$ <> "--"
  words_to_skip = 1
  .skipWords = Create Strings as tokens: words_to_skip$, " ,"
  Rename: "wordstoskip"
  n = Get number of strings

  wordTbl = Create Table with column names: "wordstoskip", n, "word"
  for i from 1 to n
    selectObject: "Strings wordstoskip"
    tmp$ = Get string: i
    selectObject: "Table wordstoskip"
    Set string value: i, "word", tmp$
  endfor
  removeObject: "Strings wordstoskip"
endif

## make table with vowels to collect
selectObject: "Strings vowels"
n = Get number of strings
vwlTbl = Create Table with column names: "vowels", n, "vowel"
  for i from 1 to n
    selectObject: "Strings vowels"
    tmp$ = Get string: i
    selectObject: "Table vowels"
    Set string value: i, "vowel", tmp$
  endfor
  removeObject: "Strings vowels"
endif

## make table that will contain all output information
selectObject: tg
nIntervals = Get number of intervals: segment_tier
tbl = Create Table with column names: "table", 0, "file filename vowel interval duration start end previous_sound next_sound stress"
if word_tier > 0
  Append column: "word"
  Append column: "word_interval"
  Append column: "word_start"
  Append column: "word_end"
  Append column: "previous_word"
  Append column: "next_word"
endif
if comment_tier > 0
  Append column: "comment"
endif



####################################################################################################################################################################
####################################################################################################################################################################


## loop to go through all segment intervals
count = 0
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

  selectObject: vwlTbl
  num = Search column: "vowel", vowel$
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

    if comment_tier > 0
      commentNum = Get interval at time: comment_tier, (vowelStart+vowelEnd)/2
      comment$ = Get label of interval: comment_tier, commentNum
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
      filename$ = sndName$ + "_" + string$(count)
    endif
    if count > 99 and count < 1000
      filename$ = sndName$ + "_0" + string$(count)
    endif
    if count > 9 and count < 100
      filename$ = sndName$ + "_00" + string$(count)
    endif
    if count < 10
      filename$ = sndName$ + "_000" + string$(count)
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

    if word_tier > 0
      Set string value: count, "word", word$
      Set numeric value: count, "word_interval", wordNum
      Set numeric value: count, "word_start", wordStart
      Set numeric value: count, "word_end", wordEnd
      Set string value: count, "previous_word", previous_word$
      Set string value: count, "next_word", next_word$
    endif

    if comment_tier > 0
      Set string value: count, "comment", comment$
    endif

  endif

endfor

selectObject: tbl
if save_information = 1
  Save as comma-separated file: folder$ + "/"+ sndName$+ "_segmentation_info.csv"
endif

if return_table == 0
  removeObject: tbl
endif

removeObject: vwlTbl
