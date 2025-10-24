(********************************************************************
 * COPYRIGHT -- Bernecker + Rainer
 ********************************************************************
 * Library: SprSetup
 * File: SprSetup.fun
 * Author: knausenbergl
 * Created: January 15, 2013
 ********************************************************************
 * Functions and function blocks of library SprSetup
 ********************************************************************)

FUNCTION_BLOCK SPR_SetupRelease (*Give release for a setup operation*)
	VAR_INPUT
		AxisPower : BOOL; (*axis is powered on*)
		NetworkInit : BOOL; (*network initialized*)
		AxisError : BOOL; (*FubError OR AxisError*)
		Reset : BOOL; (*reset output*)
	END_VAR
	VAR_OUTPUT
		Out : BOOL; (*give release for setup operations (tuning, endcoder_if, ...)*)
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK SPR_Setup (*Start a setup operation*)
	VAR_INPUT
		In : BOOL;
		SetupRelease : BOOL;
		AxisDisabled : BOOL; (*axis in state disabled*)
	END_VAR
	VAR_OUTPUT
		Out : BOOL; (*triggers FUB*)
		Lock : BOOL; (*conditions to start setup operation not met, output cannot be set*)
	END_VAR
	VAR
		R_TRIG_In : R_TRIG;
		RS_Out : RS;
	END_VAR
END_FUNCTION_BLOCK
