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

include ../Utilities/L2T-Utilities.praat
include StimPrepStartupForm.praat
include StimPrepAudio.praat
include StimulusTextGrid.praat

# Set the session parameters.
defaultExpName = 1
defaultActivity = 1
index = 1
@session_parameters: defaultExpName, defaultActivity
stimPrepDirectory$ = session_parameters.perception_experiment_directory$ + "/StimPrep"
checker_initials$ = session_parameters.initials$

# Define the TextGrid tier names and indices.
@stimulus_textgrid_tiers

# Read Table from tab-separated file: defaultDirectory$ + "/candidateStimuli.txt"
Read Table from tab-separated file: stimPrepDirectory$ + "/candidateStimuli.txt"
Rename: "MainDataFrame"

# Count the number of rows.  
last_row_plus_one = Get number of rows
last_row_plus_one = 'last_row_plus_one' + 1

# Initialize the index
index = 1

## This was deleted from the stimPrepStartupForm.praat directory.  
#		# Prompt the user to enter the participant's ID number.
#		# --> Global variable [participant_ID$].
#		comment ("Please enter the participant's ID number in the field below.")
#		word ("Participant number", defaultParticipantID$)
## Here is where we could build a form for the user to choose from among the participant IDs available 
## in the candidateStimuli.txt file if we wanted to get fancy, but for now, we'll just get the participant ID
## from the next row that has not yet been processed. 
# participantID$ = ""

# Initialize the .currentParticipantID$ variable
# .currentParticipantID$ = participantID$
.currentParticipantID$ = ""

###### Main loop starts here 
while index < 'last_row_plus_one'
	# Advance to the next unchecked token. 
	@find_current_row: index
	index = find_current_row.current_row

	select Table MainDataFrame
	.nextParticipantID$ = Get value: index, "ID"

	if .nextParticipantID$ <> .currentParticipantID$
		# Setup for and initialization and first run-through of script.
		if .currentParticipantID$ <> ""
			removeObject(soundFile$)
			removeObject(stimulusTextGrid$)
		endif
		.currentParticipantID$ = .nextParticipantID$
		@audio: .currentParticipantID$
		.soundFile$ = audio.praat_obj$
		@stimulus_textgrid: .currentParticipantID$
		.stimulusTextGrid$ = stimulus_textgrid.praat_obj$

		# Open an Editor window, displaying the Sound object and the Stimuli TextGrid.
		@open_editor: .stimulusTextGrid$,
			... .soundFile$
	endif

## Section below could be made into a procedure. 
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
	.stimOnset$ = Get value: index, "stimOnset"

	@zoom: .stimulusTextGrid$, .startTime, .endTime

## Need to make a procedure that can be invoked for both stimOnset and stimOffset
## so that can handle cases where both are inserted by default. 
	if .stimOnset$ <> "NA"
		.stimOnset = '.stimOnset$'
		editor: .stimulusTextGrid$
			Move cursor to... .stimOnset
			Move cursor to nearest zero crossing
			.stimOnset = Get cursor
		endeditor

		selectObject(.stimulusTextGrid$)
		Insert point: stimulus_textgrid_tiers.splicepoints, '.stimOnset', "stimOnset"
		Insert boundary: stimulus_textgrid_tiers.filenames, '.stimOnset'
## Also need code to allow the checker to adjust the stimulus onset tag, if she's not happy 
## with it. 
	else
		beginPause("Put boundary at stimulus beginning for: ")
			comment("'.currentParticipantID$'  '.trial_number$' : '.word$' : repetition '.repetition' ")
			comment("tagged as : '.consType$' ; transcribed as : '.transcription$'")
			if .segmNotes$ <> "NA"
				comment("segmenter noted: '.segmNotes$'")
			endif
			if .taggerNotes$ <> "NA"
				comment("tagger noted: '.taggerNotes$'")
			endif
		.button = endPause: "Quit", "Skip", "Mark onset", 3
		if .button == 1
			select all
			Remove
			exit
		elif .button == 2
			index = index + 1
		elif .button == 3
			editor: .stimulusTextGrid$
				Move cursor to nearest zero crossing
				.stimOnset = Get cursor
			endeditor

			selectObject(.stimulusTextGrid$)
			Insert point: stimulus_textgrid_tiers.splicepoints, '.stimOnset', "stimOnset"
			Insert boundary: stimulus_textgrid_tiers.filenames, '.stimOnset'

			selectObject: "Table MainDataFrame"
			Set numeric value: index, "stimOnset", .stimOnset
## Don't save here, since want to take care of stimOffset first. 
# Save as tab-separated file: stimPrepDirectory$ + "/candidateStimuli.txt"		else
			printline "Was this the problem?"
		endif
	endif

### As noted above, this needs to be a procedure, so that we're doing the same thing
### for both stimOnset and stimOffset, and we're also accommodating to cases where
### both are already in the candidateStimuli.txt file. 
# Now for the stimOffset tag.
	beginPause("Put boundary at stimulus offset for: ")
			comment("'.currentParticipantID$'  '.trial_number$' : '.word$' : repetition '.repetition' ")
		comment("tagged as '.consType$' , transcribed as '.transcription$'")
		if .segmNotes$ <> "NA"
			comment("segmenter noted: '.segmNotes$'")
		endif
		if .taggerNotes$ <> "NA"
			comment("tagger noted: '.taggerNotes$'")
		endif
	.button = endPause: "Quit", "Skip", "Mark offset", 3

	if .button == 1
		select all
		Remove
		exit
	elif .button == 2
		index = index + 1
	elif .button == 3
		editor: .stimulusTextGrid$
				Move cursor to nearest zero crossing
				.stimOffset = Get cursor
		endeditor
		selectObject(.stimulusTextGrid$)
		Insert point: stimulus_textgrid_tiers.splicepoints, .stimOffset, "stimOffset"
		Insert boundary: stimulus_textgrid_tiers.filenames, .stimOffset
		.xmid = (.stimOnset + .stimOffset) / 2
		current_interval = Get interval at time: stimulus_textgrid_tiers.filenames, .xmid
		current_transcription$ = replace_regex$(.transcription$, "[$:]", "", 3)
		current_stimulus_filename$ = .currentParticipantID$ + .trial_number$ + 
			... .word$ + "_" + current_transcription$ + "4" + .targetC$
		Set interval text: stimulus_textgrid_tiers.filenames, current_interval, current_stimulus_filename$

		#### Need something a bit more elaborate than this, but this will do for now.
		beginPause("Finishing up")
			comment("Insert a note at the stimOnset if you wish to do so.")
		.notes_button = endPause: "Quit", "No thanks", "Insert", 2

		# Save the textgrid.			
		@save_stimulus_tiers

		# Take care of the MainDataFrame table, too.
		selectObject: "Table MainDataFrame"
		Set numeric value: index, "stimOffset", .stimOffset
		Set string value: index, "checker", checker_initials$
offending$ = stimPrepDirectory$ + "/candidateStimuli.txt"
printline 'offending$'
		Save as tab-separated file: stimPrepDirectory$ + "/candidateStimuli.txt"
	else
		printline "Was this the problem?"
	endif

endwhile

procedure find_current_row: .current_row
	select Table MainDataFrame

	continueLooping = 1
	while continueLooping
		.checker$ = Get value: .current_row, "checker"

		if .checker$ == "NA"
			continueLooping = 0
		else
			.current_row = .current_row + 1
		endif
	endwhile

endproc
