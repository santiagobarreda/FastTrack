# highlight csv file
# enter symbol
# override ranges
# dropdownmenu with colors
# checkbox for new or old


########################################################################################################################################################
########################################################################################################################################################
## Initial setup

include utils/importfunctions.praat


tbl = selected ("Table")



 plotting_symbols$ = "--"
 font_size = 28
 number_of_bins = 5
 add_axes = 1
 erase = 1
 which_bin_to_plot = 3
 all_points = 0
 line_width = 2
 type_of_plot = 1
 arrow_size = 1
 point_size = 1.5
 draw_grid = 0
 symbol_column$ = "label"
 color_column$ = "color"
 minimum_F1 = 200
 maximum_F1 = 1200
 minimum_F2 = 500
 maximum_F2 = 3000

@plotAggregate: 0
