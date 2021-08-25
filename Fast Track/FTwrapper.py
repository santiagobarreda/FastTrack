# -*- coding: utf-8 -*-
"""
Created on Tue Aug 24 11:36:12 2021

@author: nrbenway
"""
import parselmouth
import os

pathToPraat = 'C:\\Apps-SU\\xInstaller Folder\\Praat.exe'


"""
First, select settings

Default working folder: The functions will write output to this folder. For the folder analysis option, Fast Track will look for sounds to analyze in a subfolder called 'sounds', inside this working folder. By default, files will be written to the Fast Track folder.
    The filepath to the working folder must not have spaces.

Low cutoff frequency: The lowest analysis frequency that will be considered. Default is 4800 Hz.

High cutoff frequency: The highest analysis frequency that will be considered. Default is 6500 Hz.
        Appropriate highest and lowest frequencies will vary as a function of talker vocal-tract length, which is strongly related to height across all speakers. 
        Talkers can be grouped into broad categories of:
                tall (>5 foot 8): recommended range 4500-6500 Hz"
                medium (5 foot 8 >  > 5 foot 0): recommended range 5000-7000 Hz"
                short (<5 foot 0) recommended range 5500-7500 Hz"
        These categories correspond roughly to adult males, adult females (and teenagers), and younger children. However, there is substantial overlap between categories and variation within-category, so that adjustments may be required for individual voices."

Number of steps: The number of steps to be considered between the low and high analysis frequencies. Default is 16. 
        More analysis steps may improve results, but will increase analysis time and the amount of data generated: 50% more steps means a 50% longer analysis time, and 50% more generated files.

Number of coefficients: The maximum order of predictors for formant contours. The default is 5, meaning predictors are equivalent to a 5th order polynomial.
        More coefficients allow for more sudden, and 'wiggly' formant motion.

Maximum plotting frequency: Maximum plotting frequency for spectrograms when images are generated.

Time step: Analysis time steps, in seconds. Default is 0.002s, meaning that formants are estimated every 2 milliseconds. This should be low enough to result in enough samples to allow for modelling of formant contours.

Tracking method: 'burg' for standard LPC tracking, 'robust' for robust tracking.

Number of formants: The best analysis will be found on average across all desired formants. Often, F4 can be difficult to track so that the best analysis including F4 may not be the best analysis for F3 and below. 
        If you only want 3 formants,tracking 3 will ensure the analysis is optimized for those formants.

Basis functions: 'dct' for discrete cosine transform, 'polynomial' for Chebyshev polynomials (coming soon).

Error method: Right now it only uses the mean absolute deviation in residuals, and each formant is weighted equally. This penalizes outliers a little less than using the variance (no clue which is better in general).

Number of bins:  How many temporal bins should be used?

"""
folder = "C:\\Apps-SU\\Rhotic-Corpus-zExtras\\TripleTrackerTest\\UAC-Justish-Rhotics\\test\\" #must not have spaces
number_of_steps = "20"
number_of_coefficients_for_formant_prediction = "5"
lowest_analysis_frequency = "5000"
highest_analysis_frequency = "7000"
maximum_plotting_frequency = "10000"
time_step = "0.002"
tracking_method = "burg"
number_of_formants = "3"
basis_functions = "dct"
error_method = "mae"
number_of_bins = "11"
make_images_comparing_analyses = "0"
make_images_showing_winners = "1"
statistic = "median" #"median" or "mean"
show_progress = "1"
track_formants = "1"
autoselect_winners = "1"
get_winners = "1"
aggregate = "1"


settings = [folder, number_of_steps, number_of_coefficients_for_formant_prediction, lowest_analysis_frequency, highest_analysis_frequency, maximum_plotting_frequency,
            time_step, tracking_method, number_of_formants, basis_functions, error_method, number_of_bins, make_images_comparing_analyses,
            make_images_showing_winners, statistic, show_progress, track_formants, autoselect_winners, get_winners, aggregate]

with open(os.path.join(folder, 'settings.txt'), encoding="utf8", mode="w") as outfileS:
    for lineS in settings:
        outfileS.write(lineS + "\n")

"""
Then, set the heuristics.

The heuristics are:

    maximum F1 frequency: Median F1 frequency should not be higher than 1200 Hz. In my experience it is unusual for F1 frequencies to be higher than this, unless the speaker is very small and/or probucing an exceptionally 'open' vowel. This limit can be changed as necessary.
    
    minimum F2 frequency: Median F2 frequency when tracking rhotics should not be lower than individual's F2 floor (Hz). 

    maximum F2 bandwidth: median F2 bandwidth should not be higher than 500 Hz. In good recording conditions most F1 values will have pretty narrow bandwidths. This heuristic may cause problems with noisy data and should probably be set relative to the bandwidths you observe in your own data from measurements that you trust.

    maximum F3 bandwidth: median F3 bandwidth should not be higher than 600 Hz. Same caveats as the F1 bandwidth heuristic.

    minimum F4 frequency: It is extremely unusual to have an average F4 below 2900 Hz. Even Scottie Pippen's F4 is higher than this (listen to his voice).

    rhotic heuristic: if F3 < 2200 Hz, F1 and F2 should be at least 400 Hz apart. A lot of tracking errors feature a very low F3 and a very low F2. However, in most real rhotics F2 tends to be higher near F3 than it is to F1. So, this heuristic only accepts low F3 vowels when F1 and F2 are separated by a reasonable amount.

    minimum F3-F4 difference: if (F4 - F3) < 500 Hz, F1 and F2 should be at least 1500 Hz apart. When F3 and F4 are really close together, this will usually be a high fron vowel. This requires that F1 and F2 be reasonably separated.
    
"""
enable_F1_frequency_heuristic = '1'
maximum_F1_frequency_value = '1200'
enable_F1_bandwidth_heuristic = '0'
maximum_F1_bandwidth_value = '500'
enable_F2_frequency_heuristic = '1'
minimum_F2_frequency_value = '700' 
enable_F2_bandwidth_heuristic = '0'
maximum_F2_bandwidth_value = '600'
enable_F3_bandwidth_heuristic = '0'
maximum_F3_bandwidth_value = '900'
enable_F4_frequency_heuristic = '1'
minimum_F4_frequency_value = '2900'
enable_rhotic_heuristic = '1'
enable_F3F4_proximity_heuristic = '1'

heuristics = [enable_F1_frequency_heuristic, maximum_F1_frequency_value, enable_F1_bandwidth_heuristic, maximum_F1_bandwidth_value, enable_F2_frequency_heuristic, 
              minimum_F2_frequency_value, enable_F2_bandwidth_heuristic, maximum_F2_bandwidth_value, enable_F3_bandwidth_heuristic, maximum_F3_bandwidth_value, 
              enable_F4_frequency_heuristic, minimum_F4_frequency_value, enable_rhotic_heuristic, enable_F3F4_proximity_heuristic]

with open(os.path.join(folder, 'heuristics.txt'), encoding="utf8", mode="w") as outfileH:
    for lineH in heuristics:
        outfileH.write(lineH + "\n")


parselmouth.praat.run_file("C:\\Apps-SU\\FastTrack-master\\Fast Track\\functions\\folder_1_analyzeFolder_python_wrapper.praat", folder)

