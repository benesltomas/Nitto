(********************************************************************
 * COPYRIGHT -- Bernecker + Rainer
 ********************************************************************
 * Library: UserSpilke
 * File: SPR_HydLever.st
 * Author: knausenbergl
 * Created: November 15, 2012
 ********************************************************************
 * Implementation of library UserSpilke
 ********************************************************************) 

(*<$Description$> Hydraulic lever (e.g. of the unwinder) </$Description$>*)
FUNCTION_BLOCK SPR_HydLever
	ValveOn	:= Down AND NOT Up;
	MotorOn	:= NOT LimitSwitchTop AND Up AND NOT Down;
END_FUNCTION_BLOCK