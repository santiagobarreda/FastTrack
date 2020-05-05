
procedure plotTable .sp, .tbl, .maximum_plotting_frequency
  selectObject: .sp
  .total_duration = Get total duration
  Line width: 1
  Paint: 0, 0, 0, 0, 100, "yes", 50, 6, 0, "yes"
  Marks left every: 1, 500, "yes", "yes", "yes"
  Marks bottom every: 1, .total_duration/4, "yes", "yes", "yes"

  selectObject: .tbl
  Yellow
  Scatter plot (mark): "time", 0, .total_duration, "f1", 0, .maximum_plotting_frequency, 0.6, "no", "."
  Cyan
  Scatter plot (mark): "time", 0, .total_duration, "f2", 0, .maximum_plotting_frequency, 0.6, "no", "."
  Magenta
  Scatter plot (mark): "time", 0, .total_duration, "f3", 0, .maximum_plotting_frequency, 0.6, "no", "."
  Lime
  nocheck Scatter plot (mark): "time", 0, .total_duration, "f4", 0, .maximum_plotting_frequency, 0.6, "no", "."

  Yellow
  Scatter plot (mark): "time", 0, .total_duration, "f1p", 0, .maximum_plotting_frequency, 0.8, "no", "o"
  Cyan
  Scatter plot (mark): "time", 0, .total_duration, "f2p", 0, .maximum_plotting_frequency, 0.8, "no", "o"
  Magenta
  Scatter plot (mark): "time", 0, .total_duration, "f3p", 0, .maximum_plotting_frequency, 0.8, "no", "o"
  Lime
  nocheck Scatter plot (mark): "time", 0, .total_duration, "f4p", 0, .maximum_plotting_frequency, 0.8, "no", "o"
endproc
