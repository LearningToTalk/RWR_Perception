if !variableExists("defaulInitials$")
	defaultInitials$ = ""
endif

if !variableExists("defaultExpName$")
	defaultExpName = 1
endif

if !variableExists("defaultActivity$")
	defaultActivity = 1
endif

procedure workstations
	# Define vector of workstations.
	.slot$ [1] = "Default"
	.slot$ [2] = "Beckman (Split)"
	.slot$ [3] = "Reidy (Split)"
	.slot$ [4] = "Other"

	.length = 4
endproc

procedure experiment_names
	# Define the vector of experiment names.
	.slot$ [1]= "TP2_SibilantGoodness_VAS"
	.slot$ [2] = "TP2_S-SH_VAS"
	.slot$ [3] = "TP2_ObstruentsGender_VAS"

	.length = 3
endproc

procedure praat_activities
	# Define vector of activities in Praat.
	.slot$ [1] = "Tag word or CV boundaries for candidate stimuli"
	.slot$ [2] = "Check a boundary-tagged stimulus TextGrid"
	.slot$ [3] = "Extract audio files for candidate stimuli"
	.slot$ [4] = "Listen to all extracted stimulus files"
	.slot$ [5] = "Other"

	.length = 5
endproc

procedure display_vector_as_options: .vector$, .default
	# Determine the .comment$ and .menu_title$ to display along with
	# the optionMenu.
	if .vector$ == "workstations"
		.comment$ = "Please select your workstation from the menu below."
		.menu_title$ = "Workstation"
	elif .vector$ == "experiment_names"
		.comment$    = "Please select the experiment name from the menu below."
		.menu_title$ = "Experiment name"
	elif .vector$ == "testwaves"
		.comment$ = "Please select the testwave from the menu below."
		.menu_title$ = "Testwave"
	elif .vector$ == "praat_activities"
		.comment$ = "What would you like to do?"
		.menu_title$ = "Activity"
	endif
	# Call the procedure named by .vector$
	@'.vector$'
	# Display that vector as an optionMenu.
	comment (.comment$)
	optionMenu (.menu_title$, .default)
	for i from 1 to '.vector$'.length
		option ('.vector$'.slot$ [i])
	endfor
endproc

procedure session_parameters

	beginPause ("Hi, How Are You?")
		# Prompt the user to enter her initials.
		# --> Global variable [your_initials$].
		comment ("Please enter your initials in the field below.")
		word ("Your initials", defaultInitials$)
		# Prompt the user to select her workstation.
		# --> Global variable [workstation$].
		@display_vector_as_options: "workstations", 1
		# Prompt the user to select the experiment name.
		# --> Global variable [experiment_name$]. 
		@display_vector_as_options: "experiment_names", defaultExpName
		# Prompt the user to select her activity.
		# --> Global variable [activity$].
		@display_vector_as_options: "praat_activities", defaultActivity
	endPause ("Quit", "Continue", 2)

	# Bind all the global variables created by the form to
	# local variables of [session_parameters].
	.initials$ = your_initials$
	.workstation$ = workstation$
	.experiment_name$ = experiment_name$
	.activity$ = activity$

	# Local variable for the path to <Tier2>/DataAnalysis on the filesystem 
	# of the [.workstation$].
	if .workstation$ == workstations.slot$ [1]
		# Default setup. 14 = the string length for "\PraatScripts\"
		.dirLength = rindex_regex (defaultDirectory$, "/|\\") - 14
		.analysis_directory$ = left$(defaultDirectory$, .dirLength)
	elif .workstation$ == workstations.slot$ [2]
		# Mary's set-up, where audio is accessed locally...
		.analysis_directory$ = "/Volumes/tier2/DataAnalysis"
	elif .workstation$ == workstations.slot$ [3]
		# Pat's setup where the audio is accessed locally, but the other data
		# are accessed through a VPN connection...
		.analysis_directory$ = "/Volumes/tier2/DataAnalysis"
	elif .workstation$ == workstations.slot$ [4]
		# Some previously un-encountered setup...
		.analysis_directory$ = ""
	endif

	# Local variable for the experimental task that produced the larger audio files
	# from which the stimuli are being extracted.   For the moment, this is a constant,
	# since we are currently only extracting stimuli from the RealWordRep recordings.
	.experimental_task$ = "RealWordRep"

	# Local variable for the test wave variable, extracted from the experiment name.
	if .experiment_name$ <> ""
		.testwave$ = "TimePoint" + mid$(.experiment_name$, 3, 1)
	else
		.testwave$ = ""
	endif

	# Local variable for the path to the directory of the experimental condition,
	# i.e. the pair of experimental task and testwave.
	if (.analysis_directory$ <> "") and (.testwave$ <> "")
		.experiment_directory$ = .analysis_directory$ + "/" + 
			... .experimental_task$ + "/" + 
			... .testwave$
	else
		.experiment_directory$ = ""
	endif

	# Local variable for the path to the perception experiment directory for the 
	# experiment -- i.e. the subdirectory under .../DataCollection/RWR_PerceptionExperiments
	# where the relevant Stimuli directory and StimPrep directory are.
	if (.analysis_directory$ <> "") and (.experiment_name$ <> "")
		.perception_experiment_directory$ = .analysis_directory$ - "Analysis" + 
			... "Collection/RWR_PerceptionExperiments/" + .experiment_name$
	else
		.perception_experiment_directory$ = ""
	endif

endproc