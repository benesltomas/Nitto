(********************************************************************
 * COPYRIGHT -- Bernecker + Rainer
 ********************************************************************
 * Library: UserSpilke
 * File: UserSpilke.fun
 * Author: knausenbergl
 * Created: November 09, 2012
 ********************************************************************
 * Functions and function blocks of library UserSpilke
 ********************************************************************)

FUNCTION_BLOCK SPR_PneumLever (*pneumatic lever (unwinder up down)*)
	VAR_INPUT
		Up : BOOL; (*move up command*)
		Down : BOOL; (*move down command*)
		LimitSwitchTop : BOOL; (*limitswich top*)
		LimitSwitchBottom : BOOL; (*limitswitch bottom*)
	END_VAR
	VAR_OUTPUT
		ValveUp : BOOL; (*switch on valve (to move upwards)*)
		ValveDown : BOOL; (*switch on valve (to move downwards)*)
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK SPR_Punch (*Implements the punch operation in automatic mode*)
	VAR_INPUT
		Master : UDINT; (*Master axis reference*)
		Slave : UDINT; (*Slave axis reference*)
		Enable : BOOL;
		EnableMove : BOOL; (*Allow this FUB to execute movements*)
		SearchRM : BOOL; (*Initiate search of new RM on positive edge*)
		RestartAllowed : BOOL; (*Execute a synchronization movement (only possible when "Move" is TRUE)*)
		Sync : BOOL; (*Execute a synchronization movement (only possible when "Move" is TRUE)*)
		VRmCorrection : DINT; (*Correction value for virtual marks*)
		ProductLength : DINT; (*Product length [Master Units]*)
		VRmRecordedPosition : DINT; (*Recorded position when using virtual registration mark*)
		RegMarkPar : SPR_REG_MARK_PAR_TYP; (*Parameters for registration mark detection and evaluation*)
		AutPar : SPR_AUT_PAR_TYP; (*Cam automat parameters*)
		SyncPar : SPR_SYNC_PAR_TYP; (*Parameters for the synchronization movement*)
		SetupPar : SPR_SETUP_PAR_TYP; (*Parameters for setting up the axis before coupling*)
	END_VAR
	VAR_OUTPUT
		Active : BOOL; (*Cam automat is running*)
		Error : BOOL;
		ErrorID : UINT;
		EnableRestart : BOOL;
		SetupComplete : BOOL; (*Setup movement complete, punch clamp can be closed*)
		CutMasterPosition : DINT; (*Cut master position [Master Units]*)
		ProbeCounter : UDINT; (*Counter for valid trigger events*)
		MissedTriggers : UDINT; (*Counter for missed trigger events*)
		ActPositionError : DINT; (*Actual reg mark position error [Master Units]*)
	END_VAR
	VAR
		IS : SPR_PUNCH_IS_TYP;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK SPR_HydLever (*Hydraulic lever (e.g. of the unwinder)*)
	VAR_INPUT
		Up : BOOL; (*move up command*)
		Down : BOOL; (*move down command*)
		LimitSwitchTop : BOOL;
		LimitSwitchBottom : BOOL;
	END_VAR
	VAR_OUTPUT
		ValveOn : BOOL; (*switch on valve (to move downwards)*)
		MotorOn : BOOL; (*switch on motor*)
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK SPR_WinderClutch (*Control of prop. valve for winder clutch*)
	VAR_INPUT
		RefDiameter : ARRAY[0..1] OF REAL; (*reference diameters [Master Units]
RefDiameter[0] = diameter at min. pressure
RefDiameter[1] = diameter at max. pressure*)
		RefPressure : ARRAY[0..1] OF REAL; (*reference pressure [%]
RefPressure[0] = min. pressure
RefPressure[1] = max. pressure*)
		ActDiameter : REAL; (*actual winder diameter [Master Units]*)
	END_VAR
	VAR_OUTPUT
		SetPressure : REAL; (*set valve pressure [%]*)
	END_VAR
	VAR
		LCRLimScal_Pressure : LCRLimScal;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK SPR_CheckTextIndexValid (*Checks if a textgroup index exists*)
	VAR_INPUT
		Enable : BOOL;
		VCHandle : UDINT;
		TG_id : UDINT;
		TGT_id : UINT;
	END_VAR
	VAR_OUTPUT
		Status : UINT;
		Valid : BOOL;
		Text : STRING[80];
	END_VAR
	VAR
		TextLength : UINT;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK SPR_MeterCounter (*Counts length periods on an axis*)
	VAR_INPUT
		Enable : BOOL; (*Enables the cam switch*)
		Period : REAL; (*Definition of the period, in case a non-periodic master axis is used or if the cam switch period does not match the master axis period*)
		Axis : UDINT; (*Axis reference of the axis from which the position is being taken*)
	END_VAR
	VAR_OUTPUT
		InOperation : BOOL; (*The controlled track is enabled.*)
		Busy : BOOL; (*FB is not yet finished*)
		Error : BOOL; (*Error occurred in FB*)
		ErrorID : UINT; (*Error number*)
	END_VAR
	VAR_IN_OUT
		PeriodCount : UDINT; (*Period count (incremented every time the axis moves another period)*)
	END_VAR
	VAR
		MC_BR_DigitalCamSwitch_0 : MC_BR_DigitalCamSwitch;
		F_TRIG_Value : F_TRIG;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK SPR_ScaleCircumference (*Scales a tool circumference to a whole number that is divisible without remainder by the number of tool segments*)
	VAR_INPUT
		ActCircumference : REAL;
		NumberToolSegments : USINT;
	END_VAR
	VAR_OUTPUT
		ScaledCircumference : UDINT;
		ToolSegmentPeriod : UDINT;
	END_VAR
	VAR
		Remainder : DINT;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK SPR_DrivesGlobal (*Monitors the status of all drives*)
	VAR_INPUT
		Init : BOOL; (*Allocates memory for the required number of function blocks*)
		Enable : BOOL; (*Enables function block*)
		pAxes : UDINT; (*Pointer to UDINT array with axis objects*)
		MaxNumberAxes : USINT; (*Maximum number of axis objects*)
	END_VAR
	VAR_OUTPUT
		InitDone : BOOL; (*Memory successfully allocated*)
		Valid : BOOL;
		Busy : BOOL;
		Error : BOOL;
		ErrorID : UINT;
		DriveStatusAll : MC_DRIVESTATUS_TYP; (*DriveStatus[Axis_1] AND DriveStatus[Axis_2] AND ... AND DriveStatus[Axis_N]*)
		DriveStatusAny : MC_DRIVESTATUS_TYP; (*DriveStatus[Axis_1] OR DriveStatus[Axis_2] OR ... OR DriveStatus[Axis_N]*)
	END_VAR
	VAR
		pMC_BR_ReadDriveStatus : REFERENCE TO MC_BR_ReadDriveStatus;
		State : USINT;
		StartAddress : UDINT; (*start address of dynamic MC_BR_ReadDriveStatus array*)
		pAxis : REFERENCE TO UDINT;
		C_MaxNumberAxes : USINT;
		MC_BR_ReadDriveStatus_Dummy : ARRAY[0..0] OF MC_BR_ReadDriveStatus;
		AllocStatus : UINT; (*status of TMP_Alloc function*)
		AxisIndex : USINT;
		TempDriveStatus : MC_DRIVESTATUS_TYP;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK SPR_MoveMaster (*Starts a movement of the master axis*)
	VAR_INPUT
		Enable : BOOL;
		SlavesReady : BOOL;
		AdditiveMovement : BOOL;
		Velocity : BOOL;
		Acceleration : BOOL;
		Deceleration : BOOL;
		Distance : BOOL;
	END_VAR
	VAR_OUTPUT
		Error : BOOL;
		ErrorID : UINT;
		Busy : BOOL;
	END_VAR
	VAR
		MC_Halt : MC_Halt;
		New_Member : MC_BR_JogVelocity;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK SPR_UnwinderCtrl (*Controls an unwinder with a magnet particle brake*)
	VAR_INPUT
		Enable : BOOL;
		InitPidPar : BOOL; (*Initialize PID parameters on positive edge*)
		PidPar : wnc_pidPara_typ; (*PID controller parameters*)
		CoreInertia : REAL; (*Mass moment of inertia of empty winder [kgm²]*)
		CoreDiam : REAL; (*Diameter of empty winder [m]*)
		MaxDiam : REAL; (*Maximum winder diameter [m]*)
		MaxRollMass : REAL; (*Mass of roll at maximum diameter [kg]*)
		ForceFf : REAL; (*Feed forward force [N]*)
		ActDiam : REAL; (*Actual winder diameter [m]*)
		SetDancerPos : REAL; (*Set dancer position [Dancer Units]*)
		ActDancerPos : REAL; (*Actual dancer position [Dancer Units]*)
		MaxTorque : REAL; (*Maximum brake torque [Nm]*)
	END_VAR
	VAR_OUTPUT
		Status : UINT;
		SetTorque : REAL; (*Set torque for winder brake*)
	END_VAR
	VAR
		State : USINT;
		WNCPidCtrl_0 : WNCPidCtrl;
		K_RollMass : REAL; (*Constant to calculate actual mass of Roll: K_RollMass = Pi * MaterialWidth * MaterialDensity*)
		ActRollMass : REAL;
		ActInertia : REAL;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK SPR_LabelerAut (*Cam automat configuration for labeling unit*)
	VAR_INPUT
		Master : UDINT; (*Master axis object*)
		LabelPeriod : REAL; (*Label period [Units]*)
		DistanceToLabelSensor : REAL; (*Distance between sensor and labelling position [Units]*)
		MaxMasterVelocity : REAL; (*Maximum master velocity [Units / s]*)
		ProductLengthMaster : REAL; (*Product length on master axis [Units]*)
		TriggerEvent : USINT; (*Trigger event for correction, e.g. ncTrigger1 + ncP_EDGE*)
	END_VAR
	VAR_OUTPUT
		adrAutData : UDINT;
	END_VAR
	VAR
		AutData : MC_AUTDATA_TYP;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK SPR_LabelerAutVax (*Cam automat configuration for an "ideal" labeler (no label position correction)*)
	VAR_INPUT
		Master : UDINT; (*Master axis object*)
		LabelPeriod : REAL; (*Label period [Units]*)
		ProductLengthMaster : REAL; (*Product length on master axis [Units]*)
		DistanceToRmSensor : REAL; (*Distance between sensor and labelling position [Units]*)
		MaxMasterVelocity : REAL; (*Maximum master velocity [Units / s]*)
		RegMarkPosition : REAL; (*Reg mark position relative to label [Units]*)
		CamLength : REAL; (*Distance the label runs synchronized to master [Units]*)
		CorrectionLongitudinal : BOOL; (*Manually longitudinal correction*)
		CorrectionLongitudinalValue : REAL; (*Manually longitudinal correction value*)
		AccelerationBias : REAL; (*AccelerationDistance / DecelerationDistance
Valid Range: 0.1...10.0
<0.1   ...   AccelerationDistance = DecelerationDistance (default)
0.1     ...   AccelerationDistance = 0.1 * DecelerationDistance
1.0     ...   AccelerationDistance = DecelerationDistance
2.0     ...   AccelerationDistane   = DecelerationDistance
10.0   ...   AccelerationDistance = 10 * DecelerationDistance
>10.0 ...   AccelerationDistance = DecelerationDistance (default)*)
		TriggerEvent : USINT; (*Trigger event for correction, e.g. ncTrigger1 + ncP_EDGE*)
	END_VAR
	VAR_OUTPUT
		adrAutData : UDINT;
	END_VAR
	VAR
		AutData : MC_AUTDATA_TYP;
		AccelerationDistance : REAL;
		DecelerationDistance : REAL;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK SPR_OverflowDetection (*Detects overflow e,g, of a periodic position*)
	VAR_INPUT
		PeriodicPosition : DINT; (*Periodic position*)
		ModuloPeriod : DINT; (*Modulo period at which overflow occurs*)
		Enable : BOOL; (*Enables FUB*)
	END_VAR
	VAR_OUTPUT
		AbsolutePosition : DINT; (*Absolute position (reset when FUB is disabled)*)
		PositiveOverflow : BOOL; (*Overflow in negative direction (TRUE for 1 cycle)*)
		NegativeOverflow : BOOL; (*Overflow in positive direction (TRUE for 1 cycle)*)
	END_VAR
	VAR
		PeriodOffset : DINT; (*Offset of actual period*)
		PeriodicPosition_1 : DINT;
		R_TRIG_Enable : R_TRIG;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK SPR_JogGear (*Gear in and update the gear ratio as long as the Jog input is set*)
	VAR_INPUT
		Jog : BOOL;
		Master : UDINT;
		Slave : UDINT;
		RatioNumerator : INT;
		RatioDenominator : UINT;
		Acceleration : REAL;
		Deceleration : REAL;
		MasterParID : UINT;
		MasterParIDMaxVelocity : REAL;
	END_VAR
	VAR_OUTPUT
		InGear : BOOL;
		Halting : BOOL;
		Busy : BOOL;
		CommandAborted : BOOL;
		Error : BOOL;
		ErrorID : UINT;
	END_VAR
	VAR
		IS : SPR_JOGGEAR_IS_TYP;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK FB_LaminateCTRL (*TODO: Bitte Kommentar hier einzufügen*)
	VAR_IN_OUT
		machineMaster : USINT; (*SPR_MoveMaster;(*ACP10AXIS_typ;*)
		status : USINT; (*unitAxis 		:FB_AxisCtrl;*)
		MarkpointMaster : SPR_RmCapture;
		MarkpointUnit : SPR_RmCapture;
		State : emuSPR_Punch_State;
		newParam5 : BOOL;
	END_VAR
	VAR
		StateCtrl : INT;
	END_VAR
	VAR CONSTANT
		STATE_READY : USINT := 10;
		STATE_POWER_ON : USINT := 1;
		STATE_MOVE_VELOCITY : USINT := 16;
		STATE_MOVE_ABSOLUTE : USINT := 14;
		STATE_WAIT : USINT := 0;
		STATE_STOP : USINT := 11;
		STATE_MOVE_ADDITIVE : USINT := 15;
		STATE_HOME : USINT := 2;
		STATE_ERROR_RESET : USINT := 102;
		STATE_ERROR_AXIS : USINT := 100;
		STATE_ERROR : USINT := 101;
		STATE_JOG_POSITIVE : USINT := 12;
		STATE_JOG_NEGATIVE : USINT := 13;
		STATE_HALT : USINT := 17;
	END_VAR
END_FUNCTION_BLOCK
(*
FUNCTION_BLOCK FB_AxisCtrl 
	VAR_INPUT
		BasicControl 			:basic_typ;
		MC_Home_0 				:MC_Home;
		MC_MoveAbsolute_0 		:MC_MoveAbsolute;
		MC_MoveAdditive_0 		:MC_MoveAdditive;
		MC_MoveVelocity_0 		:MC_MoveVelocity;
		MC_Power_0 				:MC_Power;
		MC_ReadActualPosition_0 : MC_ReadActualPosition;
		MC_ReadActualVelocity_0 : MC_ReadActualVelocity;
		MC_ReadAxisError_0 		: MC_ReadAxisError;
		MC_ReadStatus_0 		: MC_ReadStatus;
		MC_Reset_0 				: MC_Reset;
		MC_Stop_0 				: MC_Stop;
		MC_BR_ReadDriveStatus_0 : MC_BR_ReadDriveStatus;
		MC_Halt_0 				: MC_Halt;
		MC_GearIn_0				: MC_GearIn;
		Axis1Obj 				: UDINT;
		AxisStep 				: UINT;
	END_VAR
	VAR CONSTANT 
		STATE_READY 		: USINT := 10;
		STATE_POWER_ON		: USINT := 1;
		STATE_MOVE_VELOCITY : USINT := 16;
		STATE_MOVE_ABSOLUTE : USINT := 14;
		STATE_WAIT 			: USINT := 0;
		STATE_STOP 			: USINT := 11;
		STATE_MOVE_ADDITIVE : USINT := 15;
		STATE_HOME 			: USINT := 2;
		STATE_ERROR_RESET 	: USINT := 102;
		STATE_ERROR_AXIS 	: USINT := 100;
		STATE_ERROR 		: USINT := 101;
		STATE_JOG_POSITIVE 	: USINT := 12;
		STATE_JOG_NEGATIVE 	: USINT := 13;
		STATE_HALT 			: USINT := 17;
	END_VAR
END_FUNCTION_BLOCK
*)

FUNCTION_BLOCK FB_MainCtrl (*TODO: Bitte Kommentar hier einzufügen*)
	VAR_INPUT
		cycletime : UDINT;
		mainCtrlState : USINT;
		rcpActState : USINT;
	END_VAR
END_FUNCTION_BLOCK
(*FUNCTION_BLOCK FB_MainHw  (*TODO: Bitte Kommentar hier einzufügen*)
(*	VAR_INPUT
		SL8010_8A1 :   BOOL ;  (**)
(*		SO4110_38A5 :   BOOL ;  (**)
(*	END_VAR
END_FUNCTION_BLOCK*)

FUNCTION_BLOCK FB_MainHW (*TODO: Bitte Kommentar hier einzufügen*)
	VAR_INPUT
		SL8010_8A1 : BOOL;
		SO4110_38A5 : BOOL;
	END_VAR
END_FUNCTION_BLOCK
