(********************************************************************
 * COPYRIGHT -- Bernecker + Rainer
 ********************************************************************
 * Library: UserSpilke
 * File: SPR_Spender.st
 * Author: knausenbergl
 * Created: November 20, 2012
 ********************************************************************
 * Implementation of library UserSpilke
 ********************************************************************) 

(*<$Description$> Control of prop. valve for winder clutch </$Description$>*)
FUNCTION_BLOCK SPR_WinderClutch
	LCRLimScal_Pressure.x1	:= RefDiameter[0];
	LCRLimScal_Pressure.x2	:= RefDiameter[1];
	LCRLimScal_Pressure.y1	:= LIMIT(0.0, RefPressure[0], 100.0);
	LCRLimScal_Pressure.y2	:= LIMIT(0.0, RefPressure[1], 100.0);
	LCRLimScal_Pressure.x	:= ActDiameter;
	LCRLimScal_Pressure();
	SetPressure	:= LCRLimScal_Pressure.y;
END_FUNCTION_BLOCK