(********************************************************************
 * COPYRIGHT -- Bernecker + Rainer
 ********************************************************************
 * Library: SprMachine
 * File: SPR_BatchProduction.st
 * Author: knausenbergl
 * Created: January 08, 2013
 ********************************************************************
 * Implementation of library SprMachine
 ********************************************************************) 

(*<$Description$> Triggers a reduction of the master velocity and stop of master when the end of a batch is reached </$Description$>*)
FUNCTION_BLOCK SPR_BatchProduction
	
	DeltaCount			:= UDINT_TO_DINT(SetProductCount - ActProductCount);
	RemainingDistance	:= DINT_TO_REAL(DeltaCount) * ProductLength;
	
	//calculate stopping distance
	IF (Deceleration > 0.0) THEN
		StoppingDistance	:= 0.5 * ActVelocity**2 / Deceleration;
	ELSE
		StoppingDistance	:= 0.0;
	END_IF;
	
	//ANY STATE
	IF (NOT Enable) THEN
		ReduceVelocity	:= FALSE;
		BatchComplete	:= FALSE;
		State	:= 0;
	END_IF;
	
	CASE State OF
		//BATCH PRODUCTION DISABLED
		0:
			ReduceVelocity	:= FALSE;
			BatchComplete	:= FALSE;
			
			IF (Enable) THEN
				State	:= 1;
			END_IF;
		
		//BATCH PRODUCTION ACTIVE
		1:
			IF (RemainingDistance <= (StoppingDistance + DistanceAtReducedVel) ) THEN
				ReduceVelocity	:= TRUE;
				State			:= 2;
			END_IF;
		
		//BATCH COMPLETION AT REDUCED VELOCITY
		2:
			IF (DeltaCount <= 0) THEN
				ReduceVelocity	:= FALSE;
				BatchComplete	:= TRUE;
				State			:= 3;
			END_IF;
		
		//BATCH COMPLETE, WAITING FOR RESET
		3:
		
		//ERROR
		255:
		
		//STATE UNDEFINED
		ELSE
			State	:= 255;
			
	END_CASE;
	
END_FUNCTION_BLOCK