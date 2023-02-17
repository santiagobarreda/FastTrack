

<p align="center">
<img src="https://raw.githubusercontent.com/santiagobarreda/vowelhost/main/FT-wiki/fasttrack.png?raw=true" width=630>
</p>   
&nbsp;

**A Praat plugin for fast(ish), accurate, (nearly) automatic formant-tracking.** [[wiki]](https://github.com/santiagobarreda/FastTrack/wiki) [[YouTube]](https://www.youtube.com/watch?v=NaAKJJaPD8Y&t)

[[download paper]](https://drive.google.com/file/d/1RP0Lxj6PzCxaPsMQ53QXI0Kk-SwwETUl/view?usp=sharing)

Citation:
[Barreda, S. (2021). Fast Track: fast (nearly) automatic formant-tracking using Praat. Linguistics Vanguard, 7(1)](https://doi.org/10.1515/lingvan-2020-0051)

###

Fast Track is a Praat plugin that makes accurate formant tracking fast and easy. Fast Track automatically runs multiple formant analyses on a given sound file, and tries to pick the best one for you (surrounded by extra boxes in the example below). 

Fast Track has built-in functions to help along every step of a vowel analysis project from start to finish (with more coming):
  
* Extract vowel sounds from larger recordings with TextGrids files.

* Automatic selection of the 'best' analysis.

* Automatically generate images of analysis for data validation. All alternate Analyses are saved for easy corrections. 

* Quick workflow for manually editing formant tracks. 

* Aggregate fine-sampled data into coarser measures (e.g., average formants for every 20% of duration).

* Automatic generation of images showing final analyses for data validation. 

* Automatic generation of data files containing fine-sampled acoustic analysis calculated every 2 ms along the vowel. 

Comparison of multiple analyses:

<p align="center">
<img src="https://raw.githubusercontent.com/santiagobarreda/vowelhost/main/FT-wiki/file_comparison.png" width=700>
</p>

Image of winning analysis:

<p align="center">
<img src="https://raw.githubusercontent.com/santiagobarreda/vowelhost/main/FT-wiki/file_winner.png" width=600>
</p>

CSV file containing analysis information (formant frequencies and bandwidths, f0, harmonicity, intensity, etc.) sampled every 2 ms from the start to the end of the sound:

<p align="center">
<img src="https://raw.githubusercontent.com/santiagobarreda/vowelhost/main/FT-wiki/csvoutput.png?raw=true" width=80%>
</p>

&nbsp;
 
#### Output
The plugin can analyze to a single file or to an entire folder of sounds at once. Fast Track generates (among other things): 

* CSV files containing the frequencies of F1-F4, predicted formant values (for error checking), formant bandwidths (F1-F4), f0, intensity, and harmonicity, each sampled every 2 ms (by default). 

* Images for the visual verification of final analyses, and for the comparison of alternate analysis.

* A log of the selected analyses, which can then be used to select alternate preferred analysis. 

* Detailed information regarding the analyses carried out for each sound.   

&nbsp;

#### Algorithm
&nbsp;

 1) Formant tracking is carried out at multiple maximum-formant settings, always looking for 5.5 formants. 
 
 2) The goodness of each candidate is established by considering the smoothness of the formant trajectories using a regression analysis (and optional heuristics).
 
 3) The 'best' analysis is selected as the winner. Images are made for visual verification.
 
 4) The user accepts the automatic selection, or indicates an alternate analysis.
 
 5) The user is given an opportunity to manually edit winners to ensure completely-accurate tracks.

&nbsp;  

&nbsp;

[For more information please see the wiki](https://github.com/santiagobarreda/FastTrack/wiki)!
[Or check this paper out.](https://drive.google.com/file/d/1RP0Lxj6PzCxaPsMQ53QXI0Kk-SwwETUl/view?usp=sharing)

#### Automation

FastTrack can be automated to run unsupervised via a Praat script that loads a wav file, sets FastTrack global settings, and calls the `trackAutoselect` procedure.

An example script is:

```
# what sound file do we want to analyse?
# (e.g. we want to analyse part of a file called 'my.wav')
Open long sound file... my.wav

# what part of the sound file do we want to analyze?
# (e.g. extract from 2s to 4s)
Extract part... 2.0 4.0 0
Rename... sample

# at what time in the sample do we want the measurement?
# (e.g. we want the formant values at the 1s instant in the 2s sample)
time = 1.0

# Load procedures necessary for unsupervised execution
# Check this file for information about parameters and outputs
include utils/trackAutoselectProcedure.praat

# Ensure all global settings have values
@getSettings
time_step = 0.002
enable_F1_frequency_heuristic = 1
maximum_F1_frequency_value = 1200
enable_F1_bandwidth_heuristic = 0
enable_F2_bandwidth_heuristic = 0
enable_F3_bandwidth_heuristic = 0
enable_F4_frequency_heuristic = 1
minimum_F4_frequency_value = 2900
enable_rhotic_heuristic = 1
enable_F3F4_proximity_heuristic = 1
output_bandwidth = 1
output_predictions = 1
output_pitch = 1
output_intensity = 1
output_harmonicity = 1
output_normalized_time = 1

# procedure parameters
dir$ = "."
lowestAnalysisFrequency = 5000
highestAnalysisFrequency = 7000
steps = 20
coefficients = 5
formants = 3
method$ = "burg"
image = 0
current_view = 0
max_plot = 4000
# Leave a formant object named after the sound in the Objects list:
out_formant = 2
out_table = 0
out_all = 0

# run FastTrack
@trackAutoselect: selected(), dir$, lowestAnalysisFrequency, highestAnalysisFrequency, steps, coefficients, formants, method$, image, selected(), current_view, max_plot, out_formant, out_table, out_all

# output results from formant object
f1 = Get value at time: 1, time, "hertz", "Linear"
f2 = Get value at time: 2, time, "hertz", "Linear"
print 'time' 'newline$'
print 'f1' 'newline$'
print 'f2' 'newline$'

# tidy up
Remove
select Sound sample
Remove
select LongSound soundfile
Remove
```

As the praat `include` procedure assumes paths are relative to the main script, the script must be saved in the `functions` directory (i.e. `Fast Track/functions/`).

***
If you use this, please cite it:

Barreda, S. (2021). Fast Track: fast (nearly) automatic formant-tracking using Praat. Linguistics Vanguard, 7(1). https://doi.org/10.1515/lingvan-2020-0051

Its the only way I can tell if people use it and what they use it for. Thanks!
***

### Author

**Santiago Barreda** - UC Davis, Linguistics (https://linguistics.ucdavis.edu/people/sbarreda)


### License

This project is licensed under the MIT License - see the [License](LICENSE) file for details


### Acknowledgments

This work is the implementation of the ideas presented in several previous works:

* Nearey, T. M., Assmann, P. F., & Hillenbrand, J. M. (2002). Evaluation of a strategy for automatic formant tracking. The Journal of the Acoustical Society of America, 112(5), 2323-2323.
* Wassink, A. B., & Koops, C. (2013). Quantifying and interpreting vowel formant trajectory information. In Best Practices in Sociophonetics Workshop at NWAV (Vol. 42).
* Weenink, D. (2015). Improved formant frequency measurements of short segments. In ICPhS.
* Zhang, C., Morrison, G. S., Enzinger, E., and Ochoa, F. (2013). Effects of telephone transmission on the performance of formant-trajectory-based forensic voice comparison – Female voices. Speech Communication, 55(6), 796–813. https://doi.org/10.1016/j.specom.2013.01.011
