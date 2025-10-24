(********************************************************************
 * COPYRIGHT -- Bernecker + Rainer
 ********************************************************************
 * Library: UtilTyp
 * File: UtilGetDiameter.st
 * Author: schoenefeldr
 * Created: August 01, 2012
 *
 *
 * History:
 * 2012-09-20 /schoenefeldr/
 * 		core diameter as additional input
 *
 ********************************************************************
 * Implementation of library UtilTyp
 ********************************************************************) 

(* Calculates a diameter from a scaled sensor value [mm] and an calibrated offset [mm] *)
FUNCTION UtilGetDiameter
	// This function calculates the diameter from a distance value as input [mm]
	// and an offset derived from the distance value for an "empty" winder.
	UtilGetDiameter	:= ((offset + (coreDiam / 2.0)) - adr_Ain.Value.Scaled) * 2;
	IF UtilGetDiameter < 0.0 THEN
		// Invalid diameter, return 0.0
		UtilGetDiameter := 0.0;
	END_IF
END_FUNCTION