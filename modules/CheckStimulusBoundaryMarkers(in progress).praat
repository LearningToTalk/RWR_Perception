## Do I ned to worry about zero crossings?
## different initials for tagging and segmenting
## need to add word onset (tis is either consOnset or turbOnset

## Mary: Let's use the added "checker" column to figure out where to start the session.
## This will make the script more flexible, since we don't have to change the condition
## of the loop when we got to stimulus sets such as the one that we'll be building for 
## the TP2_S-SH_VAS and TP1_t-k_VAS experiments where both the stimOnset and stimOffset 
## tags are defined automatically, and what the checker is doing is just checking a stimulus
## and possibly adjusting already existing tags, rather than adding a stimOffset tag at the 
## end of the word, as in TP2_SibilantGoodness_VAS  and TP2_GenderRating_VAS experiment. 

procedure checkBoundaries
	if session_parameters.participant_number$ <> ""
		runOnlyOnSubset = 1
		@openNewSoundAndTextGrid
	else
		runOnlyOnSubset = 0
	endif

	###### 0. Main loop starts here 
	for index from 1 to numRows

		# Advance to the next unchecked token.
		@find_current_row: index
		index = find_current_row.current_row
		if index == numRows
			exit
		endif

		.stimStatus$ = ""

		select Table MainDataFrame
		.nextParticipantID$ = Get value: index, "ID"
		.nextParticipantID$ = left$(.nextParticipantID$, 3)

		# Load the audio file if need to do so, and load TextGrid (or start a new one) as appropriate. 
		if !runOnlyOnSubset and .nextParticipantID$ <> session_parameters.participant_number$

			# Setup for and initialization and first run-through of script.
			if session_parameters.participant_number$ <> ""
				removeObject(soundFile$)
				removeObject(stimulusTextGrid$)
			endif

			session_parameters.participant_number$ = .nextParticipantID$

			@openNewSoundAndTextGrid
		endif

		# Get information needed to populate the tag placement GUI.  
		@trialVariables

		selectObject: stimulusTextGrid$
		Insert boundary: stimulus_textgrid_tiers.stimStatus, trialVariables.startTime
		Insert boundary: stimulus_textgrid_tiers.stimStatus, trialVariables.endTime

		# Zoom to the current target production.
		@zoom: stimulusTextGrid$, trialVariables.startTime, trialVariables.endTime

		.stimOnset = trialVariables.startTime
		.stimOffset = trialVariables.endTime

		if trialVariables.origStimOnset == undefined
			@getMarker: "onset", trialVariables.startTime
			trialVariables.origStimOnset = getMarker.cursor
			.stimStatus$ = getMarker.status$
		endif

		Insert point: stimulus_textgrid_tiers.splicepoints, 'trialVariables.origStimOnset', "StimOnset"


		if trialVariables.origStimOffset == undefined
			@getMarker: "offset", trialVariables.endTime
			trialVariables.origStimOffset = getMarker.cursor
			.stimStatus$ = getMarker.status$
		endif

		Insert point: stimulus_textgrid_tiers.splicepoints, 'trialVariables.origStimOffset', "StimOffset"

		if .stimStatus$ == ""
			@finalizeBoundaries
			.stimOnset = finalizeBoundaries.stimOnset
			.stimOffset = finalizeBoundaries.stimOffset
			.stimStatus$ = finalizeBoundaries.stimStatus$
		endif

		@saveBoundaries: .stimOnset, .stimOffset
		@labelIntervals: .stimStatus$
		@addNote

		# Save textgrid			
		@save_stimulus_tiers


		# Update and save candidateStimuli.txt
		selectObject: "Table MainDataFrame"
		Set string value: index, "checker", session_parameters.initials$
		Set string value: index, "status", .stimStatus$
		Save as tab-separated file: stimPrepDirectory$ + "/candidateStimuli.txt"
	endfor
	######  0. End of main loop.
endproc

procedure finalizeBoundaries
	.stimOnset = trialVariables.origStimOnset
	.stimOffset = trialVariables.origStimOffset

	beginPause("Finalize Boundaries")
		comment("Participant 'session_parameters.participant_number$'  'trialVariables.trial_number$' : 'trialVariables.word$' : repetition 'trialVariables.repetition' ")
		comment("tagged as : 'trialVaribles.consType$' ; transcribed as : 'trialVariables.transcription$'")
			if trialVariables.segmNotes$ <> "?" and trialVariables.segmNotes$ <> ""
				comment("segmenter noted: 'trialVariables.segmNotes$'")
			endif
			if trialVariables.taggerNotes$ <> "?" and trialVariables.taggerNotes$ <> ""
				comment("tagger noted: 'trialVariables.taggerNotes$'")
			endif
	.onset_button = endPause: "Accept", "Adjust", "Reject", "Skip", "Quit", 1

	if .onset_button == 1
		.stimStatus$ = "ACCEPT"
	elif .onset_button == 2
		@adjustBoundary: trialVariables.origStimOnset, "stimOnset"
		.stimOnset = adjustBoundary.newPosition

		@adjustBoundary: trialVariables.origStimOffset, "stimOffset"
		.stimOffset = adjustBoundary.newPosition
		.stimStatus$ = "ADJUSTED"
	elif .onset_button == 3
		.stimStatus$ = "REJECT"
	elif .onset_button == 4
		.stimStatus$ = "SKIP"
	elif .onset_button == 5
		select all
		Remove
		exit
	endif
endproc

procedure saveBoundaries .stimOnset .stimOffset
	.pointIndex = Get nearest index from time: stimulus_textgrid_tiers.splicepoints, trialVariables.origStimOnset

	@moveCursorToZeroCrossing: .stimOnset
	.stimOnset = moveCursorToZeroCrossing.newPosition

	@moveCursorToZeroCrossing: .stimOffset
	.stimOffset = moveCursorToZeroCrossing.newPosition

	Remove point: stimulus_textgrid_tiers.splicepoints, .pointIndex
	Remove point: stimulus_textgrid_tiers.splicepoints, .pointIndex
	Insert point: stimulus_textgrid_tiers.splicepoints, trialVariables.origStimOnset, "OrigOnset"
	Insert point: stimulus_textgrid_tiers.splicepoints, trialVariables.origStimOffset, "OrigOffset"
	Insert boundary: stimulus_textgrid_tiers.filenames, .stimOnset
	Insert boundary: stimulus_textgrid_tiers.filenames, .stimOffset
endproc

procedure labelIntervals .stimStatus$
	.xmid = (trialVariables.startTime + trialVariables.endTime) / 2
	.current_interval = Get interval at time: stimulus_textgrid_tiers.stimStatus, .xmid
	.current_transcription$ = replace_regex$(trialVariables.transcription$, "[$:]", "", 3)
	.current_stimulus_filename$ = participant.id$ + trialVariables.trial_number$ + 
		... trialVariables.word$ + "_" + .current_transcription$ + "4" + trialVariables.targetC$

	Set interval text: stimulus_textgrid_tiers.filenames, .current_interval, .current_stimulus_filename$
	Set interval text: stimulus_textgrid_tiers.stimStatus, .current_interval, .stimStatus$
endproc

procedure adjustBoundary .originalPosition .whichBoundary$
	editor: stimulusTextGrid$
		Move cursor to... .originalPosition
	endeditor

	.pointIndex = Get nearest index from time: stimulus_textgrid_tiers.splicepoints, .originalPosition

	pause Move Cursor to preferred position for '.whichBoundary$'

	editor: stimulusTextGrid$
		.newPosition = Get cursor
	endeditor

	Remove point: stimulus_textgrid_tiers.splicepoints, .pointIndex
	Insert point: stimulus_textgrid_tiers.splicepoints, .newPosition, "StimOnset"
endproc

procedure addNote
	#### Need something a bit more elaborate than this, but this will do for now.
	beginPause("Finishing up")
		comment("Would you like to insert a note?")
		sentence: "Note", ""
	.notes_button = endPause: "No thanks", "Insert", 1

	if .notes_button == 2
		selectObject(stimulusTextGrid$)
		Insert point: stimulus_textgrid_tiers.checkerNotes, saveBoundaries.xmid, note$

		selectObject: "Table MainDataFrame"
		Set string value: index, "checkerNotes", note$
	endif
endproc

procedure moveCursorToZeroCrossing .originalPosition
	editor: stimulusTextGrid$
		Move cursor to... .originalPosition
		Move cursor to nearest zero crossing
		.newPosition = Get cursor
	endeditor
endproc

procedure find_current_row .current_row
	continueLooping = 1
	select Table MainDataFrame

	while continueLooping
		.participantID$  = Get value: .current_row, "ID"
		.participantID$ = left$ (.participantID$, 3)
		.checker$ = Get value: .current_row, "checker"

		if .checker$ ==  "?" or .checker$ == ""
			if !runOnlyOnSubset or .participantID$ == session_parameters.participant_number$
				continueLooping = 0
			else
				.current_row = .current_row + 1
			endif
		else
			.current_row = .current_row + 1
		endif

		if .current_row == numRows
			printline You have reached the end of candidateStimuli.txt
			select all
			Remove
			continueLooping = 0
		endif
	endwhile
endproc

procedure openNewSoundAndTextGrid
	@audio
	soundFile$ = audio.praat_obj$
	@participant: audio.read_from$, session_parameters.participant_number$
	@stimulus_textgrid: participant.id$
	stimulusTextGrid$ = stimulus_textgrid.praat_obj$

	# Open an Editor window, displaying the Sound object and the Stimuli TextGrid.
	@open_editor: stimulusTextGrid$,
		... soundFile$
endproc

procedure trialVariables
	select Table MainDataFrame

	.word$ = Get value: index, "Word"
	.trial_number$ = Get value: index, "TrialNumber"
	.repetition = Get value: index, "Repetition"
	.context$ = Get value: index, "Context"
	.consType$ = Get value: index, "consType"
	.targetC$ = Get value: index, "TargetC"
	.transcription$ = Get value: index, "transcription"
	.segmNotes$ = Get value: index, "SegmNotes"
	.taggerNotes$ = Get value: index, "TaggerNotes"
	.startTime = Get value: index, "XMin"
	.endTime = Get value: index, "XMax"
	.origStimOnset = Get value: index, "stimOnset"
	.origStimOffset = Get value: index, "stimOffset"
endproc

procedure getMarker .position$, default
	.cursor = default
	.status$ = ""

	beginPause("Put boundary at stimulus '.position$' for: ")
		comment("'session_parameters.participant_number$'  'trialVariables.trial_number$' : 'trialVariables.word$' : repetition 'trialVariables.repetition' ")
		comment("tagged as : 'trialVariables.consType$' ; transcribed as : 'trialVariables.transcription$'")
		if trialVariables.segmNotes$ <> "?" and trialVariables.segmNotes$ <> ""
			comment("segmenter noted: '.segmNotes$'")
		endif
		if trialVariables.taggerNotes$ <> "?" and trialVariables.taggerNotes$ <> ""
			comment("tagger noted: '.taggerNotes$'")
		endif
	.onset_button = endPause: "Quit", "Reject", "Mark '.position$'", 3

	if .onset_button == 1
		select all
		Remove
		exit
	elif .onset_button == 2
		.status$ = "REJECT"
	else
		editor: stimulusTextGrid$
			Move cursor to nearest zero crossing
			.cursor = Get cursor
		endeditor
	endif
endproc