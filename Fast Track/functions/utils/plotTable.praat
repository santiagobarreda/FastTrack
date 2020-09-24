
procedure plotTable .sp, .tbl, .maximum_plotting_frequency, pointSize
  selectObject: .sp
  .total_duration = Get total duration
  Line width: 1
  Paint: 0, 0, 0, 0, 100, "yes", 50, 6, 0, "yes"
  Marks left every: 1, 500, "yes", "yes", "yes"
  Marks bottom every: 1, .total_duration/4, "yes", "yes", "yes"

  Line width: 2
  selectObject: .tbl
  Yellow
  Scatter plot (mark): "time", 0, .total_duration, "f1", 0, .maximum_plotting_frequency, pointSize+0.2, "no", "o"
  Lime
  Scatter plot (mark): "time", 0, .total_duration, "f2", 0, .maximum_plotting_frequency, pointSize+0.2, "no", "o"
  Cyan
  Scatter plot (mark): "time", 0, .total_duration, "f3", 0, .maximum_plotting_frequency, pointSize+0.2, "no", "o"
  Magenta
  nocheck Scatter plot (mark): "time", 0, .total_duration, "f4", 0, .maximum_plotting_frequency, pointSize+0.2, "no", "o"

  Colour: {255/256, 209/256, 26/256}
  Scatter plot (mark): "time", 0, .total_duration, "f1p", 0, .maximum_plotting_frequency, pointSize+0, "no", "."
  Green
  Scatter plot (mark): "time", 0, .total_duration, "f2p", 0, .maximum_plotting_frequency, pointSize+0, "no", "."
  Cyan
  Scatter plot (mark): "time", 0, .total_duration, "f3p", 0, .maximum_plotting_frequency, pointSize+0, "no", "."
  Blue
  Scatter plot (mark): "time", 0, .total_duration, "f3p", 0, .maximum_plotting_frequency, pointSize+0, "no", "."
  Red
  nocheck Scatter plot (mark): "time", 0, .total_duration, "f4p", 0, .maximum_plotting_frequency, pointSize, "no", "."

  Line width: 1

endproc
