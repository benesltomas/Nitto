FUNCTION_BLOCK Sort
(* Implementation of sort *)

(**********************************************************************************************************************)
(* Object name: sort                                                                                                                              	*)
(* Author:      Peter Hauser,  B&R                                                                                                               	*)
(* Site:        Eggelsberg                                                                                                                             	*)
(* Created:     25-aug-2003                                                                                                                           	*)
(* Restriction: ------                                                                                                                          	*)
(* Description: The Sort-Function sorts a String Array alphanumerically                                                                                                                                       	*)
(*                                                                                                                                                              	*)
(*----------------------------------------------------------------------------------------------------------------------------------------	*)
(* Version 1.00.1   25-aug-2003  Peter Hauser									*)
(*----------------------------------------------------------------------------------------------------------------------------------------	*)
(* Development tool: B&R Automation Studio V2.3.0.9 							*)
(*----------------------------------------------------------------------------------------------------------------------------------------	*)
(* Comment:                                                                                                                     			*)
(**********************************************************************************************************************)


(* Errors *)

IF ((enable = 0) AND (StepCounter > 0) AND (StepCounter < ((ArrayLen / StringLen) - 1))) THEN
	Status:= SORTING_ABORTED;

ELSIF ((enable = 1) AND (StepCounter >= 0) AND (StepCounter < ((ArrayLen / StringLen) - 1))) THEN
	Status:= SORTING_BUSY;

ELSE
	Status:= SORTING_NO_ERROR;

END_IF


(* sorting StringArray alphanumerically *)

IF ((enable = 1) AND ((Status = 0) OR (Status = 65535))) THEN

	FOR xcnt:= 0 TO ((ArrayLen / StringLen) - 2) DO

		FOR ycnt:= 0 TO StringLen DO
			(* read characters of FileNames *)
			pChar1 ACCESS (pStringArray + (StringLen * xcnt) + ycnt);
			pChar2 ACCESS (pStringArray + (StringLen * xcnt) + StringLen + ycnt);

			(* if no data in FileName1 -> Swap FileNames *)
			IF ((ycnt = 0) AND (pChar1 = 0) AND (pChar2 > 0)) THEN
				SortStep:= SWAP_FILENAMES;

			(* if no data in FileName2 -> next 2 FileNames *)
			ELSIF ((ycnt = 0) AND (pChar2 = 0)) THEN
				EXIT;

			(* if data in both FileNames *)
			ELSE
				(* detect case of letters *)
				IF ((pChar1 >= 65) AND (pChar1 <= 90) AND (pChar2 >= 97) AND (pChar2 <= 122)) THEN
					SortStep:= SORT_CASE_SENSITIVE1;

				ELSIF ((pChar1 >= 97) AND (pChar1 <= 122) AND (pChar2 >= 65) AND (pChar2 <= 90)) THEN
					SortStep:= SORT_CASE_SENSITIVE2;

				(* if characters are equal -> compare next characters of FileName *)
				ELSIF ((pChar1 = pChar2) AND (pChar2 <> 0)) THEN
					SortStep:= 0;

				(* if both FileNames are finished *)
				ELSIF ((pChar1 = 0) AND (pChar2 = 0)) THEN
					EXIT;

				(* sort Alphanumerically *)
				ELSE
					SortStep:= SORT_ALPHANUMERICALLY;
				END_IF
			END_IF

			CASE SortStep OF

				SWAP_FILENAMES:
					memcpy(ADR(FileNameBuffer), (pStringArray + (StringLen * xcnt)), StringLen);
					memcpy((pStringArray + (StringLen * xcnt)), (pStringArray + (StringLen * xcnt) + StringLen), StringLen);
					memcpy((pStringArray + (StringLen * xcnt) + StringLen), ADR(FileNameBuffer), StringLen);
					EXIT;

				SORT_CASE_SENSITIVE1:
					IF (pChar2 <= (pChar1 + 32)) THEN
						memcpy(ADR(FileNameBuffer), (pStringArray + (StringLen * xcnt)), StringLen);
						memcpy((pStringArray + (StringLen * xcnt)), (pStringArray + (StringLen * xcnt) + StringLen), StringLen);
						memcpy((pStringArray + (StringLen * xcnt) + StringLen), ADR(FileNameBuffer), StringLen);
						EXIT;
					ELSE
						EXIT;
					END_IF

				SORT_CASE_SENSITIVE2:
					IF (pChar2 < (pChar1 - 32)) THEN
						memcpy(ADR(FileNameBuffer), (pStringArray + (StringLen * xcnt)), StringLen);
						memcpy((pStringArray + (StringLen * xcnt)), (pStringArray + (StringLen * xcnt) + StringLen), StringLen);
						memcpy((pStringArray + (StringLen * xcnt) + StringLen), ADR(FileNameBuffer), StringLen);
						EXIT;
					ELSE
						EXIT;
					END_IF

				SORT_ALPHANUMERICALLY:
					IF pChar1 > pChar2 THEN
						memcpy(ADR(FileNameBuffer), (pStringArray + (StringLen * xcnt)), StringLen);
						memcpy((pStringArray + (StringLen * xcnt)), (pStringArray + (StringLen * xcnt) + StringLen), StringLen);
						memcpy((pStringArray + (StringLen * xcnt) + StringLen), ADR(FileNameBuffer), StringLen);
						EXIT;
					ELSE
						EXIT;
					END_IF

			END_CASE
		END_FOR

	END_FOR

	(* execute sorting [NumStringsToSort] times *)
	IF xcnt = ((ArrayLen / StringLen) - 1) THEN
		StepCounter:= StepCounter + 1;
	END_IF;

	IF StepCounter >= (ArrayLen / StringLen) THEN
		StepCounter:= 0;
	END_IF

END_IF			(* if enable = 1 *)


END_FUNCTION_BLOCK
