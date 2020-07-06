
procedure chopSoundFiles
  @getSettings

  beginPause: "Set Parameters"
    sentence: "Input sound folder:", "E:\storage\OneDrive\_1_current-projects\repetition-experiment\11\sounds_original"
    sentence: "Output sound folder:", "E:\storage\OneDrive\_1_current-projects\repetition-experiment\11\sounds"
    sentence: "TextGrid folder:", "E:\storage\OneDrive\_1_current-projects\repetition-experiment\11\textgrids"
  endPause: "Ok", 1

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
      .sndtmp = Extract part: start-0.025, end+0.025, "rectangular", 1, 0

      Save as WAV file: output_sound_folder$ + "/" + basename$ +".wav"

      removeObject: .sndtmp, .snd
    endif
    removeObject: .tg
  endfor

endproc