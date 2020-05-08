
@getSettings

include tools/getSettings.praat
include tools/saveSettings.praat

beginPause: "Set Parameters"
    comment: "Set default parameter settings."
    sentence: "Default working directory:", folder$
    comment: "Recommended ranges: 4500-6500 for tall speakers, 5000-7000 for short speakers."
    positive: "Lowest analysis frequency (Hz):", lowest_analysis_frequency
    positive: "Highest analysis frequency (Hz):", highest_analysis_frequency
    comment: "Number of analyses between low and high analysis limits. More analysis steps may improve"
    comment: "results, but will increase analysis time (50% more steps = around 50% longer to analyze)."
		optionMenu: "Number of steps:", number_of_steps
			option: "8"
			option: "12"
			option: "16"
			option: "20"
			option: "24"
    comment: "More coefficients allow for more sudden, and 'wiggly' formant motion."
		positive: "Number of coefficients for formant prediction:", number_of_coefficients_for_formant_prediction
		positive: "Maximum plotting frequency (Hz):", maximum_plotting_frequency
		positive: "Time step (ms):", time_step
		sentence: "Tracking method:", tracking_method$
		sentence: "Basis functions:", basis_functions$
		sentence: "Error method:", error_method$

endPause: "Ok", 1

folder$ = default_working_directory$

@saveSettings
