# highlight csv file
# enter symbol
# override ranges
# dropdownmenu with colors
# checkbox for new or old


########################################################################################################################################################
########################################################################################################################################################
## Initial setup

tbl = selected ("Table")
basename$ = selected$ ("Table")

include utils/importfunctions.praat

clicked = 2
plotting_symbol$ = "a"
font_size = 18
number_of_bins = 5
add = 0
which_bin_to_plot = 3
all_points = 0
line_width = 2
type_of_plot = 1
arrow_size = 1
point_size = 1.5
draw_grid = 0
minimum_F1 = 200
maximum_F1 = 1200
minimum_F2 = 500
maximum_F2 = 3000

while clicked == 2

@getSettings

beginPause: "Set Parameters"
	boolean: "Add", add ;
  choice: "Type of plot:", type_of_plot
    option: "Contours"
    option: "Points"
  integer: "Number of bins:", number_of_bins
  optionMenu: "Color", 1
    option: "Red"
    option: "Blue"
    option: "Green"
    option: "Black"
    option: "Lime"
    option: "Purple"
    option: "Teal"
    option: "Navy"
    option: "Pink"
    option: "Maroon"
		boolean: "Draw grid", draw_grid ;
  comment: "Options for plotting vowel contours:"
  positive: "Line width:", line_width
  positive: "Arrow size:", arrow_size
  real: "Point size:", point_size
  comment: "Options for plotting symbols:"
  word: "Plotting symbol:", plotting_symbol$
  positive: "Which bin to plot:", which_bin_to_plot
	boolean: "All points", all_points ;
  positive: "Font size:", font_size
  comment: "Plot ranges:"
  positive: "Minimum F1:", minimum_F1
  positive: "Maximum F1:", maximum_F1
  positive: "Minimum F2:", minimum_F2
  positive: "Maximum F2:", maximum_F2

nocheck clicked = endPause: "Ok","Apply", 2


numberOfSelectedTables  = numberOfSelected ("Table")
if numberOfSelectedTables == 1
  tbl = selected ()
endif

selectObject: tbl


if add == 0
  Erase all
  Colour: "White"
  Font size: 14
  Scatter plot (mark): "f2", maximum_F2, minimum_F2, "f1", maximum_F1, minimum_F1, 5, "no", plotting_symbol$
  Draw inner box
  Marks bottom every: 1, 400, "yes", "yes", draw_grid
  Marks left every: 1, 200, "yes", "yes", draw_grid
  Text left: "yes", "F1 (Hz)"
  Text bottom: "yes", "F2 (Hz)"
endif

if type_of_plot == 2 and all_points == 1
  Colour: color$
  Scatter plot (mark): "f2", 3500, 800, "f1", 1200, 200, 5, "no", plotting_symbol$
endif


selectObject: tbl
nframes = Get number of rows
Append column: "bin"
for .j from 1 to nframes
  tmp = .j / (nframes/number_of_bins)
  Set numeric value: .j, "bin", ceiling( tmp )
endfor

statistic = 2
Colour: color$

for j from 1 to number_of_bins
  selectObject: tbl
  .tmp_tbl = Extract rows where column (number): "bin", "equal to", j
  for k from 1 to 2
    if statistic == 2
      .mf'k''j' = Get mean: "f"+string$(k)
    endif
    if statistic == 1
      .mf'k''j' = Get quantile: "f"+string$(k), 0.5
    endif
  endfor

  if j > 1 and type_of_plot == 1
    oj = j - 1
    y1 = .mf1'oj'
    y2 = .mf1'j'
    x1 = .mf2'oj'
    x2 = .mf2'j'
    if point_size > 0
      Paint circle (mm): color$, x1, y1, point_size
    endif
    Line width: line_width
    if j < number_of_bins
      Draw line: x1, y1, x2, y2
    endif
    if j == number_of_bins
      Arrow size: arrow_size
      Draw arrow: x1, y1, x2, y2
      Arrow size: 1
    endif
    Line width: 1
  endif

  if j == which_bin_to_plot and type_of_plot == 2
    x = .mf2'j'
    y = .mf1'j'
    Text special: x, "Centre", y, "Half", "Helvetica", font_size, "0", plotting_symbol$
  endif

  removeObject: .tmp_tbl
endfor

selectObject: tbl
Remove column: "bin"


endwhile


