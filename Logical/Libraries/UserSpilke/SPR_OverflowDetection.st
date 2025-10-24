(********************************************************************
 * COPYRIGHT -- Bernecker + Rainer
 ********************************************************************
 * Library: UserSpilke
 * File: OverflowDetection.st
 * Author: knausenbergl
 * Created: February 07, 2013
 ********************************************************************
 * Implementation of library UserSpilke
 ********************************************************************) 

(*<$Description$> Detects overflow e,g, of a periodic position </$Description$>*)
FUNCTION_BLOCK SPR_OverflowDetection
	R_TRIG_Enable.CLK	:= Enable;
	R_TRIG_Enable();
	
	IF (Enable) THEN
		IF (R_TRIG_Enable.Q) THEN
			PeriodicPosition_1	:= PeriodicPosition;	//initialize previous position
		END_IF;
		
		//detect overflow
		IF (ABS(PeriodicPosition - PeriodicPosition_1) > (ModuloPeriod / 2) ) THEN
			IF (PeriodicPosition < PeriodicPosition_1) THEN
				PositiveOverflow	:= TRUE;
				PeriodOffset		:= PeriodOffset + ModuloPeriod;	//increase period offset
			ELSE
				NegativeOverflow	:= TRUE;
				PeriodOffset		:= PeriodOffset - ModuloPeriod;	//decrease period offset
			END_IF;
		ELSE
			PositiveOverflow	:= FALSE;
			NegativeOverflow	:= FALSE;
		END_IF;
		
		//absolute position is the sum of offset (from previous periods) and actual periodic position
		AbsolutePosition	:= PeriodOffset + PeriodicPosition; 
		
		//save previous position
		PeriodicPosition_1	:= PeriodicPosition;
		
	ELSE
		PeriodicPosition_1	:= 0;
		PeriodOffset		:= 0;
		AbsolutePosition	:= 0;
		PositiveOverflow	:= FALSE;
		NegativeOverflow	:= FALSE;
	END_IF;
	
END_FUNCTION_BLOCK