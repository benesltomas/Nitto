(********************************************************************
 * COPYRIGHT -- Bernecker + Rainer
 ********************************************************************
 * Library: UserSpilke
 * File: SPR_ScaleCircumference.st
 * Author: knausenbergl
 * Created: December 07, 2012
 ********************************************************************
 * Implementation of library UserSpilke
 ********************************************************************) 

(*<$Description$> Scales a tool circumference to a whole number that is divisible without remainder by the number of tool segments </$Description$>*)
FUNCTION_BLOCK SPR_ScaleCircumference
	IF (NumberToolSegments > 0) THEN
		Remainder	:= REAL_TO_DINT(floor(ActCircumference) ) MOD USINT_TO_DINT(NumberToolSegments);
		
		IF (Remainder > USINT_TO_DINT(NumberToolSegments / 2) ) THEN
			Remainder	:= Remainder - USINT_TO_DINT(NumberToolSegments);
		END_IF;
		
		ScaledCircumference	:= DINT_TO_UDINT(REAL_TO_DINT(floor(ActCircumference) ) - Remainder);
		ToolSegmentPeriod	:= ScaledCircumference / NumberToolSegments;
	ELSE
		ScaledCircumference	:= 0;
		ToolSegmentPeriod	:= 0;
	END_IF;	
	
END_FUNCTION_BLOCK