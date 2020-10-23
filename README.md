

<p align="center">
<img src="https://github.com/santiagobarreda/FastTrack/blob/master/docs/fasttrack.png?raw=true" width=630>
</p>   
&nbsp;

**A Praat plugin for fast, accurate, (nearly) automatic formant-tracking.** [[wiki]](https://github.com/santiagobarreda/FastTrack/wiki) [[paper]](https://drive.google.com/file/d/1RP0Lxj6PzCxaPsMQ53QXI0Kk-SwwETUl/view?usp=sharing) [[YouTube]](https://www.youtube.com/watch?v=NaAKJJaPD8Y&t)

###

In order to get accurate formant measurements from a linear predictive coding (LPC) analysis, the user must set appropriate analysis parameters. However, it is difficult to know what these are ahead of time. It can also be a pain to extract formant values and to correct analyses in the case of errors. All of these things can make accurate formant tracking tedious in many cases. 

Fast Track automatically runs multiple formant analyses on a given sound file, and tries to pick the best one (surrounded by extra boxes):

<p align="center">
<img src="https://raw.githubusercontent.com/santiagobarreda/FastTrack/master/docs/file_comparison.png" width=700>
</p>

And returns this the winning analysis to the user:

<p align="center">
<img src="https://github.com/santiagobarreda/FastTrack/blob/master/docs/file_winner.png?raw=true" width=600>
</p>

Along with CSV files containing detailed analysis information (formant frequencies and bandwidths, f0, harmonicity, intensity, etc.) sampled every 2 ms from the start to the end of the sound:

<p align="center">
<img src="https://github.com/santiagobarreda/FastTrack/blob/master/docs/csvoutput.png?raw=true" width=80%>
</p>

&nbsp;

  #### Tools and Functions
  
  Fast Track includes to (among other things):
  
* Extract vowel sounds from larger recordings with TextGrids files.

* Quick workflow for manually editing formant tracks. 

* Quickly make textgrids for folders of sound files.

* Aggregate fine-sampled data into coarser measures (e.g., average formants for every 20% of duration).


  
  #### Output
The above algorithm can be applied to a single file or to an entire folder at once. Fast Track generates (among other things): 

* CSV files containing the frequencies of F1-F4, predicted formant values (for error checking), formant bandwidths (F1-F4), f0, intensity, and harmonicity, each sampled every 2 ms (by default). 

* Images for the visual verification of final analyses, and for the comparison of alternate analysis.

* A log of the selected analyses, which can then be used to select alternate preferred analysis. 

* Detailed information regarding the analyses carried out for each sound.   

&nbsp;

#### Algorithm
The general algorithm is:
&nbsp;

 1) Formant tracking is carried out at multiple maximum-formant settings, always looking for 5.5 formants. 
 
 2) The goodness of each candidate is established by considering the smoothness of the formant trajectories (and optional heuristics).
 
 3) The 'best' analysis is selected as the winner. Images are made for visual verification.
 
 4) The user accepts the automatic selection, or indicates an alternate analysis.
 
 5) The user is given an opportunity to manually edit winners to ensure completely-accurate tracks.

&nbsp;  

&nbsp;

[For more information please see the wiki](https://github.com/santiagobarreda/FastTrack/wiki)!
[Or check this paper out.](https://drive.google.com/file/d/1RP0Lxj6PzCxaPsMQ53QXI0Kk-SwwETUl/view?usp=sharing)

### Author

**Santiago Barreda** - UC Davis, Linguistics (https://linguistics.ucdavis.edu/people/sbarreda)


### License

This project is licensed under the MIT License - see the [License](LICENSE) file for details


### Acknowledgments

This work is the implementation of the ideas presented in several previous works (more coming):

* Nearey, T. M., Assmann, P. F., & Hillenbrand, J. M. (2002). Evaluation of a strategy for automatic formant tracking. The Journal of the Acoustical Society of America, 112(5), 2323-2323.
* Wassink, A. B., & Koops, C. (2013). Quantifying and interpreting vowel formant trajectory information. In Best Practices in Sociophonetics Workshop at NWAV (Vol. 42).
* Weenink, D. (2015). Improved formant frequency measurements of short segments. In ICPhS.
