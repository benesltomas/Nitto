(********************************************************************
 * COPYRIGHT -- Bernecker + Rainer
 ********************************************************************
 * Library: UtilTyp
 * File: UtilFreqPulse.st
 * Author: schoenefeldr
 * Created: July 17, 2012
 ********************************************************************
 * Implementation of library UtilTyp
 *
 * History:
 * 2012-07-17 /schoenefeldr/
 *		Task created
 * 2012-10-15 /schoenefeldr/
 *		Increased internal resolution to 0.1 ms
 ********************************************************************) 

(* FB generates a pulse at a defined frequency *)
FUNCTION_BLOCK UtilFreqPulse
		
	// Exit if frequency is 0 or no pulse requested
	IF (Frequency = 0) OR NOT dataAdr.Value.IsBlinking THEN
		dataAdr.Value.ActOut 	:= dataAdr.Value.State;
		periodCntAct			:= 0;
		RETURN;
	END_IF
		
	// Calculate the cycletime if necessary
	IF (NOT cycletimeValid AND dataAdr.Value.IsBlinking) THEN
 		// Call FB to determine the task cycletime
		RTInfo_0(enable := TRUE);
		
		// The FB returns the cycletime in µs -> convert to ms
		IF(RTInfo_0.status = 0)THEN
			// 2012-10-15 /schoenefeldr/: Increase resolution to 0.1 ms
			cycletimeValue := RTInfo_0.cycle_time / 100;
			cycletimeValid := TRUE;
		END_IF
	END_IF
	
	// Calculate state and derive output only if...
	// -> the data state is TRUE (output may be set)
	// -> blinking is requested
	IF (cycletimeValid AND dataAdr.Value.IsBlinking AND dataAdr.Value.State) THEN
		
		// Calculate period counter
		// 2012-10-15 /schoenefeldr/: Increase resolution to 0.1 ms
		periodCntMax := 100000 / Frequency;	
		
		// The period always starts with a set output
		IF (periodCntAct > periodCntMax) THEN
			// Reset output and counter
			dataAdr.Value.ActOut 	:= FALSE;
			periodCntAct			:= 0;
		ELSIF (periodCntAct > (periodCntMax / 2)) THEN
			dataAdr.Value.ActOut 	:= FALSE;
			periodCntAct := periodCntAct + cycletimeValue;
		ELSE
			dataAdr.Value.ActOut := TRUE;
			periodCntAct := periodCntAct + cycletimeValue;
		END_IF
		
	ELSE
		// Reset cycle time valid flag => a valid cycletime will always be calculated
		cycletimeValid := FALSE;
		
	END_IF

END_FUNCTION_BLOCK