

snd = selected ("Sound")
tbl = selected ("Table")

include utils/importfunctions.praat

@getSettings
beginPause: "Set Parameters"
		positive: "Maximum plotting frequency (Hz): ", maximum_plotting_frequency
endPause: "Ok", 1

maximum_plotting_frequency = maximum_plotting_frequency

selectObject: snd
total_duration = Get total duration
sp = To Spectrogram: 0.007, maximum_plotting_frequency, 0.002, 5, "Gaussian"
@plotTable: sp, tbl, maximum_plotting_frequency, 1

removeObject: sp
