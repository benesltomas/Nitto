(********************************************************************
 * COPYRIGHT -- Bernecker + Rainer
 ********************************************************************
 * Library: SprManual
 * File: SPR_ManualRelease.st
 * Author: knausenbergl
 * Created: January 01, 2013
 ********************************************************************
 * Implementation of library SprManual
 ********************************************************************) 

(*<$Description$> Release manual movements </$Description$>*)
FUNCTION_BLOCK SPR_ManualMoveRelease
	
	Out	:= ManualModeActive AND AxisPower AND NOT AxisError AND NOT Reset;
	
END_FUNCTION_BLOCK