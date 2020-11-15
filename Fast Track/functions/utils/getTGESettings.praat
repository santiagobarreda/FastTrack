
procedure getTGESettings


  .settings = Read Strings from raw text file: "../settings/TGEsettings.txt"

  sound_folder$ = Get string: 1
  
  textGrid_folder$ = Get string: 2
  
  output_folder$ = Get string: 3
  
  tmp$ = Get string: 4
  segment_tier = number (tmp$)
  
  tmp$ = Get string: 5
  word_tier = number (tmp$)
  
  tmp$ = Get string: 6
  comment_tier1 = number (tmp$)
  
  tmp$ = Get string: 7
  comment_tier2 = number (tmp$)
  
  tmp$ = Get string: 8
  comment_tier3 = number (tmp$)
  
  tmp$ = Get string: 9
  omit_tier = number (tmp$)
  
  stress_to_extract$ = Get string: 10
  
  words_to_skip$ = Get string: 11

  
  removeObject: .settings


endproc
