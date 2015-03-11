filenameTier = 2
stimStatusTier = 3

procedure segmentSoundFile
	if session_parameters.participant_number$ <> ""
		@segmentAudio
	else
		runOnlyOnSubset = 0
		@getListofTextGrids

		for i from 1 to numTextGrids
			selectObject: "Strings textGridList"
			textGrid$ = Get string... i
			session_parameters.participant_number$ = left$ (textGrid$, 3)
			@segmentAudio
			removeObject(soundFile$)
			removeObject(textGrid$)
		endfor 
	endif

	@normalizeStimuli

 	#Final clean up
	select all
	Remove
endproc

procedure segmentAudio
	@audio
	soundFile$ = audio.praat_obj$

	@participant: audio.read_from$, session_parameters.participant_number$

	.filename$ = participant.id$ + "_" + session_parameters.rwr_perception_experiment$
	.filepath$ = textGridDirectory$ + "/" + .filename$ + ".TextGrid"

	.exists = fileReadable(.filepath$)

	if .exists
		printline Loading TextGrid '.filename$' from 'textGridDirectory$'
		Read from file: .filepath$
		textGrid$ = selected$()

		selectObject: "Table MainDataFrame"
		Extract rows where column (text): "ID", "is equal to", participant.id$
		participantStimuliList$ = selected$()
		@populateFilenames
	else
		msg$ = "Unable to find a TextGrid for " + participant.id$ + " in the Experiment's StimPrep folder." 
		exitScript: msg$
	endif

	selectObject(textGrid$)
	numIntervals = Get number of intervals... filenameTier

	# This "for" loop iterates through the intervals of the textgrid, and selects the appropriate segment
	# for file extraction.  Also determines part of the name of the output file, based on the label of the
	# selected segment.  The the "if" statement allows the "for" loop to process only intervals that
	# correspond to non-blank intervals, skipping the blank intervals between sentences.

	for intervalNumber from 1 to numIntervals
		selectObject(textGrid$)
		.segmentedFileName$ = Get label of interval... filenameTier intervalNumber

		if .segmentedFileName$ <> ""
			.stimStatus$ = Get label of interval... stimStatusTier intervalNumber

			if .stimStatus$ == "ACCEPT" or .stimStatus$ == "ADJUSTED"
				@MakeWavSelection: intervalNumber, .segmentedFileName$
				.dur = Get total duration
				.dur = .dur * 1000

				selectObject(participantStimuliList$)
				.index = Search column: "Filename", .segmentedFileName$

				.word$ = Get value: .index, "Word"
				.targetC$ = Get value: .index, "TargetC"

				fileappend 'stimList$' 'participant.id$' 'tab$' '.filename$' 'tab$' '.word$' 'tab$' '.targetC$' 'tab$' '.dur' 'newline$'
			endif
		endif
	endfor

	selectObject(participantStimuliList$)
	Remove
endproc

procedure normalizeStimuli
	Create Strings as file list... list 'finalStimDirectory$'/*

	numberOfFiles = Get number of strings
	levels$ = ""
	for ifile to numberOfFiles
		select Strings list
		currentList = selected ("Strings")
		filename$ = Get string... ifile
		Read from file: finalStimDirectory$ + "/" + filename$
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

	Create Strings as file list... list 'finalStimDirectory$'/*.wav
	numberOfFiles = Get number of strings
	new_RMS_level = 0.00002 * 10^('optimalRMS'/20)
	for ifile to numberOfFiles
		select Strings list
		currentList = selected ("Strings")
		filename$ = Get string: ifile
		Read from file: finalStimDirectory$ + "/" + filename$
		currentSound = selected ("Sound")
		oldRmsLevel = Get root-mean-square... 0 0
		Formula... 'new_RMS_level'*self/'oldRmsLevel'
		extremum = Get absolute extremum... 0 0 None
		if extremum > 0.99
			exit We refuse to clip the samples in file 'filename$'"!!!
		endif
		Write to WAV file: finalStimDirectory$ + "/" + filename$

		select currentSound
		Remove
	endfor

	#clean up
	select currentList
	Remove

	#print success message
	printline Successfully equalized 'numberOfFiles' wave files.
endproc

# This procedure finds the onset and offset of the selected interval, finds the nearest
# zero-crossing to each, and saves these markers to the corresponding new tiers.  The
# wav selection determined by the zero-adjusted onset and offset is saved as a separate file
# with a name that includes the label of the original interval, the file index that links the selection
# to the mother file, and the interval number.  This final number is arbitrary, but ensures a unique
# file name for each new wav file, as it would otherwise be possible for two wav files to have the
# same name if that interval label was repeated more than once in a tier.  For instance, a given
# carrier phrase label could appear 3+ times in the carrier interval.

procedure MakeWavSelection .intervalNumber .intervalName$
	selectObject(textGrid$)
	.onset = Get start point... filenameTier .intervalNumber
	.offset = Get end point... filenameTier .intervalNumber

	selectObject(soundFile$)
	Extract part: .onset, .offset, "rectangular", 1, "no"
	printline Saving '.intervalName$'
	Save as WAV file: finalStimDirectory$ + "/" + .intervalName$ + ".wav"
endproc

procedure populateFilenames
	Append column: "Filename"
	numRows = Get number of rows

	for index from 1 to numRows
		.id$ = Get value: index, "ID"
		.word$ = Get value: index, "Word"
		.trial_number$ = Get value: index, "TrialNumber"
		.targetC$ = Get value: index, "TargetC"
		.transcription$ = Get value: index, "transcription"
		.current_transcription$ = replace_regex$(.transcription$, "[$:]", "", 3)

		.filename$ = .id$ + .trial_number$ + 
				... .word$ + "_" + .current_transcription$ + "4" + .targetC$
		Set string value: index, "Filename", .filename$
	endfor
endproc

procedure getListofTextGrids
	Create Strings as file list: "textGridList", textGridDirectory$ + "/*.TextGrid"
	numTextGrids = Get number of strings
endproc