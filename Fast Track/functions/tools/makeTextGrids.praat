
procedure makeTextGrids
  @getSettings

  beginPause: "Set Parameters"
    sentence: "Folder:", ""
    boolean: "save sound", 1
    boolean: "save textgrid", 1
  endPause: "Ok", 1

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
      endPause: "OK", 0

      selectObject: .tg
      Set interval text: 1,2,"vowel"
      Save as short text file: folder$ + "/textGrids/" + basename$ + ".TextGrid"
      start = Get start time of interval: 1, 2
      end = Get end time of interval: 1, 2
                
      selectObject: .snd
      .snd_small = Extract part: start - 0.025, end + 0.025, "rectangular", 1, "no"
      Save as WAV file: folder$ + "/sounds/" + filename$  
                
      removeObject: .snd_small, .tg
    endif
    removeObject: .snd

  endfor

endproc