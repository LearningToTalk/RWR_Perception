include modules/StimulusTextGrid.praat
Read Table from tab-separated file: "I:/DataCollection/RWR_PerceptionExperiments/TP2_SibilantGoodness_VAS/StimPrep/candidateStimuli.txt"
Rename: "MainDataFrame"

numRows = Get number of rows

textGridDirectory$ = "I:/DataCollection/RWR_PerceptionExperiments/TP2_SibilantGoodness_VAS/StimPrep/StimulusTextGrids/"
@getListofTextGrids

#for index from 1 to numRows
	select Table MainDataFrame
#	currentParticipant$ = Get value: index, "ID"
	currentParticipant$ = "606L44M3"
	Extract rows where column (text): "ID", "is equal to", currentParticipant$
	Rename: currentParticipant$
	subsetNumRows = Get number of rows

	Read from file: textGridDirectory$ + currentParticipant$ + "_TP2_SibilantGoodness_VAS.TextGrid"
	textGrid$ = selected$()
	Insert interval tier: 3, "stimStatus"

	for intervalNumber from 1 to subsetNumRows
		select Table 'currentParticipant$'
		startTime = Get value: intervalNumber, "XMin"
		endTime = Get value: intervalNumber, "XMax"
		stimStatus$ = Get value: intervalNumber, "status"

		selectObject: textGrid$
		Insert boundary: 3, startTime
		Insert boundary: 3, endTime
		Set interval text: 3, intervalNumber * 2, stimStatus$

		if stimStatus$ == "REJECT"
			select Table 'currentParticipant$'
			trial_number$ = Get value: intervalNumber, "TrialNumber"
			word$ = Get value: intervalNumber, "Word"
			transcription$ = Get value: intervalNumber, "transcription"
			targetC$ = Get value: intervalNumber, "TargetC"
			current_transcription$ = replace_regex$(transcription$, "[$:]", "", 3)

			current_stimulus_filename$ = currentParticipant$ + trial_number$ + 
			... word$ + "_" + current_transcription$ + "4" + targetC$

			selectObject: textGrid$
			Insert boundary: 2, startTime
			Insert boundary: 2, endTime
			Set interval text: 2, intervalNumber * 2, current_stimulus_filename$
		endif
		index = index + 1
	endfor
	selectObject: textGrid$
	Save as text file: textGridDirectory$ + currentParticipant$ + "_TP2_SibilantGoodness_VAS.TextGrid"
	Remove
#endfor

procedure getListofTextGrids
	Create Strings as file list: "textGridList", textGridDirectory$ + "*.TextGrid"
	numTextGrids = Get number of strings
endproc