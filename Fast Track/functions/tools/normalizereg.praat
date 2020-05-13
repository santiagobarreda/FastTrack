
#################################################################################################
selectObject: "Table token-info"
Sort rows: "vowel"
nfiles = Get number of rows

Copy: "token-info-num"

# gets first vowel label
selectObject: "Table token-info"
lastvowel$ = Get value: 1, "vowel"  
vnum = 1

## will contain all the dummy variables
Create Table with column names: "regression", nfiles, "v1"
Formula: "v1", "0"

# first pass is vowels
selectObject: "Table token-info"
Sort rows: "vowel"
selectObject: "Table token-info-num"
Sort rows: "vowel"
for i from 1 to nfiles  
  selectObject: "Table token-info"
  tmpvowel$ = Get value: i, "vowel"
 
  if lastvowel$ <> tmpvowel$ 
    vnum = vnum + 1
    selectObject: "Table regression"
    Append column: "v" + string$(vnum)
    Formula: "v" + string$(vnum), "0"
    lastvowel$ = tmpvowel$
  endif

  selectObject: "Table token-info-num"
  Set numeric value: i, "vowel", vnum

endfor 

# second pass is speakers
selectObject: "Table token-info"
lastspeaker$ = Get value: 1, "speaker"  
snum = 1
Sort rows: "speaker"
selectObject: "Table token-info-num"
Sort rows: "speaker"

selectObject: "Table regression"
Append column: "s1"
Formula: "s1", "0"

for i from 1 to nfiles  
  selectObject: "Table token-info"
  tmpspeaker$ = Get value: i, "speaker"

  if lastspeaker$ <> tmpspeaker$
    snum = snum + 1
    selectObject: "Table regression"
    Append column: "s" + string$(snum)
    Formula: "s" + string$(snum), "0"
    lastspeaker$ = tmpspeaker$
  endif

  selectObject: "Table token-info-num"
  Set numeric value: i, "speaker", snum
endfor 

selectObject: "Table token-info-num"
Sort rows: "file"

## at this point theres is a working empty design matrix, with all named columns
## I also know how many of each factor there is and have a number matrix indicating 
# the category of each 


selectObject: "Table coefficients"
Append column: "gbar"
Formula... gbar (ln(self[row,"c11"])+ln(self[row,"c11"])+ln(self[row,"c11"])+ln(self[row,"c11"])) / 4

#################################################################################################
## now there is a gbar column in coefficients. this needs to be aded to the regression table
## along with the dummy variable info

selectObject: "Table regression"
Append column: "gbar"

for i from 1 to nfiles
  # copy gbar
  selectObject: "Table coefficients"  
  tmp = Get value: i, "gbar"
  selectObject: "Table regression"  
  Set numeric value: i, "gbar", tmp

  ## set dummy
  selectObject: "Table token-info-num"  
  tmpv = Get value: i, "vowel"
  tmps = Get value: i, "speaker"

  selectObject: "Table regression"  
  Set numeric value: i, "v"+string$(tmpv), 1
  Set numeric value: i, "s"+string$(tmps), 1

endfor 

Remove column: "v1"
Remove column: "s1"


#################################################################################################
## normalization part

linreg = To linear regression
info$ = Info
intercept = extractNumber (info$, "Intercept: ")

writeInfoLine: intercept, " ", vnum," ", snum
s1 = 0
v1 = 0
for i from 2 to snum
 s'i' = extractNumber (info$, "Coefficient of factor s" + string$(i)+ ": ")
endfor

for i from 2 to vnum
 v'i' = extractNumber (info$, "Coefficient of factor v" + string$(i)+ ": ")
endfor

selectObject: "Table token-info-num"
Append column: "gbar"
Append column: "gbarhat"
Append column: "residual"

for i from 1 to nfiles

  selectObject: "Table coefficients"  
  tmp = Get value: i, "gbar"

  selectObject: "Table token-info-num"  
  s = Get value: i, "speaker"
  v = Get value: i, "vowel"

  Set numeric value: i, "gbar", tmp
  Set numeric value: i, "gbarhat", intercept + s's' + v'v'
  Set numeric value: i, "residual", tmp - (intercept + s's' + v'v')

endfor 

selectObject: "Table coefficients"  
Remove column: "gbar"

removeObject: "Table regression"
#removeObject: "Table token-info-num"



# now given these gbarhats, I can pick best alternate analyses
# actually it would be better to do the whole full regression with formantxvowel predictor, but Im not ready for that yet I dont think








