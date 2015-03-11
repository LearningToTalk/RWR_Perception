# A procedure that defines the structure of the TextGrid that is displayed in
# the Editor window during stimulus checking and tagging.
# There are three tiers (splicepoints, filenames, and checkerNotes) that are output 
# to the StimPrep/StimulusTextGrids directory.
procedure stimulus_textgrid_tiers
	# String constants for the tiers of a Burst Tagging TextGrid.
	.splicepoints = 1
	.filenames = 2
	.stimStatus = 3
	.checkerNotes = 4
	#.tier$ [1]= "splicepoints"
	#.tier$ [2] = "filenames"
	#.tier$ [3] = "checkerNotes"

	#.length = 3
	# String constants that facilitate creating a new Burst TextGrid
	#.all_tiers$ = .tier$ [1] + " " + .tier$ [2] + " " +.tier$ [3]  
	#.point_tiers$ = .tier$ [1] + " " +.tier$ [3] 
	.all_tiers$ = "splicepoints filenames stimStatus checkerNotes"
	.point_tiers$ = "splicepoints checkerNotes"
endproc

# A procedure for concatenating various strings to form a string-pattern that
# is used to search the filesystem for TextGrid containing the three 
# "Stimulus Tiers", i.e. the splicepoints, filenames, and checkerNotes tiers that
# are modified during stimulus checking and tagging.
procedure stimulus_tiers_pattern
	# Import constants from the [session_parameters] namespace.
	.initials$ = session_parameters.initials$
	.experiment_name$ = session_parameters.rwr_perception_experiment$
	.perception_experiment_directory$ = session_parameters.rwr_perception_experiment_directory$
	# Import the .currentParticipantID$ from the call to stimulus_textgrid in the main script
	# to set up the currentParticipantID$ variable.
	.currentParticipantID$ = stimulus_textgrid.currentParticipantID$
	# Set up the path to the [.directory$] of the Stimulus Checking / Tagging TextGrids.
	.directory$ = .perception_experiment_directory$ + "/" + 
		... "StimPrep" + "/" + 
		... "StimulusTextGrids"
	# Set up the string [.filename$] used to search for a stimulus TextGrid.
	.filename$ = .currentParticipantID$ + "_" +
		... .experiment_name$ + ".TextGrid"
	# Set up the string [.filepath$] used to search for a stimulus TextGrid.
	.filepath$ = .directory$ + "/" + .filename$
endproc

# A procedure for reading, from the filesystem, a TextGrid that contains the 
# Stimulus Checking / Tagging tiers.
procedure read_stimulus_tiers
	# Use the .filepath$ variable from stimulus_tiers_pattern for the .read_from$
	.read_from$ = stimulus_tiers_pattern.filepath$
	# The [.write_to$] path is the same as the [.read_from$] path.
	.write_to$ = .read_from$
	# Read in the stimulus checking / tagging tiers
	printline Loading Stimulus Checking / Tagging tiers from
		... 'stimulus_tiers_pattern.filename$' (found in
		... 'stimulus_tiers_pattern.directory$')
	Read from file... '.read_from$'
	Rename... StimulusTiers
	.praat_obj$ = selected$()
endproc

# A procedure for creating, from scratch, a TextGrid that contains the
# Stimulus Checking / Tagging tiers.
procedure initialize_stimulus_tiers
	# The [.read_from$] path is an empty string because the stimulus checking / tagging
	# TextGrid was not read from the filesystem.
	.read_from$ = ""
	# Set up the path that the Stimulus Checking / Tagging TextGrid will be written to.
	.write_to$ = stimulus_tiers_pattern.filepath$
	# Create a blank Stimulus Checking / Tagging TextGrid by annotating the audio object.
	@stimulus_textgrid_tiers
	printline Initializing Stimulus Checking / Tagging tiers
	select 'audio.praat_obj$'
	To TextGrid... "'stimulus_textgrid_tiers.all_tiers$'"
		... 'stimulus_textgrid_tiers.point_tiers$'
	Rename... StimulusTiers
	.praat_obj$ = selected$()
endproc

# A procedure for loading the Stimulus Checking / Tagging tiers.
procedure stimulus_textgrid: .currentParticipantID$
	# Search for the Stimulus Checking / Tagging tiers on the filesystem.
	@stimulus_tiers_pattern(.currentParticipantID$)
	if fileReadable(stimulus_tiers_pattern.filepath$)
		# If the Stimulus Checking / Tagging tiers were found on the filesystem, then read
		# them in.
		@read_stimulus_tiers
		# Import string constants from the [read_burst_tiers] namespace.
		.read_from$ = read_stimulus_tiers.read_from$
		.write_to$  = read_stimulus_tiers.write_to$
		.praat_obj$ = read_stimulus_tiers.praat_obj$
	else
		# If the Stimulus Checking / Tagging tiers were not found on the filesystem, then
		# create them.
		@initialize_stimulus_tiers
		# Import string constants from the [initialize_burst_tiers]
		# namespace.
		.read_from$ = initialize_stimulus_tiers.read_from$
		.write_to$  = initialize_stimulus_tiers.write_to$
		.praat_obj$ = initialize_stimulus_tiers.praat_obj$
	endif
endproc

# Saving the Stimulus Checking / Tagging TextGrid.
procedure save_stimulus_tiers
	select 'stimulus_textgrid.praat_obj$'
	Save as text file... 'stimulus_textgrid.write_to$'
endproc