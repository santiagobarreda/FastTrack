
#################################################################################################

## this needs to change to aggregate
## also it needs to loop across formants and time points
selectObject: "Table aggregated_data"
Append column: "gbar"
Formula... gbar (ln(self[row,"f11"])+ln(self[row,"f21"])+ln(self[row,"f31"])) / 3

#################################################################################################
## now there is a gbar column in coefficients. this needs to be aded to the regression table
## along with the dummy variable info

selectObject: "Table regression"
Append column: "gbar"

for i from 1 to nfiles
  # copy gbar
  selectObject: "Table aggregated_data"  
  tmp = Get value: i, "gbar"
  selectObject: "Table regression"  
  Set numeric value: i, "gbar", tmp

  ## set dummy
  ## this now can be taken from the file info csv file
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

#writeInfoLine: intercept, " ", vnum," ", snum
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








