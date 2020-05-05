

include tools/importFunctions.praat

@getSettings
beginPause: "Set Parameters"
  comment: "Select which type of data processing you want:"
  optionMenu: "Processing:", 1
      option: "aggregate"
      option: "get coefficients"
endPause: "Ok", 1


if processing == 1
  @aggregate
endif
if processing == 2
  @getCoefficients
endif
