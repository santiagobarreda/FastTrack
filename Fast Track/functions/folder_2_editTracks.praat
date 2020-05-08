
include tools/importFunctions.praat

@getSettings

beginPause: "Set Parameters"
		sentence: "Folder", folder$
		positive: "Maximum plotting frequency (Hz): ", maximum_plotting_frequency
		optionMenu: "Number of formants", number_of_formants
						option: "3"
						option: "4"
		boolean: "save formant", 1 ;
		boolean: "save csv", 1
		boolean: "save image", 1
endPause: "Ok", 1

ending$ = right$ (folder$,1)
if ending$ == "/"
	folder$ = folder$ - "/"
endif
if ending$ == "\"
	folder$ = folder$ - "\"
endif

createDirectory: folder$ + "/formants_edited"
createDirectory: folder$ + "/images_edited"

number_of_formants = number(number_of_formants$)

maximum_plotting_frequency = maximum_plotting_frequency
strs = Create Strings as file list: "list", folder$ + "/formants_edited/*_winner_.Formant"
nfiles = Get number of strings


for iii from 1 to nfiles
  selectObject: strs
  filename$ = Get string: iii
  basename$ = filename$ - "_winner_.Formant"
  fr = Read from file: folder$ + "/formants_edited/"+ filename$
  Rename: filename$ + "_edited_"

  snd = Read from file: folder$ + "/sounds/"+ basename$ + ".wav"
  total_duration = Get total duration
  sp = noprogress To Spectrogram: 0.007, maximum_plotting_frequency, 0.002, 5, "Gaussian"

  @editTracks: fr

  if save_image = 1
    Select outer viewport: 0, 7.5, 0, 4.5
    Save as 300-dpi PNG file: folder$+"/images_edited/"+basename$+"_edited.png"
  endif

  if save_formant = 1
    selectObject: fr
    deleteFile: folder$ + "/formants_edited/"+ filename$
    Save as short text file: folder$ + "/formants_edited/"+ basename$ + "_edited.Formant"
  endif

  if save_csv = 1
    @addAcousticInfoToTable: tbl, snd
  	selectObject: "Table output"
  	Save as comma-separated file: folder$ + "/csvs/"+ basename$ + ".csv"
  endif
  removeObject: snd, tbl, fr, sp

endfor

nocheck removeObject: strs
