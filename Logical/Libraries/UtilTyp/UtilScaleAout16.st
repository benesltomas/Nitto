(********************************************************************
 * COPYRIGHT -- Bernecker + Rainer
 ********************************************************************
 * Library: UtilTyp
 * File: UtilScaleAout16.st
 * Author: schoenefeldr
 * Created: July 17, 2012
 ********************************************************************
 * Implementation of library UtilTyp
 ********************************************************************) 

(* Scale a real vaue into a 16 Bit analogue output *)
FUNCTION UtilScaleAout16
	// Input is the data value that first has to be limited to the scaled range 
	// (application units) and then into the limitations of the raw range
	// depending on the analogue outputs. 
	outValue := dataAdr.Value.Scaled + dataAdr.Config.ScaleOffset;

	// Now scale the output value in application units into raw range
	IF NOT (dataAdr.Config.ScaleGain = 0.0) THEN
		outValue := outValue / dataAdr.Config.ScaleGain;
		UtilScaleAout16 := ERR_OK;
	ELSE
		// Invalid Scale Gain (division by zero), add offset only, no further scaling
		outValue 		:= 0.0;
		UtilScaleAout16 := ERR_DIVISION_BY_ZERO;
	END_IF

	// Limit the result to the physical limits of the analogue output
	IF outValue > dataAdr.Config.RawMax THEN
		outValue := dataAdr.Config.RawMax;
		// Second limitation to physical limit of output / conversion
		IF outValue > 32767.0 THEN
			outValue 		:= 32767.0;
			UtilScaleAout16 := ERR_INT_OVERFLOW;
		END_IF
	ELSIF outValue < dataAdr.Config.RawMin THEN
		outValue := dataAdr.Config.RawMin;
		// Second limitation to physical limit of output / conversion
		IF outValue < -32768.0 THEN
			outValue 		:= -32768.0;
			UtilScaleAout16 := ERR_INT_UNDERFLOW;
		END_IF
	END_IF
	// convert value into output
	dataAdr.Value.RawInt := REAL_TO_INT (outValue);
END_FUNCTION