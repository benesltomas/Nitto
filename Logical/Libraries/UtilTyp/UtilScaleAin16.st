(********************************************************************
 * COPYRIGHT -- Bernecker + Rainer
 ********************************************************************
 * Library: UtilTyp
 * File: UtilScaleAin16.st
 * Author: schoenefeldr
 * Created: July 16, 2012
 ********************************************************************
 * Implementation of library UtilTyp
 ********************************************************************) 

(* Scale analogue input 16 Bit *)
FUNCTION UtilScaleAin16
	// Result is the sum of the scaled raw value (signed 16 bit) and the offset (in application units)
	dataAdr.Value.Scaled := dataAdr.Config.ScaleOffset +
							(dataAdr.Config.ScaleGain * INT_TO_REAL( dataAdr.Value.RawInt ));
	UtilScaleAin16 := ERR_OK;   // Return value = OK
END_FUNCTION