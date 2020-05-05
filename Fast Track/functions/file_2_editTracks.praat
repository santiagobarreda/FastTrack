
snd = selected ("Sound")
fr = selected ("Formant")

include tools/importFunctions.praat
@getSettings

beginPause: "Set Parameters"
		positive: "Maximum plotting frequency (Hz): ", maximum_plotting_frequency
		optionMenu: "Number of formants", number_of_formants
						option: "3"
						option: "4"
		boolean: "save formant", 0 ;
		boolean: "return table", 1
    boolean: "save csv", 0
		boolean: "save image", 0
endPause: "Ok", 1

number_of_formants = number(number_of_formants$)

selectObject: snd
basename$ = selected$ ("Sound")
total_duration = Get total duration
sp = noprogress To Spectrogram: 0.007, maximum_plotting_frequency, 0.002, 5, "Gaussian"

@editTracks: fr
removeObject: sp

if save_image = 1
  Select outer viewport: 0, 7.5, 0, 4.5
  Save as 300-dpi PNG file: folder$+"/"+basename$+"_edited.png"
endif

if save_formant = 1
  selectObject: fr
  Save as short text file: folder$ + "/"+ basename$ + "_edited.Formant"
endif

if save_csv = 1
  @addAcousticInfoToTable: tbl, snd
  selectObject: "Table output"
  Save as comma-separated file: folder$ + "/"+ basename$ + ".csv"
endif

if return_table = 1
	selectObject: "Table output"
	Rename: basename$
endif
if return_table = 0
	removeObject: "Table output"
endif
