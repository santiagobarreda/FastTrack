

include utils/importfunctions.praat

@getSettings
beginPause: "Set Parameters"
  comment: "What tool do you want to use:"
  choice: "Option:", 1
      option: "Edit folder"
      option: "Aggregate"
      option: "Get coefficients"
      option: "Cut sound files"
endPause: "Ok", 1

if option == 1
  @editFolder
endif
if option == 2
  @aggregate
endif
if option == 3
  @getCoefficients
endif
if option == 4
  @chopSoundFiles
endif
