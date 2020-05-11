
procedure checkErrors

	.strs = Read from file: folder$ +"/fileList.Strings"
  .nfiles = Get number of strings

	.tmp = Read Table from whitespace-separated file: folder$ + "/coefficients.txt"
	.coefficient_table = Down to TableOfReal: "vowel"
	removeObject: .tmp

	.discriminant_model = To Discriminant
	selectObject: .coefficient_table
	plusObject: .discriminant_model
	.classifications = To ClassificationTable: "yes", "no"

	writeFileLine: folder$ + "/error-check.txt", "file vowel prob winner prob error"
	for .i from 1 to .nfiles
		selectObject: .strs
		.basename$ = Get string: .i
		.basename$ = .basename$ - ".wav"

    selectObject: .classifications
	  .win_index = Get class index at maximum in row: .i
	  .winp = Get value: .i, .win_index
	  .winv$ = Get class label at maximum in row: .i
	  .actv$ = Get row label: .i
	  .act_index = Get column index: .actv$
	  .actp = Get value: .i, .act_index
	  .error = 1
	  if .winv$ == .actv$
	    .error = 0
	  endif
	  appendFileLine: folder$ + "/error-check.txt", .basename$," ",.actv$," ", .actp, " ", .winv$," ", .winp," ",.error
	endfor

endproc
