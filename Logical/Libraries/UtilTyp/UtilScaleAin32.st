(********************************************************************
 * COPYRIGHT -- Bernecker + Rainer
 ********************************************************************
 * Library: UtilTyp
 * File: UtilScaleAin32.st
 * Author: schoenefeldr
 * Created: July 16, 2012
 ********************************************************************
 * Implementation of library UtilTyp
 ********************************************************************) 

(* Scale analogue input 32 Bit *)
FUNCTION UtilScaleAin32
	// Result is the sum of the scaled raw value (signed 32 bit) and the offset (in application units)
	dataAdr.Value.Scaled := dataAdr.Config.ScaleOffset +
							(dataAdr.Config.ScaleGain * DINT_TO_REAL( dataAdr.Value.RawDInt ));
	UtilScaleAin32 := ERR_OK;   // Return value = OK
END_FUNCTION