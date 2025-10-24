(********************************************************************
 * COPYRIGHT -- Bernecker + Rainer
 ********************************************************************
 * Library: UtilTyp
 * File: UtilTyp.fun
 * Author: schoenefeldr
 * Created: July 09, 2012
 ********************************************************************
 * Functions and function blocks of library UtilTyp
 ********************************************************************)

FUNCTION UtilScaleAin32 : UINT (*Scale analogue input 32 Bit*)
	VAR_INPUT
		dataAdr : REFERENCE TO AiAo_Type;
	END_VAR
END_FUNCTION

FUNCTION UtilScaleAin16 : UINT (*Scale analogue input 16 Bit*)
	VAR_INPUT
		dataAdr : REFERENCE TO AiAo_Type;
	END_VAR
END_FUNCTION

FUNCTION UtilScaleAout16 : UINT (*Scale a real vaue into a 16 Bit analogue output*)
	VAR_INPUT
		dataAdr : REFERENCE TO AiAo_Type;
	END_VAR
	VAR
		outValue : REAL; (*Internal limited value*)
	END_VAR
END_FUNCTION

FUNCTION_BLOCK UtilFreqPulse (*FB generates a pulse at a defined frequency*)
	VAR_INPUT
		Frequency : UDINT; (*Pulse frequency [0.1 Hz]*)
		dataAdr : REFERENCE TO DiDo_Type;
	END_VAR
	VAR
		RTInfo_0 : RTInfo;
		periodCntMax : UDINT; (*Maximum counter value for one pulse period in cycletime*)
		periodCntAct : UDINT; (*Counter for pulse period in cycletime*)
		cycletimeValue : UDINT; (*Cycletime in ms*)
		cycletimeValid : BOOL; (*internal cycletime has been determined*)
	END_VAR
END_FUNCTION_BLOCK

FUNCTION UtilGetDiameter : REAL (*Calculates a diameter from a scaled sensor value [mm] and an calibrated offset [mm]*)
	VAR_INPUT
		adr_Ain : REFERENCE TO AiAo_Type; (*address of analogue input structure*)
		offset : REAL; (*calibrated diameter offset in [mm]*)
		coreDiam : REAL; (*additional offset through core diameter in [mm]*)
	END_VAR
END_FUNCTION

FUNCTION UtilCalcSetVeloHz : REAL (*Calculate velocity setpoint in user units [0.001 Hz] from input velocity in user units [µm/s]*)
	VAR_INPUT
		FIXED_DIAM : REAL; (*Used diameter if diameter input is zero*)
		veloM : REAL; (*Velocitiy in user unit [µm/s] (direct input)*)
		diam_mm : REAL; (*diameter of winder in [mm] (assume miminum diameter if zero)*)
	END_VAR
END_FUNCTION

FUNCTION UtilGetVeloHz : REAL (*Calculate velocity in user units [0.001 Hz] from input velocity in user units [µm/s]*)
	VAR_INPUT
		veloM : REAL; (*Velocitiy in user unit [µm/s] (direct input)*)
		diam_mm : REAL; (*diameter of winder in [mm]*)
	END_VAR
END_FUNCTION

FUNCTION UtilScal : REAL (*Scaling an input via a line equation*)
	VAR_INPUT
		In : REAL; (*Input value*)
		Gain : REAL; (*line equation gain*)
		Offset : REAL; (*line equation offset*)
	END_VAR
END_FUNCTION
