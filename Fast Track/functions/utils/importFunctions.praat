
include modeling/findError.praat
include modeling/predictFormants.praat

include utils/daySecond.praat
include utils/plotTable.praat
include utils/stringSplit.praat
include utils/getSettings.praat
include utils/saveSettings.praat
include utils/addAcousticInfoToTable.praat
include utils/editTracks.praat
include utils/extractVowels.praat
include utils/plotAggregate.praat
include utils/getTGESettings.praat
include utils/saveTGESettings.praat

include tools/aggregate.praat
include tools/aggregateAggregate.praat
include tools/aggregateTables.praat
include tools/addBuffer.praat
include tools/findOutliers.praat
include tools/getCoefficients.praat
include tools/editFolder.praat
include tools/chopSoundFiles.praat
include tools/makeTextGrids.praat
include tools/extractVowelswithTG.praat
include tools/prepareFileInfo.praat


versionPraat$ = left$(praatVersion$, (rindex(praatVersion$, ".")-1));
versionPraat = 'versionPraat$' 

if versionPraat < 6.1
   exit "Please download a more recent version of Praat."
endif
