(********************************************************************
 * COPYRIGHT -- Bernecker + Rainer
 ********************************************************************
 * Library: UserRegMa
 * File: UserRegMa.fun
 * Author: knausenbergl
 * Created: October 19, 2012
 ********************************************************************
 * Functions and function blocks of library UserRegMa
 ********************************************************************)

FUNCTION_BLOCK SPR_RmCalcPosError (*Calculates a position error for registration mark control*)
	VAR_INPUT
		Enable : BOOL;
		RecordedValue : DINT; (*Recorded RegMark position, e.g. from a MC_BR_Touchprobe instance [Master Units]*)
		RecordedValueValid : BOOL;
		CutMasterPosition : DINT; (*Uncorrected next cut position [Master Units]*)
		DistanceToSensor : DINT; (*Distance between tool and sensor [Master Units]*)
		RegMarkPosition : DINT; (*RegMark offset relative to cut position [Master Units]*)
		ProductLength : DINT; (*Product length [Master Units]*)
	
	END_VAR
	VAR_OUTPUT
		PositionError : DINT; (*Difference between corrected and uncorrected cut position [Master Units]*)
		PositionErrorValid : BOOL; (*TRUE for 1 cycle if "PositionError" is within current product cycle*)
	END_VAR
	VAR
		State : emuSprRmState;
		SPR_Fifo_0 : SPR_Fifo;
		CorrectedCutPosition : DINT;
		PositionErrorTemp : DINT;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK SPR_RmCapture (*Touchprobe with built-in FIFO for RegMark correction in cross-cutter applications*)
	VAR_INPUT
		Enable : BOOL;
		TriggerInput : MC_BR_TRIGGER_REF; (*Input that is used as event source*)
		Axis : UDINT; (*Axis reference of slave*)
		SearchRM : BOOL; (*Initiate search of new RM on positive edge*)
		CutMasterPosition : DINT; (*Uncorrected next cut position [Master Units]*)
		RegMarkPosition : DINT; (*RegMark offset relative to cut position [Master Units]*)
		WindowNegative : REAL; (*Range before the expected position in which the trigger signal may occur [Master Units]*)
		WindowPositive : REAL; (*Range after the expected position in which the trigger signal may occur [Master Units]*)
		ProductLength : REAL; (*Interval between two expected trigger positions [Master Units]*)
		DistanceToSensor : DINT; (*Distance between tool and sensor [Master Units]*)
	END_VAR
	VAR_OUTPUT
		RecordedValue : DINT; (*Most recent RM position [Master Units]*)
		ProbeCounter : UDINT; (*Number of valid trigger events. Reset by "SearchRM"*)
		MissedTriggers : UDINT; (*Number of invalid or missed trigger events. Reset by "SearchRM"*)
		CorrectionValue : DINT; (*Deviation between corrected and uncorrected cut position [Master Units]. Can be used as a relative distance for correction movements.*)
		CorrectionValid : BOOL; (*TRUE for 1 cycle if "CorrectionValue" is valid. Can be used to trigger correction movements.*)
		ActProductLength : REAL; (*Actual measured product length*)
		Active : BOOL; (*FB is enabled - waiting for a trigger event*)
		Busy : BOOL; (*FB is not yet finished*)
		Error : BOOL; (*Error occurred in FB*)
		ErrorID : UINT; (*Error number*)
	END_VAR
	VAR
		IS : SPR_RMCAPTURE_IS_TYP; (*internal data structure*)
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK SPR_RmPeriodicPosition (*Converts a DINT RegMark position into a periodic REAL RegMark position*)
	VAR_INPUT
		RecordedValue : DINT; (*Recorded RegMark position in DINT format [Master Units]*)
		MasterPeriodicPosition : REAL; (*Periodic master position in REAL format [Master Units]*)
		MasterPosition : DINT; (*Non-periodic master position in DINT format (from axis structure) [Master Units]*)
		MasterPeriod : DINT; (*Master axis modulo period [Master Units]*)
	END_VAR
	VAR_OUTPUT
		Out : REAL; (*Periodic RegMark position in REAL format [Master Units]*)
	END_VAR
	VAR
		MasterModuloOffset : DINT;
		RmModuloOffset : DINT;
		DeltaPeriods : DINT;
	END_VAR
END_FUNCTION_BLOCK
