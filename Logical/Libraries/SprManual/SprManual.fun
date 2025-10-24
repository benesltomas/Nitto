(********************************************************************
 * COPYRIGHT -- Bernecker + Rainer
 ********************************************************************
 * Library: SprManual
 * File: SprManual.fun
 * Author: knausenbergl
 * Created: January 01, 2013
 ********************************************************************
 * Functions and function blocks of library SprManual
 ********************************************************************)

FUNCTION_BLOCK SPR_ManualMoveRelease (*Release manual movements*)
	VAR_INPUT
		ManualModeActive : BOOL; (*machine is in manual mode*)
		AxisPower : BOOL; (*axis is powered on*)
		AxisError : BOOL; (*FubError OR AxisError*)
		Reset : BOOL; (*reset output*)
	END_VAR
	VAR_OUTPUT
		Out : BOOL; (*give release for manual movements*)
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK SPR_ManualMove (*Start a manual movement*)
	VAR_INPUT
		In : BOOL; (*start command*)
		ManualMoveRelease : BOOL;
		AxisInStandstill : BOOL; (*axis in standstill state*)
	END_VAR
	VAR_OUTPUT
		Out : BOOL; (*starts movement (connected to FUB)*)
		Lock : BOOL; (*conditions to start a movement not met, output cannot be set*)
	END_VAR
	VAR
		R_TRIG_In : R_TRIG;
		RS_Out : RS;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK SPR_ManualStop (*Triggers a stop movement*)
	VAR_INPUT
		In : BOOL; (*stop command*)
		ManualModeActive : BOOL; (*machine is in manual mode*)
		ManualMoveRelease : BOOL;
		AxisPower : BOOL; (*axis is powered on*)
	END_VAR
	VAR_OUTPUT
		Out : BOOL; (*stop movement (connected to FUB)*)
	END_VAR
	VAR
		R_TRIG_ManualMoveRelease : R_TRIG;
		F_TRIG_ManualMoveRelease : F_TRIG;
	END_VAR
END_FUNCTION_BLOCK
