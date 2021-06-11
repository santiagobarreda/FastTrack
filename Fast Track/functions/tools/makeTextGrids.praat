
procedure makeTextGrids
  @getSettings

  beginPause: "Set Parameters"
    comment: "Path to folder containing sounds"
    sentence: "Folder:", ""
    comment: "Label for TextGrid interval corresponding to vowel."
    sentence: "Label:", ""
    comment: "If selected, vowels will be extracted and saved in new files."
    boolean: "save sound", 1
	if not hide_Click_to_Read_boxes
		optionMenu: "", 1
		option: "[Click to Read]"
		option: "If sounds are extracted, how much time should be added to edges (0 = no padding)?"
		option: "Setting the buffer to 0.025 allows formant tracking to the edge of the sound when using"
		option: "a 50ms analysis window. Alternatively, sounds can be padded with zeros during analysis"
		option: "with the track sound or track folder functionalities."
	endif
    positive: "Buffer (s):", 0.025 
    comment: "If selected, TextGrid files will be saved."
    boolean: "save textgrid", 1
  nocheck endPause: "Ok", 1

  ending$ = right$ (folder$,1)
  if ending$ == "/"
    folder$ = folder$ - "/"
  endif
  if ending$ == "\"
    folder$ = folder$ - "\"
  endif
 
  #if corresponding selection is true
  if save_sound == 1
    createDirectory: folder$ + "/sounds"
  endif
  if save_textgrid == 1
    createDirectory: folder$ + "/textgrids"
  endif

  obj = Create Strings as file list: "files", folder$ + "/*.wav"
  nfiles = Get number of strings

  for i from 1 to nfiles
    selectObject: obj
    filename$ = Get string: i
    basename$ = filename$ - ".wav"
    .snd = Read from file: folder$ + "/" + filename$

    if !fileReadable: folder$ + "/textGrids/" + basename$ + ".TextGrid"
      .tg = To TextGrid: "segments", ""
      selectObject: .snd, .tg
      View & Edit

      beginPause: ""
        comment: "Press OK when done to save."
      nocheck endPause: "OK", 0

      selectObject: .tg
      Set interval text: 1,2, label$
      Save as short text file: folder$ + "/textGrids/" + basename$ + ".TextGrid"
      start = Get start time of interval: 1, 2
      end = Get end time of interval: 1, 2
                
      selectObject: .snd
      .snd_small = Extract part: start - buffer, end + buffer, "rectangular", 1, "no"
      Save as WAV file: folder$ + "/sounds/" + filename$  
                
      removeObject: .snd_small, .tg
    endif
    removeObject: .snd

  endfor

endproc