
## collect all regression coefficients in one big csv file. recreate after, collect winners,

include tools/importFunctions.praat
include folder/trackFolder.praat
include folder/autoSelectFolder.praat
include folder/getWinnersFolder.praat

@getSettings

beginPause: "Set Parameters"
    comment: "Indicate your working directory. This folder shgould contain a folder inside of it."
    comment: "called 'sounds' that contains all of the sounds you wih to analyze."
    sentence: "Folder:", folder$
    comment: "Recommended ranges: 4500-6500 for tall speakers, 5000-7000 for short speakers."
		positive: "Lowest analysis frequency (Hz):", lowest_analysis_frequency
		positive: "Highest analysis frequency (Hz):", highest_analysis_frequency
    comment: "Number of analyses between low and high analysis limits. More analysis steps may"
    comment: "results, but will increase analysis time (50% more steps = 50% longer to analyze)."
		optionMenu: "Number of steps:", number_of_steps
			option: "8"
			option: "12"
			option: "16"
			option: "20"
			option: "24"
    comment: "More coefficients allow for more sudden, and 'wiggly' formant motion."
		positive: "Number of coefficients for formant prediction:", number_of_coefficients_for_formant_prediction
    comment: "How many formants will be judged to pick the winner?"
    optionMenu: "Number of formants", number_of_formants
            option: "3"
            option: "4"
    comment: "Images are recommended as they facilitate data validation and the selection of alternate analyses."
    comment: "Making images does not add significant time (<5%) to the analysis."
    boolean: "Make images comparing analyses", 1
    boolean: "Make images showing winners", 1
    positive: "Maximum plotting frequency (Hz):", maximum_plotting_frequency
    comment: "Uncheck to skip step. Individual steps can be carried out if previous step has been completed."
    boolean: "Track formants", 1
    boolean: "Autoselect winners", 1
    boolean: "Get winners", 1
endPause: "Ok", 1

number_of_steps = number(number_of_steps$)
number_of_formants = number(number_of_formants$)

ending$ = right$ (folder$,1)
if ending$ == "/"
  folder$ = folder$ - "/"
endif
if ending$ == "\"
  folder$ = folder$ - "\"
endif

@saveSettings

daySecond = 0
save_csvs = 1

@daySecond
overAllStart = daySecond


if track_formants = 1
  @trackFolder
endif
if autoselect_winners = 1
  save_image = make_images_comparing_analyses
  @autoSelectFolder
endif
if get_winners = 1
  save_images = make_images_showing_winners
  @getWinnersFolder
endif

@daySecond
overAllEnd = daySecond
totalTime = overAllEnd - overAllStart
writeInfoLine: "Finished!"
appendInfoLine: "Process took: " + string$(totalTime) + " seconds."
