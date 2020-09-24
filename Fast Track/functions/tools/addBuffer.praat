
procedure addBuffer
  @getSettings

  beginPause: "Set Parameters"
    optionMenu: "", 1
    option: "[Click to Read]"
    option: "This function takes a folder of sound files and adds a specified amount of silence" 
    option: "to the begenning and end of each file."
    sentence: "Input sound folder:", ""
    sentence: "Output sound folder:", ""
    optionMenu: "", 1
    option: "[Click to Read]"
    option: "Setting the buffer to 0.025 allows formant tracking to the edge of the sound when using a 50ms "
    option: "analysis window, the default in Praat. If you use the functions in this plugin to extract"
    option: "sounds using TextGrids, the sound can be padded with its original context instead of zeros."
    comment: "How much time (in seconds) should be added to edges?"
    positive: "Buffer (s):", 0.025 

  endPause: "Ok", 1

  ending$ = right$ (folder$,1)
  if ending$ == "/"
    folder$ = folder$ - "/"
  endif
  if ending$ == "\"
    folder$ = folder$ - "\"
  endif
 
  obj = Create Strings as file list: "files", input_sound_folder$ + "/*.wav"
  nfiles = Get number of strings

  for i from 1 to nfiles
    selectObject: obj
    filename$ = Get string: i

    .snd = Read from file: input_sound_folder$ + "/" + filename$ 
    fs = Get sampling frequency

    sl1 = Create Sound from formula: "sl1", 1, 0, 0.333, fs, "0"
    selectObject: .snd
    Copy: "tmp_sound"
    sl2 = Create Sound from formula: "sl2", 1, 0, 0.333, fs, "0"

    selectObject: sl1, "Sound tmp_sound", sl2
    Concatenate

    Save as WAV file: output_sound_folder$ + "/" + filename$

    removeObject: .snd, sl1, sl2, "Sound tmp_sound", "Sound chain"

  endfor

  remobeObject: obj
endproc