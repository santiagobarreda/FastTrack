segment_tier = 1
word_tier = 0

tg = selected ("TextGrid")
snd = selected ("Sound")
basename$ = selected$ ("Sound")

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
    option: "Alternatively, you can write the vowels you want in a text file, one per lines. You can read"
    option: "this in by specifying a path to a text file below."
    comment: "Path to optional text file with alternate vowels (--)"
    sentence: "Vowels file:", "--"
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
nocheck endPause: "Ok", 1

if vowels_file$ <> "--"
  removeObject: "Strings vowels"
  Read Strings from raw text file: vowels_file$
  Rename: "vowels"
endif


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

@extractVowels

selectObject: tbl
if save_information = 1
  Save as comma-separated file: folder$ + "/"+ basename$+ "_segmentation_info.csv"
endif

if return_table == 0
  removeObject: tbl
endif

removeObject: vwlTbl
