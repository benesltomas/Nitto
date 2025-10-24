(********************************************************************
 * COPYRIGHT -- Bernecker + Rainer
 ********************************************************************
 * Library: SprManual
 * File: SPR_ManualStop.st
 * Author: knausenbergl
 * Created: January 01, 2013
 ********************************************************************
 * Implementation of library SprManual
 ********************************************************************) 

(*<$Description$> Triggers a stop movement </$Description$>*)
FUNCTION_BLOCK SPR_ManualStop
	
	R_TRIG_ManualMoveRelease.CLK	:= ManualMoveRelease;
	R_TRIG_ManualMoveRelease();
	
	F_TRIG_ManualMoveRelease.CLK	:= ManualMoveRelease;
	F_TRIG_ManualMoveRelease();
	
	Out	:= AxisPower AND ManualModeActive AND (In OR R_TRIG_ManualMoveRelease.Q OR F_TRIG_ManualMoveRelease.Q);
	
END_FUNCTION_BLOCK