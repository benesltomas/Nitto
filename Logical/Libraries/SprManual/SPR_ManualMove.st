(********************************************************************
 * COPYRIGHT -- Bernecker + Rainer
 ********************************************************************
 * Library: SprManual
 * File: SPR_ManualMove.st
 * Author: knausenbergl
 * Created: January 01, 2013
 ********************************************************************
 * Implementation of library SprManual
 ********************************************************************) 

(*<$Description$> Start a manual movement </$Description$>*)
FUNCTION_BLOCK SPR_ManualMove
	
	R_TRIG_In.CLK	:= In;
	R_TRIG_In();
	
	Lock	:= NOT( (AxisInStandstill OR Out) AND ManualMoveRelease);
	
	RS_Out.RESET1	:= NOT In OR NOT ManualMoveRelease;
	RS_Out.SET		:= R_TRIG_In.Q AND AxisInStandstill;
	RS_Out();
	Out	:= RS_Out.Q1;
	
END_FUNCTION_BLOCK