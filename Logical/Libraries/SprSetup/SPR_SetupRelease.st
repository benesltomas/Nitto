(********************************************************************
 * COPYRIGHT -- Bernecker + Rainer
 ********************************************************************
 * Library: SprSetup
 * File: SPR_SetupRelease.st
 * Author: knausenbergl
 * Created: January 15, 2013
 ********************************************************************
 * Implementation of library SprSetup
 ********************************************************************) 

(*<$Description$> Give release for a setup operation </$Description$>*)
FUNCTION_BLOCK SPR_SetupRelease
	
	Out	:= NOT AxisPower AND NetworkInit AND NOT AxisError AND NOT Reset;
	
END_FUNCTION_BLOCK