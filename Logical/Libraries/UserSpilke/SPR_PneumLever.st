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
FUNCTION_BLOCK SPR_PneumLever	   
	ValveDown	:= Down AND NOT Up AND NOT LimitSwitchBottom;
	ValveUp		:= Up AND NOT Down AND NOT LimitSwitchTop;
END_FUNCTION_BLOCK