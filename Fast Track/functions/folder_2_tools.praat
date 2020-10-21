

include utils/importfunctions.praat

@getSettings
beginPause: "Set Parameters"
  comment: "Click for more info:"
  optionMenu: "", 1
    option:  "[Add buffer to edge of files]"
    option: "Add silence to edges of sounds for if you want formant analyses right up to the edge"
    option: "of the sounds. Alternatively, sounds can be padded when extracted."
  optionMenu: "", 1
    option:  "[Aggregate]"
    option: "Aggregates CSVs resulting from folder analysis into a single CSV summarizing the data in each sound analysis."
    option: "The output is a CSV with a single row for each sound file analyzed. "
  optionMenu: "", 1
    option:  "[Chop sound files with TextGrids]"
    option: "Allows you to extract vowels from sounds using textgrids. This can be"
    option: "done for an entire folder full of sounds (and one of TextGrids) at a time."
  optionMenu: "", 1
    option:  "[Edit folder]"
    option: "This tool allows you to manually-edit analyses in batch, after carrying"
    option: "out a folder analysi."
  optionMenu: "", 1
    option:  "[Get coefficients]"
    option: "This will collect regression coefficients from best analysis from each sound in a folder analysis."
    option: "All coefficients for all formants for each sound are presented on a different row."
  optionMenu: "", 1
    option:  "[Make TextGrids]"
    option: "This function if for quickly making textgrids for a folder of sounds, each containing a single word with a single vowel of interest."
    option: "bla"

  comment: "Select Tool:"
  choice: "Option:", 1
      option: "Add buffer to edge of files"
      option: "Aggregate"
      option: "Chop sound files with TextGrids"
      option: "Edit folder"
      option: "Get coefficients"
      option: "Make TextGrids"
endPause: "Ok", 1

if option == 1
  @addBuffer
endif
if option == 2
  @aggregate: 0
endif
if option == 3
  @chopSoundFiles
endif
if option == 4
  @editFolder
endif
if option == 5
  @getCoefficients: 0
endif
if option == 6
  @makeTextGrids
endif

