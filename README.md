

<p align="center">
<img src="https://github.com/santiagobarreda/FastTrack/blob/master/docs/fasttrack.png?raw=true" width=630>
</p>   
&nbsp;

**A Praat plugin for fast, accurate, (nearly) automatic formant-tracking.** [[wiki]](https://github.com/santiagobarreda/FastTrack/wiki) [[paper]](https://drive.google.com/file/d/1RP0Lxj6PzCxaPsMQ53QXI0Kk-SwwETUl/view?usp=sharing) [[YouTube]](https://www.youtube.com/watch?v=WUFj2QUtuEs&t)

###




In order to get accurate formant measurements from a linear predictive coding (LPC) analysis, the user must set appropriate analysis parameters. In the example on the left, the maximum-formant frequency is too low and Praat is finding formants where there are none. On the right, a more appropriate maximum-formant frequency is used, leading to a better analysis. Manually adjusting analysis parameters until finding the right combination is time consuming, difficult to reproduce, and not systematic: characteristics which make it impractical and undesirable for large-scale projects. 

&nbsp;

<img src="https://github.com/santiagobarreda/FastTrack/blob/master/docs/badtrack.png?raw=true" width=400>    <img src="https://github.com/santiagobarreda/FastTrack/blob/master/docs/goodtrack.png?raw=true" width=400>

&nbsp;
&nbsp;

Fast Track speeds up formant tracking by automatically trying multiple maximum-formant settings and attempting to find the 'best' one for the user. The general algorithm is:
&nbsp;

 1) Formant tracking is carried out at multiple maximum-formant settings, always looking for 5.5 formants. 
 
 2) The goodness of each candidate is established by considering the smoothness of the formant trajectories (and optional heuristics).
 
 3) The 'best' analysis is selected as the winner. Images are made for visual verification.
 
 4) The user accepts the automatic selection, or indicates an alternate analysis.
 
 5) The user is given an opportunity to manually edit winners to ensure completely-accurate tracks.

&nbsp;

The above algorithm can be applied to a single file or to an entire folder at once. Fast Track generates (among other things): 

* CSV files containing the frequencies of F1-F4, predicted formant values (for error checking), formant bandwidths (F1-F4), f0, intensity, and harmonicity, each sampled every 2 ms (by default). 

* Images for the visual verification of final analyses, and for the comparison of alternate analysis.

* A log of the selected analyses, which can then be used to select alternate preferred analysis. 

* Detailed information regarding the analyses carried out for each sound.   

&nbsp;

For example, when Fast Track is run on the sound above we can have Fast Track select the best analysis for us:

<p align="center">
<img src="https://github.com/santiagobarreda/FastTrack/blob/master/docs/file_winner.png?raw=true" width=600>
</p>

&nbsp;

We can automatically generate an image comparing the alternate possible analyses (the winner has extra boxes):

<p align="center">
<img src="https://github.com/santiagobarreda/FastTrack/blob/master/docs/file_comparison.png?raw=true" width=700>
</p>

&nbsp;

[For more information please see the wiki](https://github.com/santiagobarreda/FastTrack/wiki)!
[Or check this paper out.](https://docs.google.com/document/d/1sNTL8xrzTTcX9zRLPB89UoSfalet2Xs9A6_WwB3a7oM/edit?usp=sharing)

### Author

**Santiago Barreda** - UC Davis, Linguistics (https://linguistics.ucdavis.edu/people/sbarreda)


### License

This project is licensed under the MIT License - see the [License](LICENSE) file for details


### Acknowledgments

This work is the implementation of the ideas presented in several previous works (more coming):

* Nearey, T. M., Assmann, P. F., & Hillenbrand, J. M. (2002). Evaluation of a strategy for automatic formant tracking. The Journal of the Acoustical Society of America, 112(5), 2323-2323.
* Wassink, A. B., & Koops, C. (2013). Quantifying and interpreting vowel formant trajectory information. In Best Practices in Sociophonetics Workshop at NWAV (Vol. 42).
* Weenink, D. (2015). Improved formant frequency measurements of short segments. In ICPhS.
