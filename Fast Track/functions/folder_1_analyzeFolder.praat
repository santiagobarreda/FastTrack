
## collect all regression coefficients in one big csv file. recreate after, collect winners,

include utils/importfunctions.praat
include folder/trackFolder.praat
include folder/autoSelectFolder.praat
include folder/getWinnersFolder.praat

@getSettings

beginPause: "Set Parameters"
    optionMenu: "", 1
    option: "[Click to Read]"
    option: "Indicate your working directory. This folder should contain"
    option: "a folder inside of it called 'sounds' that contains all of"
    option: "the sounds you wish to analyze."
    sentence: "Folder:", folder$
    optionMenu: "", 1
    option: "[Click to Read]"
    option: "Appropriate highest and lowest frequencies will vary as a function of talker vocal-tract length,"
    option: "which is strongly related to height across all speakers. Talkers can be grouped into broad categories of:"
    option: "   tall (>5 foot 8): recommended range 4500-6500 Hz"
    option: "   medium (5 foot 8 >  > 5 foot 0): recommended range 5000-7000 Hz"
    option: "   short (<5 foot 0) recommended range 5500-7500 Hz"
    option: "These categories correspond roughly to adult males, adult females (and teenagers),"
    option: "and younger children. However, there is substantial overlap between categories and variation"
    option: "within-category, so that adjustments may be required for individual voices."		
    positive: "Lowest analysis frequency (Hz):", lowest_analysis_frequency
		positive: "Highest analysis frequency (Hz):", highest_analysis_frequency
    optionMenu: "", 1
      option: "[Click to Read]"
      option: "Number of analyses between low and high analysis limits. More analysis steps may"
	    option: "improve results, but will increase analysis time and the amount of data generated: "
      option: "50% more steps means a 50% longer analysis time, and 50% more generated files."		
    optionMenu: "Number of steps:", number_of_steps
			option: "8"
			option: "12"
			option: "16"
			option: "20"
			option: "24"
    optionMenu: "", 1
    option: "[Click to Read]"
    option: "More coefficients allow for more sudden, and 'wiggly' formant motion."
		positive: "Number of coefficients for formant prediction:", number_of_coefficients_for_formant_prediction
    optionMenu: "", 1
    option: "[Click to Read]"
      option: "The best analysis will be found on average across all desired formants."
      option: "Often, F4 can be difficult to track so that the best analysis including F4"
      option: "may not be the best analysis for F3 and below. If you only want 3 formants,"
      option: "tracking 3 will ensure the analysis is optimized for those formants."
    optionMenu: "Number of formants", number_of_formants
            option: "3"
            option: "4"
                optionMenu: "", 1
    option: "[Click to Read]"
    option: "Images are recommended as they facilitate data validation and the selection of "
    option: "alternate analyses. Making images can add 10%-20% more time to the analysis."
    boolean: "Make images comparing analyses", 1
    boolean: "Make images showing winners", 1
    positive: "Maximum plotting frequency (Hz):", maximum_plotting_frequency
     optionMenu: "", 1
    option: "[Click to Read]"
   option: "Uncheck to skip step. Individual steps can be"
   option: "carried out if previous step has been completed."
    boolean: "Track formants", 1
    boolean: "Autoselect winners", 1
    boolean: "Get winners", 1
nocheck endPause: "Ok", 1

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
