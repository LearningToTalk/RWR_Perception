# Code dependencies:
# include StimPrepStartupForm.praat
## for the session_parameters procedure, etc.
# include ../L2T-utilities/L2T-Utilities.praat

procedure audio_error: .directory$
                   ... .participant_number$
  printline
  printline
  printline <<<>>> <<<>>> <<<>>> <<<>>> <<<>>> <<<>>> <<<>>> <<<>>> <<<>>>
  printline
  printline ERROR :: No audio file was loaded
  printline
  printline Make sure the following directory exists on your computer:
  printline '.directory$'
  printline 
  printline Also, make sure that directory contains an audio
        ... file for participant '.participant_number$'.
  printline
  printline <<<>>> <<<>>> <<<>>> <<<>>> <<<>>> <<<>>> <<<>>> <<<>>> <<<>>>
  printline
  printline 
endproc

procedure audio_directory: .workstation$, .experimental_task$, .testwave$
	# Set the main trunk of the [.directory$] of the audio files for the current [.workstation$].
	@workstations
	if .workstation$ ==  workstations.slot$ [1]
		# Default setup. 14 = the string length for "\PraatScripts\"
		.dirLength = rindex_regex (defaultDirectory$, "/|\\") - 14
		.directory$ = left$(defaultDirectory$, .dirLength)
	elif .workstation$ == workstations.slot$ [2]
		# Mary's set-up, where audio is accessed locally...
		.directory$ = "/LearningToTalk/Tier2/DataAnalysis"
	elif .workstation$ == workstations.slot$ [3]
		# Pat's setup where the audio is accessed locally, but the other data are accessed through a VPN connection...
 		.directory$ = "/Volumes/liveoak/LearningToTalk"
	elif .workstation$ == workstations.slot$ [4]
		# Some previously un-encountered setup...
		.directory$ = ""
	endif
	# Complete the [.directory$] path only if the [.workstation$] has been previously encountered.
	if .workstation$ !=  "Other"
		.directory$ = .directory$ + "/" +
			... .experimental_task$ + "/" +
			... .testwave$
	# The organization of the recordings on Pat's external drive (i.e., when the [.workstation$] is [workstations.reidy_split$]) differs from how these files are organized for every other workstation.  So, [.directory$] must be completed differently for different workstations.
	if .workstation$ == "Reidy (Split)"
		.directory$ = .directory$ + "/" + "Audio"
	else
		.directory$ = .directory$ + "/" + "Recordings"
	endif
 	# If the [.workstation$] has not been encountered before, then the [.directory$] and [.pattern$] for finding audio files are both set to empty strings, since the structure of that workstation's filesystem cannot be guessed and it should be ensured that no audio file is loaded when the workstation is novel.
	else
		.directory$ = ""
	endif
endproc

#procedure audio_extension
#  .extension$ = if (macintosh or unix) then ".WAV" else ".wav" endif
#endproc

procedure audio_pattern: .directory$, .experimental_task$, .participant_number$
	if .directory$ != ""
		.pattern$ = .directory$ + "/" + 
			... .experimental_task$ + "_" + .participant_number$ + "*"
	else
		.pattern$ = ""
	endif
endproc

# procedure audio_filename: .pattern$
#   @filename_from_pattern: .pattern$, "audio file"
#   .filename$ = filename_from_pattern.filename$
# endproc

procedure audio_filename
	# Import string variables from other namespaces.
	.directory$ = audio_directory.directory$
	.experimental_task$ = session_parameters.experimental_task$
	.participant_number$ = audio.participant_number$
	# Use the imported string variables to create a base pattern for finding
	# audio files.
	.base_pattern$ = .directory$ + "/" + .experimental_task$ + "_" +
		... .participant_number$ + "*"
	# Create a Strings Object using 
	.pattern1$ = .base_pattern$ + ".WAV"
	Create Strings as file list: "WAV_files", .pattern1$
	.strings_obj1$ = selected$()
	if (macintosh or unix)
		# If on a Mac or a Unix machine, also search for audio files whose extension
		# is .wav.
		.pattern2$ = .base_pattern$ + ".wav"
		Create Strings as file list: "wav_files", .pattern2$
		.strings_obj2$ = selected$()
		# Append the two String objects.
		select '.strings_obj1$'
		plus '.strings_obj2$'
		Append
		Rename... audio_files
		.audio_files_obj$ = selected$()
		@remove: .strings_obj1$
		@remove: .strings_obj2$
	else
		# If on a Windows machine
		select '.strings_obj1$'
		Rename... audio_files
		.audio_files_obj$ = selected$()
	endif
	@filename_from_strings: .audio_files_obj$, "audio file"
	.filename$ = filename_from_strings.filename$
endproc

procedure audio_filepaths: .directory$, .filename$
	# If neither the [.directory$] nor the [.filename$] is an empty string, then
	# set the [.read_from$] and [.write_to$] directories by concatenating the
	# directory and filename.
	if (.directory$ <> "") & (.filename$ <> "")
		.read_from$ = .directory$ + "/" + .filename$
		.write_to$  = .directory$ + "/" + .filename$
	else
		.read_from$ = ""
		.write_to$  = ""
	endif
endproc

procedure load_audio: .filepath$
	if .filepath$ <> ""
		# Parse the [.filepath$]
		@parse_filepath: .filepath$
		# Print a message.
		printline Loading audio file 'parse_filepath.filename$' from
			... 'parse_filepath.directory$'
		# Extract the participant's ID from the audio filename.
		@participant: .filepath$, audio.participant_number$
		# Load the audio file as a Praat Sound object.
		Read from file... '.filepath$'
		Rename... 'participant.id$'_Audio
		# Store the name of the Praat Sound Object.
		.praat_obj$ = selected$()    
	else
		.praat_obj$ = ""
	endif
endproc

procedure audio: .currentParticipantID$
	# Import constants from the [session_parameters] namespace. 
	.workstation$ = session_parameters.workstation$
	.experimental_task$ = session_parameters.experimental_task$
	.testwave$ = session_parameters.testwave$

### Originally specified in the session_parameters procedure in L2T-StartupForm.praat
##	.participant_number$ = session_parameters.participant_number$
	# Create the participant_number$ variable for the error messages and such. 
	.participant_number$ = left$(.currentParticipantID$, 3)

	# Set the [.directory$] of the audio recordings.
	@audio_directory: .workstation$, .experimental_task$, .testwave$
	.directory$ = audio_directory.directory$
  
	# # Set the [.extension$] of the audio recordings.
	# @audio_extension
	# .extension$ = audio_extension.extension$
	#
	# # Set the [.pattern$] used to find audio recordings.
	# @audio_pattern: .directory$,
	#             ... .experimental_task$,
	#             ... .participant_number$,
	#             ... .extension$
	# .pattern$ = audio_pattern.pattern$
  
	# Set the [.filename$] of the audio recording.
	@audio_filename
	.filename$ = audio_filename.filename$

	# Set the [.read_from$] and [.write_to$] filepaths of the audio recording.
	@audio_filepaths: .directory$,
		... .filename$
	.read_from$ = audio_filepaths.read_from$
	.write_to$  = audio_filepaths.write_to$

	# Load the audio file as a Praat Sound object.
	@load_audio: .read_from$
	.praat_obj$ = load_audio.praat_obj$

	# Print an error message if a Praat Sound object was not created.
	if .praat_obj$ == ""
		@audio_error: .directory$,
			... .participant_number$
	endif

	.researchID$ = selected$ ("Sound")
	.researchID$ = left$ (.researchID$, 9)
endproc