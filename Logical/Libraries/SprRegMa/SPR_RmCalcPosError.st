(********************************************************************
 * COPYRIGHT -- Bernecker + Rainer
 ********************************************************************
 * Library: UserRegMa
 * File: CalcPosError.st
 * Author: knausenbergl
 * Created: October 19, 2012
 ********************************************************************
 * Implementation of library UserRegMa
 ********************************************************************) 
(*<$Description$> Calculates a position error for registration mark control </$Description$>*)
FUNCTION_BLOCK SPR_RmCalcPosError		
	//save registration mark position in FIFO
	SPR_Fifo_0.InValue	:= RecordedValue;
	SPR_Fifo_0.Reset	:= NOT Enable;
	SPR_Fifo_0.Add		:= RecordedValueValid AND Enable;
	SPR_Fifo_0();
		
	//********************************	FIFO state-machine	**************************
	//Any state
	IF (NOT Enable) THEN
		State	:= SPRRM_FIFO_DISABLED;
	END_IF;
		
	CASE State OF
		//FIFO is disabled, waiting for Enable
		SPRRM_FIFO_DISABLED:
			PositionErrorValid	:= FALSE;
			PositionError		:= 0;
				
			IF (Enable) THEN
				State	:= SPRRM_FIFO_EMPTY;	
			END_IF;
		
		//FIFO is enabled and empty
		SPRRM_FIFO_EMPTY:
			IF (SPR_Fifo_0.ActElements > 0) THEN
				State		:= SPRRM_FIFO_EVALUATION_BUSY;	
			END_IF;
					
		//FIFO output value is under evaluation
		SPRRM_FIFO_EVALUATION_BUSY:
			CorrectedCutPosition	:= SPR_Fifo_0.OutValue + DistanceToSensor - RegMarkPosition;
			PositionErrorTemp		:= CorrectedCutPosition - CutMasterPosition;
			PositionError			:= PositionErrorTemp MOD ProductLength;
				
			IF (PositionErrorTemp > (- ProductLength / 2) ) THEN
				//wait until registration mark is within current product cycle
				IF (ABS(PositionErrorTemp) < (ProductLength / 2) ) THEN
					PositionErrorValid	:= TRUE;
					SPR_Fifo_0.Remove	:= TRUE;
					State				:= SPRRM_FIFO_EVALUATION_DONE;
				ELSIF (ABS(PositionErrorTemp) > (2 * DistanceToSensor) ) THEN
					//if position error is too large, it is assumed to be invalid
					SPR_Fifo_0.Remove	:= TRUE;
					State			:= SPRRM_FIFO_EVALUATION_DONE;
				END_IF;
			ELSE
				SPR_Fifo_0.Remove	:= TRUE;
				State				:= SPRRM_FIFO_EVALUATION_DONE;	
			END_IF;
			
		//FIFO value has been evaluated, read next value 
		SPRRM_FIFO_EVALUATION_DONE:
			SPR_Fifo_0.Remove			:= FALSE;
			PositionErrorValid		:= FALSE;
				
			IF (SPR_Fifo_0.ActElements > 0) THEN
				State		:= SPRRM_FIFO_EVALUATION_BUSY;
			ELSE
				State		:= SPRRM_FIFO_EMPTY;
			END_IF;
					
	END_CASE;
	
END_FUNCTION_BLOCK