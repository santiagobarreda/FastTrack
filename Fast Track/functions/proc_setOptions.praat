
include utils/getSettings.praat
include utils/saveSettings.praat

@getSettings
clicked = 2

menu = 1
while clicked <> 1
	beginPause: "Set Parameters"
 	  if menu == 1
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
		  positive: "Time step (s):", time_step
		  sentence: "Tracking method:", tracking_method$
		  sentence: "Basis functions:", basis_functions$
		  sentence: "Error method:", error_method$
		  comment: "If you have trouble seeing the bottom of some pause windows, tick this box:"
		  boolean: "Hide Click to Read boxes", hide_Click_to_Read_boxes
		endif
	if menu == 2
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
    boolean: "Enable rhotic heuristic:", enable_rhotic_heuristic
    boolean: "Enable F3F4 proximity heuristic:", enable_F3F4_proximity_heuristic
	endif

	if menu == 3
    boolean: "Output bandwidth:", output_bandwidth
    boolean: "Output predictions", output_predictions
    boolean: "Output pitch:", output_pitch
    boolean: "Output intensity:", output_intensity
    boolean: "Output harmonicity:", output_harmonicity
    boolean: "Output normlized time:", output_normalized_time
  endif

    optionMenu: "Menu", 1
    option: "Settings"
    option: "Heuristics"
    option: "CSV output"

	clicked = endPause: "Ok", "Switch Options", 1
endwhile

folder$ = default_working_directory$
@saveSettings
