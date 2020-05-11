
procedure chopSoundFiles

    folder$ = "C:\Users\sbarreda\OneDrive\GitHub\sounds"
    point_tiers$ = ""
    interval_tiers$ = "tier1"
    #toggle for save out wav file
    #toggle for maketextgrids
  
    # if corresponding selection is true
    createDirectory: folder$ + "/sounds"
    createDirectory: folder$ + "/textgrids"

    obj = Create Strings as file list: "files", folder$ + "/*.wav"
    nfiles = Get number of strings

    tiers$ = interval_tiers$ + " " + point_tiers$

    for i from 1 to nfiles
        selectObject: obj
        filename$ = Get string: i
        basename$ = filename$ - ".wav"
        .snd = Read from file: folder$ + "/" + filename$

        if !fileReadable: folder$ + "/textGrids/" + basename$ + ".TextGrid"
            .tg = To TextGrid: tiers$, point_tiers$
            selectObject: .snd, .tg
            View & Edit

            beginPause: ""
                comment: "Press OK when done to save."
            endPause: "OK", 0

            selectObject: .tg
            Set interval text: 1,2,"vowel"
            Save as text file: folder$ + "/textGrids/" + basename$ + ".TextGrid"
            start = Get start time of interval: 1, 2
            end = Get end time of interval: 1, 2
            
            selectObject: .snd
            .snd_small = Extract part: start - 0.025, end + 0.025, "rectangular", 1, "no"
            Save as WAV file: folder$ + "/sounds/" + filename$  
            
            removeObject: .snd_small, .tg

        endif

        removeObject: .snd

    endfor

endproc