
procedure getCoefficients

    beginPause: "Set Parameters"
      comment: "Indicate your working directory. This folder should contain a folder inside of it."
      comment: "called 'infos' that contains regression coefficients for each sound."
      sentence: "Working directory:", folder$
      optionMenu: "Number of formants:", number_of_formants
          option: "3"
          option: "4"
    endPause: "Ok", 1
    
    ending$ = right$ (folder$,1)
    if ending$ == "/"
      folder$ = folder$ - "/"
    endif
    if ending$ == "\"
      folder$ = folder$ - "\"
    endif

  .strs = Create Strings as file list: "list", folder$ + "/infos/*.txt"
  Save as short text file: folder$ +"/fileList.Strings"
  .nfiles = Get number of strings
  .basename$ = Get string: 1

  .info = Read Strings from raw text file: folder$ + "/infos/" + .basename$
  .tmp$ = Get string: 7
  number_of_coefficients_for_formant_prediction = number (.tmp$)

  .output = Create Table with column names: "output", .nfiles, "file"
  for j from 1 to (number_of_coefficients_for_formant_prediction+1)
    for i from 1 to number_of_formants
      Append column: "c"+string$(i)+string$(j)
    endfor
  endfor

  createDirectory: folder$ + "/processed_data/"


  for .iii from 1 to .nfiles
    selectObject: .strs
    .basename$ = Get string: .iii
    tmp$ = folder$ + "/infos/" + .basename$
    .info = Read Strings from raw text file: folder$ + "/infos/" + .basename$

    stringToVector_output# = {0,0,0,0,0,0}
    f1coeffs# = {0,0,0,0,0,0}
    f2coeffs# = {0,0,0,0,0,0}
    f3coeffs# = {0,0,0,0,0,0}

    if number_of_formants == 3
      .tmp$ = Get string: 18
      @stringToVector: .tmp$
      f1coeffs# = stringToVector_output#
      .tmp$ = Get string: 19
      @stringToVector: .tmp$
      f2coeffs# = stringToVector_output#
      .tmp$ = Get string: 20
      @stringToVector: .tmp$
      f3coeffs# = stringToVector_output#
    endif
    if number_of_formants == 4
      f4coeffs# = {0,0,0,0,0,0}
      .tmp$ = Get string: 19
      @stringToVector: .tmp$
      f1coeffs# = stringToVector_output#
      .tmp$ = Get string: 20
      @stringToVector: .tmp$
      f2coeffs# = stringToVector_output#
      .tmp$ = Get string: 21
      @stringToVector: .tmp$
      f3coeffs# = stringToVector_output#
      .tmp$ = Get string: 22
      @stringToVector: .tmp$
      f4coeffs# = stringToVector_output#
    endif


    selectObject: .output
    Set string value... .iii file '.basename$'
    for .i from 1 to (number_of_coefficients_for_formant_prediction+1)
      Set numeric value: .iii, "c1"+string$(.i), f1coeffs#[.i]
      Set numeric value: .iii, "c2"+string$(.i), f2coeffs#[.i]
      Set numeric value: .iii, "c3"+string$(.i), f3coeffs#[.i]
      Set numeric value: .iii, "c4"+string$(.i), f4coeffs#[.i]
    endfor
    removeObject: .info
  endfor

  selectObject: .output
  Save as comma-separated file: folder$ + "/processed_data/coefficients.csv"
  #Rename: "coefficients"
endproc
