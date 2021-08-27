# -*- coding: utf-8 -*-
"""
Created on Tue Aug 24 11:36:12 2021

@author: nrbenway
"""
import parselmouth
import os
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import math
import itertools

wkdir = os.path.dirname(os.path.abspath(__file__))
#%%
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
"""enter each value as strings"""
folder = "" #must not have spaces. This is the parent folder of /sounds/ subdirectory.
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
make_images_comparing_analyses = "1"
make_images_showing_winners = "1"
statistic = "1" #1 for "median" or 2 for "mean"
show_progress = "1"
track_formants = "1"
autoselect_winners = "1"
get_winners = "1"
aggregate = "1"


settings = [folder, number_of_steps, number_of_coefficients_for_formant_prediction, lowest_analysis_frequency, highest_analysis_frequency, maximum_plotting_frequency,
            time_step, tracking_method, number_of_formants, basis_functions, error_method, number_of_bins, make_images_comparing_analyses,
            make_images_showing_winners, statistic, show_progress, track_formants, autoselect_winners, get_winners, aggregate]

with open(os.path.join(folder, 'settings.txt'), encoding="utf8", mode="w") as outfileS: #save subject-specific settings file to support parallelization
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

with open(os.path.join(folder, 'heuristics.txt'), encoding="utf8", mode="w") as outfileH: #save subject-specific heuristics file to support parallelization
    for lineH in heuristics:
        outfileH.write(lineH + "\n")

#calling from Parselmouth will update return writeInfoWindow in real time 
parselmouth.praat.run_file(os.path.join(wkdir, "functions", "folder_1_analyzeFolder_python.praat"), folder) 



#%% make the comparison images
dynamic_range=50
if make_images_comparing_analyses == "1":
    print("Starting comparison image generation in Python...this may take a while...")
    sounds = sorted(os.listdir(os.path.join(folder, "sounds")))
    comparisons = sorted(os.listdir(os.path.join(folder, "comparisons")))

    for k, group in itertools.groupby(comparisons, lambda c: c.rpartition("_")[0]):
        if show_progress == "1":
            print(f'Generating comparison image for {k}')
        wavFP = os.path.join(folder, 'sounds', k + ".wav")
        snd = parselmouth.Sound(wavFP)
        spectrogram = snd.to_spectrogram()
        plots_per_row = 4
        fig, axs = plt.subplots(int(math.ceil(int(number_of_steps))/plots_per_row), plots_per_row, sharex=True, sharey=True, figsize=(14,10), dpi = 300)
        X, Y = spectrogram.x_grid(), spectrogram.y_grid()
        sg_db = 10 * np.log10(spectrogram.values)
        i,j=0,0
        for comparison in group:
            csv = pd.read_csv(os.path.join(folder, 'comparisons', comparison), encoding="utf8", dialect="excel")
            comparisonHz = comparison.rpartition("_")[-1].replace('.csv', "")
            axs[i][j].pcolormesh(X, Y, sg_db, vmin=sg_db.max() - dynamic_range, cmap='gray_r')
            axs[i][j].set_ylim([0, int(maximum_plotting_frequency)])
            axs[i][j].set_xlim([snd.xmin, snd.xmax])
            axs[i][j].set_title("Max Hz = " + str(comparisonHz),fontsize=12,ha='center')
            axs[i][j].scatter(csv['time'], csv['f1'], marker = "o", s=15, c='none', edgecolors='yellow', linewidths = .75)
            axs[i][j].scatter(csv['time'], csv['f2'], marker = "o", s=15, c='none', edgecolors='lime', linewidths = .75)
            axs[i][j].scatter(csv['time'], csv['f3'], marker = "o", s=15, c='none', edgecolors='cyan', linewidths = .75)
        
                
            axs[i][j].plot(csv['time'], csv['f1p'], color="#ffd11a")
            axs[i][j].plot(csv['time'], csv['f2p'], color="green")
            axs[i][j].plot(csv['time'], csv['f3p'], color="blue")
            
            if number_of_formants == "4":
                axs[i][j].scatter(csv['time'], csv['f4'], marker = "o", s=15, c='none', edgecolors='magenta', linewidths = .75)
                axs[i][j].plot(csv['time'], csv['f4p'], color="red")
            j+=1
            if j%plots_per_row==0:
                i+=1
                j=0
        fig.suptitle(comparison.rpartition("_")[0])
        fig.supxlabel("time [s]")
        fig.supylabel("frequency [Hz]")
        plt.tight_layout()
        plt.savefig(os.path.join(folder, 'images_comparison', k + ".png"), dpi = 300, format = "png")
        #plt.show()
        plt.close()



#%% make the winner image
def draw_spectrogram(spectrogram, csv, Hz, name, dynamic_range=50):
    X, Y = spectrogram.x_grid(), spectrogram.y_grid()
    sg_db = 10 * np.log10(spectrogram.values)
    plt.pcolormesh(X, Y, sg_db, vmin=sg_db.max() - dynamic_range, cmap='gray_r')
    plt.xlabel("time [s]")
    plt.ylabel("frequency [Hz]")
    plt.ylim([0, int(maximum_plotting_frequency)])
    plt.xlim([snd.xmin, snd.xmax])

    plt.title(name + "\nMaximum Formant = " + str(Hz))
    
    plt.scatter(csv['time'], csv['f1'], marker = "o", s=15, c='none', edgecolors='yellow', linewidths = .75)
    plt.scatter(csv['time'], csv['f2'], marker = "o", s=15, c='none', edgecolors='lime', linewidths = .75)
    plt.scatter(csv['time'], csv['f3'], marker = "o", s=15, c='none', edgecolors='cyan', linewidths = .75)

        
    plt.plot(csv['time'], csv['f1p'], color="#ffd11a")
    plt.plot(csv['time'], csv['f2p'], color="green")
    plt.plot(csv['time'], csv['f3p'], color="blue")
    
    if number_of_formants == "4":
        plt.scatter(csv['time'], csv['f4'], marker = "o", s=15, c='none', edgecolors='magenta', linewidths = .75)
        plt.plot(csv['time'], csv['f4p'], color="red")
    
if make_images_showing_winners == '1':
    print("Starting winning image generation in Python...")
    winnerHz = pd.read_csv(os.path.join(folder, 'processed_data', 'aggregated_data.csv'), encoding="utf8", dialect="excel")
    winnerHz = pd.Series(winnerHz.cutoff.values,index=winnerHz.file).to_dict()
    csvs = os.listdir(os.path.join(folder, "csvs"))
    for csvName in csvs:
        if show_progress == "1":
            print(f'Generating winning image for {csvName.replace(".csv", "")}')
        csvFP = os.path.join(folder, 'csvs', csvName)
        wavFP = os.path.join(folder, 'sounds', csvName).replace(".csv", ".wav")
        snd = parselmouth.Sound(wavFP)
        csv = pd.read_csv(csvFP, encoding="utf8", dialect="excel")
        winningHz = winnerHz.get(csvName.replace(".csv", ""))
        spectrogram = snd.to_spectrogram()
        f = plt.figure()
        draw_spectrogram(spectrogram, csv, winningHz, csvName.replace(".csv", ""))
        plt.savefig(os.path.join(folder, "images_winners", csvName.replace(".csv", ".png")), dpi = 300, format = "png")
        #plt.show()
        plt.close()

print("Python Wrapper to Fast Track has completed.")    
