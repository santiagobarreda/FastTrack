

include utils/importfunctions.praat

@getSettings
beginPause: "Set Parameters"
  comment: "What tool do you want to use:"
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

