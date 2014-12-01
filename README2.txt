The praat scripts in this directory are intended for use in checking a set of
candidate stimuli to be extracted from some subset of the RealWordRep recordings
under ../DataAnalysis/RealWordRep/TimePoint{1|2|3}/Recordings for the purpose 
of doing some named experiment.  Named experiments to date are:

TP2_SibilantGoodness_VAS
TP2_S-SH_VAS
TP2_ObstruentsGender_VAS
TP2_k-t_VAS

The scripts are set up in a way that assumes there is a companion directory 
for the named experiment under the .../DataCollection/RWR_PerceptionExperiments 
directory, containing a subdirectory called StimPrep that contains at least
the following elements:

StimulusTextGrids
   a folder where the TextGrid files created in checking will be placed

candidateStimuli.txt
   a file created by an R script such as buildStimulusCandidatesTable.R
   that has at least the following columns:

ID          -- the 9-char PID for the larger audio file (e.g., 006L40FS3)
Word        -- the orthographic form for the target word (e.g., suitcase)
TargetC     -- the worldBet for the target word-initial consonant (e.g., s)
TrialNumber -- the trial number (e.g., Test4) from the segm.TextGrid
Context     -- the Context label (e.g., Response) from the segm.TextGrid
Repetition  -- the repetition number from the segm.TextGrid
SegmNotes   -- the segmenter's notes from the segm.TextGrid
XMin        -- the beginning time that was tagged for the segmented interval
XMax        -- the ending time that was tagged the segmented interval
consType    -- the consType label (e.g., Sibilant fricative) from the 
               turb.TextGrid or burst.TextGrid file
TaggerNotes -- the TurbNotes or BurstNotes label
stimOnset   -- the stimulus onset time that was extracted from the 
               turb.TextGrid or burst.TextGrid file or that will be added
               by the script user
stimOffset  -- the stimulus offset time that was extracted from the 
               turb.TextGrid or burst.TextGrid file or that will be added
               by the script user
checker     -- a column that will hold the checker's initials
