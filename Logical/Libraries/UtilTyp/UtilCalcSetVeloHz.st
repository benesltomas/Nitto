(********************************************************************
 * COPYRIGHT -- Bernecker + Rainer
 ********************************************************************
 * Library: UtilTyp
 * File: UtilCalcSetVeloHz.st
 * Author: schoenefeldr
 * Created: August 02, 2012
 ********************************************************************
 * Implementation of library UtilTyp
 ********************************************************************) 

(* Calculate velocity setpoint in user units [0.001 Hz] from input velocity in user units [µm/s] *)
FUNCTION UtilCalcSetVeloHz
	// Formula:
	// 					n [0.001 Hz] = ( v [m/s] / (pi * diam [m]) ) * 1.000
	// normalized		n [0.001 Hz] = ( ( v [µm/s] / 1.000.000 ) / (pi * ( diam [mm] / 1.000 ) ) ) * 1.000
	// reduced:			n [0.001 Hz] = ( ( v [µm/s] / 1.000 ) / (pi * ( diam [mm] / 1.000 ) ) ) * 1
	// finally reduced:	n [0.001 Hz] = ( ( v [µm/s] / 1 ) / (pi * ( diam [mm] / 1 ) ) ) * 1
	// 								 = v [µm/s] / (pi * diam [mm])
	IF ( diam_mm = 0.0 ) THEN
		IF ( FIXED_DIAM = 0.0 ) THEN
			// Invalid input for FIXED_DIAM, return velocity setpoint = 0.0
			diam_mm		:= 1.0;
			veloM		:= 0.0;
		ELSE
			// Invalid input for diam_mm, calculate with FIXED_DIAM
			diam_mm		:= FIXED_DIAM;
		END_IF
	END_IF
	UtilCalcSetVeloHz		:= veloM / ( MATH_PI * diam_mm );

END_FUNCTION