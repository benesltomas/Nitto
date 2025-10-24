(********************************************************************
 * COPYRIGHT -- Bernecker + Rainer
 ********************************************************************
 * Library: UserSpilke
 * File: UserSpilke.typ
 * Author: knausenbergl
 * Created: November 09, 2012
 ********************************************************************
 * Data types of library UserSpilke
 ********************************************************************)

TYPE
	SPR_AUT_PAR_TYP : 	STRUCT 
		StartMasterVelocity : REAL; (*Master velocity at very first cut [Master Units/ s]*)
		MaxMasterVelocity : REAL; (*Maximum master velocity [Master Units/ s]*)
		Insetting : REAL; (*Insetting ratio for calculation of CutRangeMaster [%]*)
		MaxCorrection : DINT; (*Maximum correction movement per product cycle [Master Units]*)
		CutStartPos : DINT; (*Start of synchronisation within slave period [Slave Units]*)
		CutEndPos : DINT; (*End of synchronisation within slave period [Slave Units]*)
		MinCutRangeSlave : REAL; (*Minimum synchronization distance [Slave Units]*)
		MinCompRangeSlave : REAL; (*Minimum effective compensation distance [Slave Units]*)
	END_STRUCT;
	SPR_SYNC_PAR_TYP : 	STRUCT 
		Velocity : REAL; (*Velocity for reaching phase shift [Master Units / s²]*)
		Acceleration : REAL; (*Acceleration for reaching phase shift [Master Units / s²]*)
	END_STRUCT;
	SPR_PUNCH_IS_TYP : 	STRUCT 
		OffsetValue1 : DINT; (*cumulated offset correction*)
		OffsetValue : DINT; (*cumulated offset correction*)
		CutCntOld : UDINT;
		OffsetErrorValid : BOOL;
		PositionErrorValid : BOOL;
		PositionError : DINT;
		R_TRIG_Enable : R_TRIG;
		R_TRIG_Sync : R_TRIG;
		R_TRIG_InCompensation : R_TRIG;
		SPR_RmCapture_0 : SPR_RmCapture; (*RegMark detection*)
		MC_BR_Phasing_0 : MC_BR_Phasing; (*Synchronization movement*)
		MC_BR_CrossCutterControl_0 : MC_BR_CrossCutterControl; (*Cam automat*)
		MC_MoveAbsolute_0 : MC_MoveAbsolute; (*Setup movement before coupling*)
		MC_BR_ReadAutPosition_0 : MC_BR_ReadAutPosition; (*Reading of actual automat position for restart*)
		MC_ReadParameter_AxisPeriod : MC_ReadParameter; (*Reading of axis period for setup movement*)
		LCRLimit_Correction : LCRLimit; (*Limit RM correction movement*)
		RelativeShift : DINT; (*Relative shift for RM correction*)
		State : emuSPR_Punch_State;
		EnableRestart : BOOL; (*Enable cam automat restart*)
		MC_ReadActualPosition_0 : MC_ReadActualPosition;
		ShiftInProgress : BOOL;
		NeutralPosition : REAL; (*Neutral position where axis is not in synchronisation*)
		LCRLimScal_CutRangeMaster : LCRLimScal;
		SPR_RmCalcPosError_Virtual : SPR_RmCalcPosError; (*Calculate position error for virtual registration marks*)
		CutCount_1 : UDINT;
		CccTriggerInit : BOOL; (*Trigger inititalization of CCC*)
		CccInitMasterMaxVel : BOOL; (*Init max. master velocity*)
	END_STRUCT;
	SPR_JOGGEAR_IS_TYP : 	STRUCT 
		MC_Halt_0 : MC_Halt;
		MC_GearIn_0 : MC_GearIn;
		MC_ReadStatus_0 : MC_ReadStatus;
		State : USINT;
		R_TRIG_Jog : R_TRIG;
		GearRatioChanged : BOOL;
	END_STRUCT;
	SPR_SETUP_PAR_TYP : 	STRUCT 
		Velocity : REAL; (*Maximum velocity [Slave Units / s]*)
		Acceleration : REAL; (*Maximum acceleration [Slave Units / s²]*)
		Deceleration : REAL; (*Maximum deceleration [Slave Units / s²]*)
	END_STRUCT;
	SPR_REG_MARK_PAR_TYP : 	STRUCT 
		Axis : UDINT; (*Axis object of Touchprobe*)
		TriggerInput : MC_BR_TRIGGER_REF; (*Input that is used as event source*)
		DistanceToSensor : DINT; (*Distance between tool and sensor [Master Units]*)
		RegMarkPosition : DINT; (*RegMark offset relative to cut position [Master Units]*)
		WindowNegative : REAL; (*Range before the expected position in which the trigger signal may occur [Master Units]*)
		WindowPositive : REAL; (*Range after the expected position in which the trigger signal may occur [Master Units]*)
		EnableRmCorrection : BOOL; (*Enable RM correction*)
		EnableVRegMark : BOOL; (*Use virtual reg mark instead of physical sensor signal*)
		EnableOffsetCorr : BOOL; (*Allow longitudinal correction of register*)
	END_STRUCT;
	basic_status_typ : 	STRUCT  (*status structure*)
		ErrorID : UINT; (*ErrorID of any occured error*)
		ErrorText : ARRAY[0..3]OF STRING[79]; (*Error Text*)
		ActPosition : REAL; (*actual position of the axis*)
		ActVelocity : REAL; (*actual velocity of the axis*)
		DriveStatus : MC_DRIVESTATUS_TYP; (*actual status of the axis*)
	END_STRUCT;
	basic_axisState_typ : 	STRUCT  (*axis state structure*)
		Disabled : BOOL; (*if set, axis is in state Disabled*)
		StandStill : BOOL; (*if set, axis is in state StandsStill*)
		Homing : BOOL; (*if set, axis is in state Homing*)
		Stopping : BOOL; (*if set, axis is in state Stopping*)
		DiscreteMotion : BOOL; (*if set, axis is in state DiscreteMotion*)
		ContinuousMotion : BOOL; (*if set, axis is in state ContinousMotion*)
		SynchronizedMotion : BOOL; (*if set, axis is in state SynchronizedMotion*)
		ErrorStop : BOOL; (*if set, axis is in state ErrorStop*)
		Homed : BOOL;
	END_STRUCT;
	basic_typ : 	STRUCT  (*control structure*)
		Command : basic_command_typ; (*command structure*)
		Parameter : basic_parameter_typ; (*parameter structure*)
		Status : basic_status_typ; (*status structure*)
		AxisState : basic_axisState_typ; (*axis state structure*)
	END_STRUCT;
	emuSPR_Punch_State : 
		(
		SPR_STATE_DISABLED,
		SPR_STATE_INIT,
		SPR_STATE_IDLE,
		SPR_STATE_CHECK_STANDBY,
		SPR_STATE_READ_AUT_POS,
		SPR_STATE_MOVE_TO_AUT_POS,
		SPR_STATE_MOVE_TO_NEUTRAL_POS,
		SPR_STATE_W4_REG_MARK,
		SPR_STATE_START_AUTOMAT,
		SPR_STATE_RUNNING,
		SPR_STATE_W4_RESET,
		SPR_STATE_ERROR
		);
	basic_command_typ : 	STRUCT  (*command structure*)
		Power : BOOL; (*switch on the controller*)
		Home : BOOL; (*reference the axis*)
		MoveAbsolute : BOOL; (*move to an defined position*)
		MoveAdditive : BOOL; (*move a defiened distance*)
		MoveVelocity : BOOL; (*start a movement with a defiened velocity*)
		Halt : BOOL; (*stop every active movement*)
		Stop : BOOL; (*stop every active movement as long as is set*)
		MoveJogPos : BOOL; (*move in positive direction as long as is set*)
		MoveJogNeg : BOOL; (*move in negative direction as long as is set*)
		ErrorAcknowledge : BOOL; (*reset active errors*)
	END_STRUCT;
	basic_parameter_typ : 	STRUCT  (*parameter structure*)
		Position : REAL; (*target-position for MoveAbsolute-Command*)
		Distance : REAL; (*distance for MoveAdditive-Command*)
		Velocity : REAL; (*velocity for MoveVelocity-Command*)
		Direction : USINT; (*direction for commanded movements*)
		Acceleration : REAL; (*acceleration for commanded movements*)
		Deceleration : REAL; (*deceleration for commanded movements*)
		HomePosition : REAL; (*target-position for referencing the axis*)
		HomeMode : USINT; (*homing mode*)
		JogVelocity : REAL; (*velocity for jogging movement*)
	END_STRUCT;
END_TYPE
