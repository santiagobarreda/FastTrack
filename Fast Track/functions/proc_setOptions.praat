
include utils/getSettings.praat
include utils/saveSettings.praat

@getSettings
optiontype = -1
clicked = 2

while clicked > 1
	beginPause: "Set Parameters"
	  if optiontype == -1
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
		endif

	if optiontype == 1
		comment: "Heuristics:"
	endif

	if optiontype == 1
	  boolean: "Enable F1 frequency heuristic:", enable_F1_frequency_heuristic
      positive: "Maximum F1 frequency value:", maximum_F1_frequency_value
    boolean: "Enable F1 bandwidth heuristic:", enable_F1_bandwidth_heuristic
      positive: "Maximum F1 bandwidth value:", maximum_F1_bandwidth_value
	  boolean: "Enable F2 bandwidth heuristic:", enable_F2_bandwidth_heuristic
      positive: "Maximum F2 bandwidth value:", maximum_F2_bandwidth_value
	  boolean: "Enable F3 bandwidth heuristic:", enable_F3_bandwidth_heuristic
      positive: "Maximum F3 bandwidth value:", maximum_F3_bandwidth_value
	  boolean: "Enable F4 frequency heuristic:", enable_F4_frequency_heuristic
      positive: "Minimum F4 frequency value:", minimum_F4_frequency_value
    boolean: "Enable F3F4 proximity heuristic:", enable_F3F4_proximity_heuristic
	endif
	clicked = endPause: "Ok", "Settings/Heuristics", 1
    if clicked == 2
	  optiontype = optiontype * -1	  
	endif
endwhile

folder$ = default_working_directory$
writeInfoLine: enable_F1_frequency_heuristic
@saveSettings
