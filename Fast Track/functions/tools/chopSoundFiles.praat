
procedure chopSoundFiles
  @getSettings

  beginPause: "Set Parameters"
    optionMenu: "", 1
    option: "[Click to Read]"
    option: "This function takes a folder of sound files and a corresponding folder" 
    option: "of textgrids. Each textgrid must contain a single interval. The function"
    option: "extracts the sound inside the interval and saves a copy of the file."  
    sentence: "Input sound folder:", ""
    sentence: "Input TextGrid folder:", ""
    sentence: "Output sound folder:", ""
    optionMenu: "", 1
    option: "[Click to Read]"
    option: "If sounds are extracted, how much time should be added to edges (0 = no padding)?"
    option: "Setting the buffer to 0.025 allows formant tracking to the edge of the sound when using"
    option: "a 50ms analysis window. Alternatively, sounds can be padded with zeros during analysis"
    option: "with the track sound or track folder functionalities."
    positive: "Buffer (s):", 0.025 

  nocheck endPause: "Ok", 1

  ending$ = right$ (folder$,1)
  if ending$ == "/"
    folder$ = folder$ - "/"
  endif
  if ending$ == "\"
    folder$ = folder$ - "\"
  endif
 
  obj = Create Strings as file list: "files", textGrid_folder$ + "/*.TextGrid"
  nfiles = Get number of strings

  for i from 1 to nfiles
    selectObject: obj
    filename$ = Get string: i
    basename$ = filename$ - ".TextGrid"

    .tg = Read from file: textGrid_folder$ + "/" + filename$
    nintervals = Get number of intervals: 1

    if (fileReadable: input_sound_folder$ + "/" + basename$ + ".wav") & (nintervals > 1)
      selectObject: .tg
      start = Get start time of interval: 1, 2
      end = Get end time of interval: 1, 2

      .snd = Read from file: input_sound_folder$ + "/" + basename$ + ".wav"
      .sndtmp = Extract part: start-buffer, end+buffer, "rectangular", 1, 0

      Save as WAV file: output_sound_folder$ + "/" + basename$ +".wav"

      removeObject: .sndtmp, .snd
    endif
    removeObject: .tg
  endfor

endproc