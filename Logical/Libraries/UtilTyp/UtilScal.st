(********************************************************************
 * COPYRIGHT -- Bernecker + Rainer
 ********************************************************************
 * Library: UtilTyp
 * File: UtilScal.st
 * Author: schoenefeldr
 * Created: September 19, 2012
 ********************************************************************
 * Implementation of library UtilTyp
 ********************************************************************) 

(* Scaling an input via a line equation *)
FUNCTION UtilScal
	// This function has a comparable functionality as LCRScal from the CoopConR Lib.
	// As long as the Lib is not necessary this function replaces the Function Block
	UtilScal	:= Gain * In + Offset;
END_FUNCTION