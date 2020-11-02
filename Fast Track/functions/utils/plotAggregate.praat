
procedure plotAggregate autorun

  # set parameter for specifying vowels. make table
  .clr_str = Create Strings as tokens: "Red Blue Green Magenta Black Lime Purple Teal Navy Pink Maroon Olive Grey", " ,"
  Rename: "colors"

  clicked = 2

  @getSettings

  while clicked == 2

  if autorun == 0
  ## need to think carefully about where this goes and when. 
  ## some of these need to be set differently in different calls. others need to be allowed to equal 
  ## what they equal in the overall function

    beginPause: "Set Parameters"
      boolean: "Erase", erase ;
      boolean: "Add axes", add_axes ;
      choice: "Type of plot:", type_of_plot
        option: "Contours"
        option: "Points"
      integer: "Number of bins:", number_of_bins
      optionMenu: "Color", 1
        option: "Multi"
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
      word: "Symbol column:", symbol_column$
      word: "Color column:", color_column$
      positive: "Which bin to plot:", which_bin_to_plot
      positive: "Font size:", font_size
      comment: "You can specify a symbol for each row, separated by a spae. This is a simple way to plot a small number of vowels."
      sentence: "Plotting symbols:", plotting_symbols$
      positive: "Minimum F1:", minimum_F1
      positive: "Maximum F1:", maximum_F1
      positive: "Minimum F2:", minimum_F2
      positive: "Maximum F2:", maximum_F2

    nocheck clicked = endPause: "Ok","Apply", 2

  endif

 if autorun == 1
   clicked = 1
  endif


  selectObject: .clr_str 
  .ncolors = Get number of strings

  selectObject: tbl

  if erase == 1
    Erase all
  endif

  if add_axes == 1
    Colour: "White"
    Font size: 14
    Scatter plot (mark): "f21", maximum_F2, minimum_F2, "f11", maximum_F1, minimum_F1, 5, "no", plotting_symbols$
    Draw inner box
    Marks bottom every: 1, 400, "yes", "yes", draw_grid
    Marks left every: 1, 200, "yes", "yes", draw_grid
    Text left: "yes", "F1 (Hz)"
    Text bottom: "yes", "F2 (Hz)"
  endif

  selectObject: tbl
  nrows = Get number of rows

  if plotting_symbols$ <> "--"
    .plot_symbols = Create Strings as tokens: plotting_symbols$, " ,"
    n = Get number of strings
    assert n == nrows
  endif


  for i from 1 to nrows
    for j from 1 to number_of_bins

      color_use$ = color$
      if color$ == "Multi"
        selectObject: .clr_str 
        color_use = (i mod (.ncolors)) + 1
        color_use$ = Get string: color_use
      endif

      selectObject: tbl
      color_use$ = Get value: i, color_column$

      Colour: color_use$
      if j > 1 and type_of_plot == 1
        oj = j - 1
        selectObject: tbl
        y1 = Get value: i, "f1"+string$(oj)
        y2 = Get value: i, "f1"+string$(j)
        x1 = Get value: i, "f2"+string$(oj)
        x2 = Get value: i, "f2"+string$(j)

        if point_size > 0
          Paint circle (mm): color_use$, x1, y1, point_size
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
        selectObject: tbl
        x = Get value: i, "f2"+string$(j)
        y = Get value: i, "f1"+string$(j)
        label$ = string$(i)

        if plotting_symbols$ <> "--"
          selectObject: .plot_symbols
          label$ = Get string: i
        endif

        if symbol_column$ <> "--"
          selectObject: tbl
          label$ = Get value: i, symbol_column$
        endif

        Text special: x, "Centre", y, "Half", "Helvetica", font_size, "0", label$
      endif
    endfor
  endfor

  endwhile

  nocheck removeObject: .plot_symbols
  nocheck removeObject: .clr_str

endproc