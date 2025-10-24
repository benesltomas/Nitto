(********************************************************************
 * COPYRIGHT -- Bernecker + Rainer
 ********************************************************************
 * Library: SprSetup
 * File: SPR_Setup.st
 * Author: knausenbergl
 * Created: January 15, 2013
 ********************************************************************
 * Implementation of library SprSetup
 ********************************************************************) 

(*<$Description$> Start a setup operation </$Description$>*)
FUNCTION_BLOCK SPR_Setup
	
	R_TRIG_In.CLK	:= In;
	R_TRIG_In();
	
	Lock	:= NOT( (AxisDisabled OR Out) AND SetupRelease);
	
	RS_Out.RESET1	:= NOT In OR NOT SetupRelease;
	RS_Out.SET		:= R_TRIG_In.Q AND AxisDisabled;
	RS_Out();
	Out	:= RS_Out.Q1;
	
END_FUNCTION_BLOCK