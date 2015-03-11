include ../L2T-StartUpForm/L2T-StartupForm.praat
include ../L2T-Audio/L2T-Audio.praat
include ../L2T-utilities/L2T-Utilities.praat
include modules/StimulusTextGrid.praat
include modules/wav_segmentation.praat
#include modules/AddStimulusBoundaryMarkers.praat
include modules/CheckStimulusBoundaryMarkers(in progress).praat

# Set the session parameters.
loadStartUpForm = 0
experimental_task$ = "RealWordRep"
testwave$ = "Timepoint2"
activity$ = "Prep RWR_Perception stimuli"
defaultRWRPerceptionExperiment = 3
defaultRWRPerceptionActivity = 1

@session_parameters

stimPrepDirectory$ = session_parameters.rwr_perception_experiment_directory$ + "/StimPrep"
textGridDirectory$ = stimPrepDirectory$ + "/StimulusTextGrids"
finalStimDirectory$ = session_parameters.rwr_perception_experiment_directory$ + "/Stimuli"
checker_initials$ = session_parameters.initials$

if session_parameters.rwr_perception_activity$ == "Define word/CV boundaries for candidate stimuli"
	# Define the TextGrid tier names and indices.
	@stimulus_textgrid_tiers

	# Read Table from tab-separated file: defaultDirectory$ + "/candidateStimuli.txt"
	Read Table from tab-separated file: stimPrepDirectory$ + "/candidateStimuli.txt"
	Rename: "MainDataFrame"

	# Count the number of rows.  
	numRows = Get number of rows
	numRows = numRows + 1

	if session_parameters.rwr_perception_experiment$ == "TP2_SibilantGoodness_VAS_StimPrep"
		@addBoundaries
	else
		@checkBoundaries
	endif
elif session_parameters.rwr_perception_activity$ == "Check a boundary-tagged stimulus TextGrid"
	runScript: "modules/??"
elif session_parameters.rwr_perception_activity$ == "Extract audio files for candidate stimuli"
	@segmentSoundFile
elif session_parameters.rwr_perception_activity$ == "Listen to all extracted stimulus files"
	runScript: "modules/??"
endif