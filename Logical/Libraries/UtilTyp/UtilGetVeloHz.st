(********************************************************************
 * COPYRIGHT -- Bernecker + Rainer
 ********************************************************************
 * Library: UtilTyp
 * File: UtilGetVeloHz.st
 * Author: schoenefeldr
 * Created: August 02, 2012
 ********************************************************************
 * Implementation of library UtilTyp
 ********************************************************************) 

(* Calculate velocity in user units [0.001 Hz] from input velocity in user units [µm/s] *)
FUNCTION UtilGetVeloHz
	// Formula:
	// 					n [0.001 Hz] = ( v / (pi * diam [mm]) ) * 1.000
	// normalized		n [0.001 Hz] = ( ( v / 1.000.000 ) / (pi * ( diam [mm] / 1.000 ) ) ) * 1.000
	// reduced:			n [0.001 Hz] = ( ( v / 1.000 ) / (pi * ( diam [m] / 1.000 ) ) ) * 1
	// finally reduced:	n [0.001 Hz] = ( ( v / 1 ) / (pi * ( diam [m] / 1 ) ) ) * 1
	// 								 = v / (pi * diam [m])
	// If diameter = 0.0 (invalid diameter) then return 0.0
	IF ( diam_mm = 0.0 ) THEN
		UtilGetVeloHz		:= 0.0;
	ELSE
		UtilGetVeloHz		:= veloM / ( MATH_PI * diam_mm );
	END_IF

END_FUNCTION