segment_tier = 1
word_tier = 0

tg = selected ("TextGrid")
snd = selected ("Sound")
basename$ = selected$ ("Sound")

include utils/importfunctions.praat
@getSettings

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

@getTGESettings


beginPause: "Set Parameters"
    optionMenu: "", 1
    option: "[**IMPORTANT** Click to Read]"
    option: "All arpabet vowels (specified in /dat/arpabet.csv) are extracted by default. If you place a file called 'vowelstoextract.csv'"
    option: "in your desired output folder, or in the '/dat/' folder, the sounds you specify there will be extracted. You can (and should) also specify colors and groups"
    option: "for each sound. The file should be set up before running this function. You can use the 'arpabet.csv' file in /dat/ as a template."
    comment: "Files will be saved directly into the folder specified here."
    sentence: "Folder:", folder$
    comment: "Which tier contains segment information?"
    positive: "Segment tier:", segment_tier
    comment: "Which tier contains word information? (not necessary)"
		integer: "Word tier:", word_tier
    comment: "Optional tiers (up to 3) containing comments that will also be collected."
		integer: "Comment tier1:", 0
		integer: "Comment tier2:", 0
		integer: "Comment tier3:", 0
    comment: "If anything is written in this tier, the segment will be skipped:"
		integer: "Omit tier:", 0
    comment: "Collect vowels with the following stress."
    option: "[Click to Read]"
    option: "This assumes the final symbol on the vowel labels is used to indicate stress."
    option: "Indicate which stress symbols you want to extract (leave blank for no symbols)"
    sentence: "Stress to extract", stress_to_extract$
    optionMenu: "", 1
    option: "[Click to Read]"
    option: "Vowels will not be extracted from any words specified here. Please spell words exactly as they"
    option: "will appear in the textgrid (including capitalization). Words should be separated by a space."
    option: " "
    option: "Alternatively, a file called wordstoskip.txt can be placed in the /dat/ folder. Each line should contain one"
    option: "word to be skipped. This file will be used if it exists so be sure to erase it when no longer needed."
		sentence: "Words to skip:", "--"
    optionMenu: "", 1
    option: "[Click to Read]"
    option: "The first option saves a table with information about the vowels extracted."
    option: "For example, start and end times, and the current and previous words are saved."
    option: "The second option saves a file that can be used to analyze extractec sounds in a folder analysis."
    boolean: "Save segmentation information:", 1
    boolean: "Save file information:", 1
    optionMenu: "", 1
    option: "[Click to Read]"
    option: "How much time should be added to edges (0 = no padding)?"
    option: "Setting the buffer to 0.025 allows formant tracking to the edge of the sound when using"
    option: "a 50ms analysis window. Alternatively, sounds can be padded with zeros before analysis"
    option: "with another function provided by Fast Track."
    positive: "Buffer (s):", 0.025

nocheck endPause: "Ok", 1

@saveTGESettings


################################################################################################
###### This handles stress extraction

stress_override = 0
stress = 0

if stress_to_extract$ <> ""
  stress = 1
  tmp_strs = Create Strings as tokens: stress_to_extract$, " ,"
  stresses = To WordList
  removeObject: tmp_strs
  stress_override = 1
endif

if fileReadable ("/../dat/stresstoextract.txt") and stress_override == 0
  stress = 1
  tmp_strs = Read Strings from raw text file: "/../dat/stresstoextract.txt"
  stresses = To WordList
  removeObject: tmp_strs
endif 


##############################################################################################
###### Here I get the information about which vowels to extract

extract_file = 0

if fileReadable (folder$ + "/vowelstoextract.csv")
  vwl_tbl = Read Table from comma-separated file: folder$ + "/vowelstoextract.csv"
  extract_file = 1
endif 

if fileReadable ("/../dat/vowelstoextract.csv") and extract_file = 0
  vwl_tbl = Read Table from comma-separated file: "/../dat/vowelstoextract.csv"
  extract_file = 1
endif 
if !fileReadable ("/../dat/vowelstoextract.csv") and extract_file = 0
   if !fileReadable ("/../dat/arpabet.csv")
     exitScript: "You do not have either an arpabet.csv nor a vowelstoextract.csv file in your /dat/ folder. Please fix and run again!!"
   endif
  vwl_tbl = Read Table from comma-separated file: "/../dat/arpabet.csv"
endif 

Rename: "vowels"


################################################################################################
###### This section adds group and color information to vowel tables if the user has not provided it

selectObject: vwl_tbl
fill_group = Get column index: "group"
fill_color = Get column index: "color"
nrows = Get number of rows

if fill_group == 0
  Append column: "group"
endif

if fill_color == 0
  Append column: "color"
  .clr_str = Create Strings as tokens: "Red Blue Black Green Olive Yellow Magenta Black Lime Purple Teal Navy Pink Maroon Grey Silver Cyan Black", " ,"
endif

for .tmpi from 1 to nrows
  if fill_group == 0
    selectObject: vwl_tbl
    Set numeric value: .tmpi, "group", .tmpi
  endif
  if fill_color == 0
    selectObject: .clr_str
     color_use = (.tmpi mod (18)) + 1
    .tmp_clr = Get string: .tmpi
    selectObject: vwl_tbl
    Set string value: .tmpi, "color", "Blue"
  endif  
endfor

nocheck removeObject: .clr_str

#################################################################################################

words_to_skip = 0
## make table with words to skip
if words_to_skip$ <> "--"
  words_to_skip = 1
  .skipWords = Create Strings as tokens: words_to_skip$, " ,"
endif

if fileReadable ("../dat/wordstoskip.txt")
  words_to_skip = 1
  .skipWords = Read Strings from raw text file: "../dat/wordstoskip.txt"
endif

if fileReadable (folder$ + "/wordstoskip.txt")
  words_to_skip = 1
  .skipWords = Read Strings from raw text file: folder$ + "/wordstoskip.txt"
endif

if words_to_skip == 1
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

#################################################################################################

  ## make table that will contain all output information
    tbl = Create Table with column names: "table", 0, "file filename vowel interval duration start end previous_sound next_sound stress omit"
    if word_tier > 0
    Append column: "word"
    Append column: "word_interval"
    Append column: "word_start"
    Append column: "word_end"
    Append column: "previous_word"
    Append column: "next_word"
    endif
    if comment_tier1 > 0
      Append column: "comment1"
    endif
    if comment_tier2 > 0
      Append column: "comment2"
    endif
    if comment_tier3 > 0
      Append column: "comment3"
    endif

    file_info = Create Table with column names: "fileinfo", 0, "number file label group color"


####################################################################################################################################################################
####################################################################################################################################################################


@extractVowels


if save_segmentation_information = 1
  selectObject: tbl
  Save as comma-separated file: folder$ + "/" + basename$+ "_segmentation_info.csv"
endif

if save_file_information = 1
  selectObject: file_info
  Save as comma-separated file: folder$ + "/file_information.csv"
endif


removeObject: vwl_tbl, file_info, "Table table"
