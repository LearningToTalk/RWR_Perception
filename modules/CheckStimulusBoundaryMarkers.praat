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
	# Initialize the index for this session
	index = 1

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

	## Section below could be made into a procedure?
		# Get the information you need to populate the tag placement GUI.  
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

		selectObject: stimulusTextGrid$
		Insert boundary: stimulus_textgrid_tiers.stimStatus, .startTime
		Insert boundary: stimulus_textgrid_tiers.stimStatus, .endTime
		Insert point: stimulus_textgrid_tiers.splicepoints, '.origStimOnset', "StimOnset"
		Insert point: stimulus_textgrid_tiers.splicepoints, '.origStimOffset', "StimOffset"

		.xmid = (.startTime + .endTime) / 2
		current_interval = Get interval at time: stimulus_textgrid_tiers.stimStatus, .xmid

		# Zoom to the current target production.
		@zoom: stimulusTextGrid$, .startTime, .endTime

		# 1. Beginning of section to take care of the stimulus onset tag. 
		beginPause("Put boundary at stimulus beginning for: ")
			comment("Participant 'session_parameters.participant_number$'  '.trial_number$' : '.word$' : repetition '.repetition' ")
			comment("tagged as : '.consType$' ; transcribed as : '.transcription$'")
				if .segmNotes$ <> "NA"
					comment("segmenter noted: '.segmNotes$'")
				endif
				if .taggerNotes$ <> "NA"
					comment("tagger noted: '.taggerNotes$'")
				endif
		.onset_button = endPause: "Accept", "Adjust", "Reject", "Skip", "Quit", 1

		.stimOnset = .origStimOnset
		.stimOffset = .origStimOffset
		.pointIndex = Get nearest index from time: stimulus_textgrid_tiers.splicepoints, .origStimOnset

		if .onset_button == 1
			.stimStatus$ = "ACCEPT"
		elif .onset_button == 2
			@adjustBoundary: .origStimOnset, "stimOnset"
			.stimOnset = adjustBoundary.newPosition

			@adjustBoundary: .origStimOffset, "stimOffset"
			.stimOffset = adjustBoundary.newPosition
			.stimStatus$ = "ACCEPT"
		elif .onset_button == 3
			.stimStatus$ = "REJECT"
		elif .onset_button == 4
			.stimStatus$ = "SKIP"
		elif .onset_button == 5
			#.status$ = ""
			select all
			Remove
			exit
		endif

		@moveCursorToZeroCrossing: .stimOnset
		.stimOnset = moveCursorToZeroCrossing.newPosition

		@moveCursorToZeroCrossing: .stimOffset
		.stimOffset = moveCursorToZeroCrossing.newPosition

		Remove point: stimulus_textgrid_tiers.splicepoints, .pointIndex
		Remove point: stimulus_textgrid_tiers.splicepoints, .pointIndex
		Insert point: stimulus_textgrid_tiers.splicepoints, '.origStimOnset', "OrigOnset"
		Insert point: stimulus_textgrid_tiers.splicepoints, '.origStimOffset', "OrigOffset"

		Set interval text: stimulus_textgrid_tiers.stimStatus, current_interval, .stimStatus$

		Insert boundary: stimulus_textgrid_tiers.filenames, '.stimOnset'
		Insert boundary: stimulus_textgrid_tiers.filenames, '.stimOffset'

		current_transcription$ = replace_regex$(.transcription$, "[$:]", "", 3)
		current_stimulus_filename$ = participant.id$ + .trial_number$ + 
			... .word$ + "_" + current_transcription$ + "4" + .targetC$

		Set interval text: stimulus_textgrid_tiers.filenames, current_interval, current_stimulus_filename$

		#### Need something a bit more elaborate than this, but this will do for now.
		beginPause("Finishing up")
			comment("Would you like to insert a note?")
			sentence: "Note", ""
		.notes_button = endPause: "No thanks", "Insert", 1

		if .notes_button == 1
			.note$ = ""
		elif .notes_button == 2
			.note$ = note$
		endif

		# Take care of the TextGrid. 
		selectObject(stimulusTextGrid$)

		if .notes_button == 2
			Insert point: stimulus_textgrid_tiers.checkerNotes, .xmid, .note$
		endif

		# Save the textgrid.			
		@save_stimulus_tiers

		# 3. Take care of the MainDataFrame table.
		selectObject: "Table MainDataFrame"
		if .notes_button == 2
			Set string value: index, "checkerNotes", .note$
		endif

		Set string value: index, "checker", session_parameters.initials$
		Set string value: index, "status", .stimStatus$
 
		Save as tab-separated file: stimPrepDirectory$ + "/candidateStimuli.txt"
	endfor
	######  0. End of main loop.
endproc

procedure adjustBoundary .originalPosition .whichBoundary$
		editor: stimulusTextGrid$
			Move cursor to... .originalPosition
		endeditor

		#selectObject(stimulusTextGrid$)
		.pointIndex = Get nearest index from time: stimulus_textgrid_tiers.splicepoints, .originalPosition

		pause Move Cursor to preferred position for '.whichBoundary$'

		editor: stimulusTextGrid$
			.newPosition = Get cursor
		endeditor

		Remove point: stimulus_textgrid_tiers.splicepoints, .pointIndex
		Insert point: stimulus_textgrid_tiers.splicepoints, .newPosition, "StimOnset"
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

		if .checker$ == "NA"
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