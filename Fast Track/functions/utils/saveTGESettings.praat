
procedure saveTGESettings

  .settings = Read Strings from raw text file: "../settings/TGEsettings.txt"

  Set string: 1, sound_folder$
  Set string: 2, textGrid_folder$
  Set string: 3, output_folder$
  tmp$ = string$(segment_tier)
  Set string: 4, tmp$ 
  tmp$ = string$(word_tier)
  Set string: 5, tmp$ 
  tmp$ = string$(comment_tier1)
  Set string: 6, tmp$ 
  tmp$ = string$(comment_tier2)
  Set string: 7, tmp$ 
  tmp$ = string$(comment_tier3)
  Set string: 8, tmp$ 
  tmp$ = string$(omit_tier)
  Set string: 9, tmp$ 
  Set string: 10, stress_to_extract$
  Set string: 11, words_to_skip$
  tmp$ = string$(stress)
  Set string: 12, tmp$ 

  tmp$ = string$(maintain_separate)
  Set string: 13, tmp$ 
  tmp$ = string$(omit_tier)
  Set string: 14, tmp$ 


  Save as raw text file: "../settings/TGEsettings.txt"
  removeObject: .settings



endproc
