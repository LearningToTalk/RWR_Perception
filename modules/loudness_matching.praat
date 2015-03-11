#determine praat version
ver1$ = left$(praatVersion$, (rindex(praatVersion$, ".")-1));
ver1 = 'ver1$'
if ver1 < 5.2
	exit Please download a more recent version of Praat
endif

if ver1 == 5.2
	ver2$ = right$(praatVersion$, length(praatVersion$) - (rindex(praatVersion$, ".")));
	ver2 = 'ver2$'
	if ver2 < 4
		exit Please download a more recent version of Praat (minor)
	endif
endif

beginPause ("Equalize RMS Levels Instructions")
	comment ("1. Select a folder containing the wave files to be normalized")
	comment ("2. Wave files will be analyzed and the optimal RMS value will be calculated")
	comment ("3. You may choose to reduce the optimal RMS value to a value if you wish")
	comment ("4. Select an output folder for the normalized wave files to be saved to")
	comment ("Click 'Next' to begin")
clicked = endPause("Next", 1);

#wavefile folder path
sourceDir$ = chooseDirectory$ ("Select folder containing wave files")
if sourceDir$ == ""
	exit Script exited. You did not select a folder.
else
	sourceDir$ = sourceDir$ + "/";
endif

Create Strings as file list... list 'sourceDir$'/*.mp3

numberOfFiles = Get number of strings
levels$ = ""
for ifile to numberOfFiles
	select Strings list
	currentList = selected ("Strings")
	filename$ = Get string... ifile
	Read from file... 'sourceDir$'/'filename$'
	currentSound = selected ("Sound")
	oldRmsLevel = Get root-mean-square... 0 0
	extremum = Get absolute extremum... 0 0 None
	oldRmsLevel = Get root-mean-square... 0 0
	newLevel = 0.99 * oldRmsLevel / extremum
	
	select currentSound
	Remove
	
	levels$ = levels$ + "'newLevel'" + ","
endfor

levels$ = left$ (levels$, length(levels$)-1)
minPa = min ('levels$')
minRMS = 20 * log10('minPa'/0.00002)
minRMS = floor('minRMS')
select currentList
Remove

beginPause ("Equalize RMS levels")
	comment ("This is the optimal RMS. You may set this to a lower value if you wish:")
	real("OptimalRMS", minRMS)
clicked = endPause("Next", 1);

#output folder path  - where the wave files get saved
outputDir$ = chooseDirectory$ ("Select folder to save wave files")
if outputDir$ == ""
	exit Script exited. You did not select a folder.
else
	outputDir$ = outputDir$ + "/";
endif

Create Strings as file list... list 'sourceDir$'/*.wav
numberOfFiles = Get number of strings
new_RMS_level = 0.00002 * 10^('optimalRMS'/20)
for ifile to numberOfFiles
	select Strings list
	currentList = selected ("Strings")
	filename$ = Get string... ifile
	Read from file... 'sourceDir$'/'filename$'
	currentSound = selected ("Sound")
	oldRmsLevel = Get root-mean-square... 0 0
	Formula... 'new_RMS_level'*self/'oldRmsLevel'
	extremum = Get absolute extremum... 0 0 None
	if extremum > 0.99
		exit We refuse to clip the samples in file "'sourceDir$'\'filename$'"!!!
	endif
	Write to WAV file... 'outputDir$'/'filename$'
	select currentSound
	Remove
endfor

#clean up
select currentList
Remove

#clear the info window
clearinfo
#print success message
printline Successfully equalized 'numberOfFiles' wave files.
