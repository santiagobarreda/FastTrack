
procedure addAcousticInfoToTable .tbl, .snd

  selectObject: .tbl
  .nframes = Get number of rows
  ## append f0, intensity
  Append column: "f0"
  Append column: "intensity"
  Append column: "harmonicity"

  ## add pitch, intensity outside, move this out. new function
  selectObject: .snd
  .p1 = noprogress To Pitch: 0.002, 60, 350
  .p2 = noprogress Smooth: 10
  removeObject: .p1

  selectObject: .snd
  .i1 = noprogress To Intensity: 130, 0.002, "yes"
   
   selectObject: .snd
  .h = noprogress To Harmonicity (cc): 0.01, 75, 0.1, 1

  for .i from 1 to .nframes
    selectObject: .tbl
    .time = Get value... .i time
    
    selectObject: .p2
    .f0 = Get value at time: .time, "Hertz", "Linear"
    .f0 = round(.f0*10) / 10
    if .f0 = undefined
      .f0 = 0
    endif
    selectObject: .tbl
    Set numeric value... .i f0 .f0
    
    selectObject: .i1
    .intn = Get value at time: .time, "Cubic"
    .intn = round(.intn*10) / 10
    selectObject: .tbl
    Set numeric value... .i intensity .intn


    selectObject: .h
    .hrm = Get value at time: .time, "Cubic"
    .hrm = round(.hrm*10) / 10
    selectObject: .tbl
    Set numeric value... .i harmonicity .hrm

  endfor
  removeObject: .i1
  removeObject: .p2
  removeObject: .h

  if output_pitch == 0
    Remove column: "f0"
  endif
  if output_intensity == 0
    Remove column: "intensity"
  endif
  if output_harmonicity == 0
    Remove column: "harmonicity"
  endif

endproc
