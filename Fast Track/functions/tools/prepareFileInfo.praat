
#include utils/importfunctions.praat
#@getSettings

procedure prepareFileInfo autorun

  if autorun == 0
    beginPause: "Set Parameters"
        comment: "Working directory:"
        sentence: "folder", folder$
        boolean: "Save CSV:", 1
    nocheck endPause: "Ok", 1
  endif

  if autorun == 1
    save_CSV = 1  
  endif

  strs = Create Strings as file list: "list", folder$ + "/sounds/*.wav"
  nfiles = Get number of strings

  file_info = Create Table with column names: "fileInformation", nfiles, "number file label group color"

  .clr_str = Create Strings as tokens: "Red Blue Green Magenta Black Lime Purple Teal Navy Pink Maroon Olive Grey", " ,"
  Rename: "colors"
  
  for i from 1 to nfiles
    selectObject: strs
    tmp$ = Get string: i

    selectObject: .clr_str 
    color_use = (i mod (13)) + 1
    color_use$ = Get string: color_use

    selectObject: file_info
    Set string value: i, "file", tmp$
    Set numeric value: i, "number", i
    Set string value: i, "color", color_use$
    Set numeric value: i, "group", 1
    Set string value: i, "label", "*"
  endfor

  if save_CSV == 1
    selectObject: file_info
    Save as comma-separated file: folder$ + "/file_information.csv"
  endif
  removeObject: file_info, .clr_str

endproc