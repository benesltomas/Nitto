(********************************************************************
 * COPYRIGHT -- Bernecker + Rainer
 ********************************************************************
 * File: Global.typ
 * Author: schoenefeldr
 * Created: July 06, 2012
 ********************************************************************
 * Global data types of project 120706_hp_001
 ********************************************************************)
(*======================================================================================================================================*)
(*GLOBAL OPERATING MODE DEFINITIONS*)
(*======================================================================================================================================*)
(*General operating mode of the machine*)

TYPE
	OpModeEnum_Type : 
		(
		OPMODE_MANUAL := 0, (*Manual mode ("Hand")*)
		OPMODE_AUTOMATIC := 1, (*Automatic mode*)
		OPMODE_SETUP := 2, (*Automatic mode with additional functions ("Einrichten")*)
		OPMODE_SERVICE := 5 (*Service mode with direct access to hardware*)
		);
END_TYPE

(*General machine status*)

TYPE
	MachineStatusEnum_Type : 
		(
		STATE_PREOPERATIONAL := 0, (*Machine not ready for operation*)
		STATE_READY_FOR_OPERATION := 1, (*Machine ready for operation*)
		STATE_AUTOMATIC := 2, (*Machine is running in operating mode automatic*)
		STATE_JOG := 3, (*Jog mode active*)
		STATE_MANUAL := 4, (*Manual operating mode*)
		STATE_FAULT := 5 (*Fault active*)
		);
END_TYPE

(*Cutting unit operating mode*)

TYPE
	OpModeCutEnum_Type : 
		(
		CUT_DISABLED := 20, (*Cut unit disabled*)
		FREE_CUT := 21, (*Free cutting mode*)
		PHYSICAL_TRIGGER := 22, (*synchronous cutting mode*)
		VIRTUAL_TRIGGER := 23 (*synchronous cutting mode*)
		);
END_TYPE

(*Laaminator operating mode 17.01.14 opirational Mode*)

TYPE
	OpModeLaminatorEnum_Type : 
		(
		LAMINATOR_DISABLED := 0,
		LAMINATOR_ENABLED := 1
		);
END_TYPE

(*Label dispenser operating mode*)

TYPE
	OpModeLabelDispenser_Type : 
		(
		LABEL_DISP_DISABLED := 0, (*Label dispenser disabled*)
		LABEL_DISP_ENABLED := 1 (*Label dispenser enabled*)
		);
END_TYPE

(*Long cut unit operating mode*)

TYPE
	OpModeLongCutEnum_Type : 
		(
		LONG_CUT_DISABLED := 10, (*Long cut enabled*)
		LONG_CUT_ENABLED := 11 (*active braking*)
		);
END_TYPE

(*Winder operating mode*)

TYPE
	OpModeWinderEnum_Type : 
		(
		WIND_DISABLED := 35, (*Winder disabled*)
		WINDER := 36, (*Machine ready for operation*)
		BRAKE := 37 (*Brake functionality*)
		);
END_TYPE

(*Web tension unit operating mode*)

TYPE
	OpModeTensionEnum_Type : 
		(
		WEB_TENSION_DISABLED := 5, (*Web tension control disabled*)
		WEB_TENSION_ENABLED := 6 (*Web tension control enabled*)
		);
END_TYPE

(*End module operating mode*)

TYPE
	OpModeEndModuleEnum_Type : 
		(
		END_MODULE_DISABLED := 40, (*No end module selected, disable winder and belts*)
		END_MODULE_TOP_WINDER := 41, (*Select top winder*)
		END_MODULE_BOT_WINDER := 42, (*Select bottom winder*)
		END_MODULE_TANDEM_WINDER := 43, (*Select tandem winder*)
		END_MODULE_BELTS := 44 (*Select upper belt and conveyor belt*)
		);
END_TYPE

(*Markpoint operating mode*)

TYPE
	OpModeMarkpointEnum_Type : 
		(
		DISABLED := 0, (*deactivated*)
		SENSOR_CONTROL := 1, (*Use sensor*)
		PERIOD_CONTROL := 2 (*use period*)
		);
	CONST_MACHINE_MODES_Type : 	STRUCT 
		MANUAL : INT := 0;
		AUTOMATIC : INT := 1;
		PRODUCTION : INT := 2;
		SAFETYSTOP : INT := 7;
		RESET : INT := 8;
		EMERGENCYSTOP : INT := 9;
	END_STRUCT;
END_TYPE

(*Machine structure*)

TYPE
	Machine_Type : 	STRUCT 
		Command : MachineCmd_Type;
		Safety : MachineSafe_Type;
		Data : MachineData_Type;
		Config : MachineCfg_Type;
		IO : MachineIo_Type; (*Inputs on DI9371-38A7 to DI9371-38A10*)
		Status : MachineStatus_Type;
	END_STRUCT;
	MachineCmd_Type : 	STRUCT 
		StartRequestButton : BOOL; (*Start request by pressing of button*)
		StopRequestButton : BOOL; (*Stop request by pressing of button*)
		AutoStopRequestAlarm : BOOL; (*Stop request by alarm handling (automatic mode only)*)
		JogRequestButton : BOOL; (*Jog request by pressing of button*)
		UpdateRecipe : BOOL; (*Command for updating recipe parameters*)
		OpModeSet : OpModeEnum_Type; (*operating mode setpoint*)
		MasterVelocity : REAL; (*master velocity setpoint [µm/s]*)
	END_STRUCT;
	MachineSafe_Type : 	STRUCT 
		RequestSTO : BOOL; (*Emergency Stop is requested (active low)*)
		RequestSLS : BOOL; (*Safe Limited Speed requested by opening safety doors (active low)*)
		ResetSafeMC : BOOL; (*Reset input of SafeMC Function Blocks*)
		ResetStartupInhibit : BOOL; (*Reset emergency functions (quit startup inhibit)*)
		ResetUserSafeMC : BOOL;
		SLSmasterVeloScaled : REAL; (*maximum master velocity command if SLS is requested due to scalings of cutting units*)
	END_STRUCT;
	MachineData_Type : 	STRUCT 
		cut1 : MachineDataCut_Type; (*Derived data for cutting unit 1*)
		cut2 : MachineDataCut_Type; (*Derived data for cutting unit 2*)
		AccMaster : BOOL; (*Accelerate master axis*)
		StopMaster : BOOL; (*Decelerate master axis with machine deceleration ramp*)
		DiscreteMove : BOOL; (*Discrete move over distance or fixed number of packages*)
		VelocityIncrement : REAL; (*Increment for accelerate / decelerate master*)
	END_STRUCT;
	MachineDataCut_Type : 	STRUCT  (*Derived cuttin unit data *)
		cutPeriodLength : REAL; (*Material period corresponding to cutting cylinder perimeter [µm]*)
		scaleCutToMasterPeriod : REAL; (*Scaling factor for conversion of cutting unit into master unit*)
	END_STRUCT;
	MachineCfg_Type : 	STRUCT  (*Configuration data structure*)
		FlengeDMS : USINT; (*Configuration of Flenge DMS analogue input*)
	END_STRUCT;
	MachineStatus_Type : 	STRUCT 
		initDone : BOOL; (*Initialisation complete*)
		recipeUpdating : BOOL; (*recipe updating is active*)
		recipeUpdateDone : BOOL; (*recipe update in all units completed*)
		Diam : MachineStatusDiam_Type; (*actual diameters*)
		Act : MachineStatusEnum_Type; (*actual machine status*)
		OpModeAct : OpModeEnum_Type; (*actual operating mode*)
		CalcDiam : MachineCalcDiam_Type; (*actual estimated diameter *)
		Power : BOOL; (*drives enabled*)
		ReferencedOK : BOOL; (*Combination of necessary reference conditions to start*)
		SupportSpikesOK : BOOL; (*Necessary supportspikes for tandem winders are closed*)
		mManualModeActive : BOOL;
		mAutoModeActive : BOOL;
		StartButtonBlinking : BOOL;
		StartButtonActOut : BOOL;
		WebBreakLabeler : BOOL;
		EnableMasterMove : BOOL;
	END_STRUCT;
	MachineStatusDiam_Type : 	STRUCT 
		MainUnwind : REAL; (*Actual diameter Abwicklung*)
		Spend1 : REAL; (*Actual diameter Abwickler 1*)
		Spend2 : REAL; (*Actual diameter Abwickler 2*)
		Spend3 : REAL; (*Actual diameter Abwickler 3*)
		Spend4 : REAL; (*Actual diameter Abwickler 4*)
		Grid1 : REAL; (*Actual diameter Gitteraufwickler 1*)
		Grid2 : REAL; (*Actual diameter Gitteraufwickler 2*)
		Laminator1 : REAL; (*Actual diameter Laminator 1*)
		Laminator2 : REAL; (*Actual diameter Laminator 2*)
		TUnwindTop : REAL; (*Actual diameter Tandemwickler oben*)
		TUnwindBot : REAL; (*Actual diameter Tandemwickler unten*)
	END_STRUCT;
	MachineCalcDiam_Type : 	STRUCT 
		MainUnwind : REAL; (*Actual estimated diameter Abwicklung*)
		TUnwindTop : REAL; (*Actual estimated diameter Tandemwickler oben*)
		TUnwindBot : REAL; (*Actual estimated diameter Tandemwickler unten*)
	END_STRUCT;
END_TYPE

(*Data types for print marks*)

TYPE
	PrintMark_Type : 	STRUCT 
		Data : PrintMarkData_Type;
		ActIndex : USINT;
		MaxArrIndex : USINT;
	END_STRUCT;
	PrintMarkData_Type : 	STRUCT 
		ActDiff : REAL;
		LastPos : REAL;
		AbsPos : REAL;
	END_STRUCT;
END_TYPE

(*Data types for visualisation*)

TYPE
	Visu_Type : 	STRUCT 
		RelSafeOut : BOOL;
		Cmd : VisuCmd_Type;
		Status : VisuStatus_Type;
	END_STRUCT;
	VisuCmd_Type : 	STRUCT 
		pageSel : VisuCmdPage_Type;
		resetError : BOOL;
		DoReference : BOOL;
		Hold : BOOL;
		StartAddPos : BOOL;
		numPkg : UDINT; (*Input for movement over a number of packages*)
		jogOverride : REAL; (*override for jogging in percent*)
		masterPos : REAL;
		masterVelo : REAL;
	END_STRUCT;
	VisuCmdPage_Type : 	STRUCT 
		selPage : UINT;
		reqPage : UINT;
		actPage : UINT := 100;
		newPage : UINT;
		oldPage : UINT;
	END_STRUCT;
	VisuStatus_Type : 	STRUCT 
		ActVelocity : REAL; (*Actual master speed [µm/s]*)
		ActPosition : REAL; (*Actual master position [µm]*)
	END_STRUCT;
	mAutoPunchPar_typ : 	STRUCT 
		Mode : OpModeCutEnum_Type;
		TriggerIndex : USINT;
		RmWindow : REAL;
		PositionPunch : DINT;
		PositionSensor : DINT;
		CutStartPos : DINT;
		CutEndPos : DINT;
		Insetting : REAL;
		RegMarkPosition : DINT;
		MaxCorr : DINT;
	END_STRUCT;
		RmIfStatusActVal_Type : 	STRUCT  (*Structure for actual data, positions, differences etc.*)
		RmDetected : BOOL; (*A registration mark has been detected during the last movement*)
		RmShiftValid : BOOL; (*The shift value has been calculated after a valid registration mark has been detected*)
		lastValidIndex : USINT; (*Returns the last valid index of the RM data*)
		RegMark : ARRAY[0..MAX_RM_DATA_ARRAY_INDEX]OF RmActValArray_Type; (*Arrays for each registraion mark sensor*)
	END_STRUCT;
		RmActValArray_Type : 	STRUCT  (*Structure for actual data for visualisation*)
		Ident : UDINT; (*Serial number of the registration mark*)
		PIdx : USINT; (*Group index for this RM*)
		RegMarkActPos : DINT; (*Actual RM position [axis units]*)
		AbsPosition : REAL; (*Absolute position of the RM [µm]*)
		Difference : REAL; (*Difference between absolute positions [µm]*)
		SetpointError : REAL; (*Difference between RM position and setpoint [µm]*)
	END_STRUCT;
		reg_mark_typ : 	STRUCT  (*control structure*)
		Command : reg_mark_command_typ; (*command structure*)
		Parameter : reg_mark_parameter_typ; (*parameter structure*)
		Data : reg_mark_data_typ; (*data structure*)
		Status : reg_mark_status_typ; (*status structure*)
	END_STRUCT;
		reg_mark_command_typ : 	STRUCT  (*command structure*)
		StartCorrection : BOOL; (*start the correction*)
		StopCorrection : BOOL; (*stop the correction*)
		SearchTrigger : BOOL; (*search trigger manual*)
		ResetCalc : BOOL; (*reset the calculation data*)
		InitCalcData : BOOL; (*initialize the changed calculation parameters*)
		InitCaptureData : BOOL; (*initialize the changed capture parameters *)
	END_STRUCT;
	reg_mark_parameter_typ : 	STRUCT  (*parameter structure*)
		Mode : USINT; (*RM control mode, e.g. real RMs, virtual RMs etc.*)
		RegMarkAdditiveSetpoint : REAL; (*Additive cumulated RM position*)
		Capture : reg_mark_parameter_capture_typ; (*capture parameter structure*)
		Calculation : MC_RMCALC001_REF; (*ControllerParameter input structure of MC_BR_RegMarkCalc001*)
		Shift : reg_mark_parameter_shift_typ; (*shift parameter structure*)
	END_STRUCT;
	reg_mark_parameter_capture_typ : 	STRUCT  (*capture parameter structure*)
		Trigger : MC_BR_TRIGGER_REF; (*trigger input structure of MC_BR_RegMarkCapture001*)
		Product : MC_BR_PRODUCT_REF; (*product input structure of MC_BR_RegMarkCapture001*)
		WindowNegative : REAL; (*window in which the valid trigger signal can occur before the expected position*)
		WindowPositive : REAL; (*window in which the valid trigger signal can occur after the expected position*)
		DistanceToSensor : REAL; (*distance between the sensor and the cut/seal position*)
	END_STRUCT;
	reg_mark_parameter_shift_typ : 	STRUCT  (*shift parameter structure*)
		Velocity : REAL; (*maximum velocity for reaching the shift *)
		Acceleration : REAL; (*maximum acceleration for reaching the shift*)
		ApplicationDistanceRatio : REAL; (*ratio of shift application distance / product length (must be <1.0!!!)*)
	END_STRUCT;
	reg_mark_data_typ : 	STRUCT 
		resetDone : BOOL; (*handshake with interface for reset command*)
		probeTriggered : BOOL; (*handshake with touchProbe*)
		actRmArrIndex : USINT; (*Write pointer index for array of RM data*)
		axisIndex : USINT; (*Index on global axis handle*)
		config : UDINT; (*configuration bits (available etc.)*)
		attrib : UDINT; (*attribute bits (reserved)*)
		rmStep : USINT; (*general registration mark control step state*)
		tpStep : USINT; (*touch probe step state*)
		lastNumOfValidTriggers : UDINT; (*Last number of valid triggers*)
		receiveParID : UINT; (*ParID of the cyclic data transfer-channel that has been automatically determined*)
		eventDelayTime : REAL; (*estimated transmission delay time [s] (unit "s" avoids division in cyclic task)*)
		eventDelayPosCompensation : REAL; (*estimated position correction for compensation of transmission delay via POWERLINK*)
	END_STRUCT;
	reg_mark_status_typ : 	STRUCT  (*status structure*)
		initDone : BOOL; (*Initialisation completed*)
		Capture : reg_mark_status_capture_typ; (*capture status structure*)
		Calculation : reg_mark_status_calc_typ; (*calculation status structure*)
		ErrorID : UINT; (*ErrorID if an function block reports an error*)
	END_STRUCT;
	reg_mark_status_capture_typ : 	STRUCT  (*capture status structure*)
		ValidTriggers : UDINT; (*number of valid triggers found by the function block*)
		MissedTriggers : UINT; (*number of missed triggers*)
		ActProbePosition : DINT; (*actual position of the last found trigger by TouchProbe*)
		ActLength : REAL; (*actual length of the last found trigger*)
		ActLengthIV : REAL; (*actual length of the interval*)
		ActPosition : REAL; (*actual position of the last found trigger*)
		LengthError : REAL; (*length error of the last interval*)
		SavePositionError : REAL; (*save variable for change detection*)
		PositionError : REAL; (*actual position error of the last found trigger*)
		SetpointError : REAL; (*Setpoint error between RM position setpoint and RM position actual value [µm]*)
		Reserve : REAL; (*Reserve*)
	END_STRUCT;
	reg_mark_status_calc_typ : 	STRUCT  (*calculation status structure*)
		ErrorID : UINT; (*ErrorID*)
		ValidCorrections : UDINT; (*number of valid calculated corrections*)
		Distance : REAL; (*calculated distance difference*)
		Shift : REAL; (*calculated shift*)
		DistanceLimiterActive : BOOL; (*shows if the calculated distance was limited to maximum*)
		ShiftLimiterActive : BOOL; (*shows if the calculated shift was limited to maximum*)
	END_STRUCT;
		RmIf_Type : 	STRUCT 
		Command : RmIfCmd_Type; (*Command structure*)
		Para : RmIfPara_Type; (*Parameter structure*)
		Data : RmIfData_Type; (*General data structure*)
		Status : RmIfStatus_Type; (*Status structure*)
		Error : RmIfError_Type; (*Error data structure*)
	END_STRUCT;
	RmIfCmd_Type : 	STRUCT  (*Command structure*)
		startGeneral : BOOL; (*command for starting (depends on operating mode)*)
		stopGeneral : BOOL; (*command for starting (depends on operating mode)*)
		updatePara : BOOL; (*command for starting parameter update*)
		shadowArrayLocked : BOOL; (*command that inhibits writing to the shadow arrays*)
		clearArray1 : BOOL; (*command for clearing RM array 1*)
		clearArray2 : BOOL; (*command for clearing RM array 2*)
		reset : BOOL; (*command for reset one/all errors*)
	END_STRUCT;
	RmIfPara_Type : 	STRUCT 
		axisNumber : USINT; (*axisNumber for specific commands*)
		Cut1_HomingMode : USINT; (*Tool specific homing mode for Cutting Unit 1*)
		Cut2_HomingMode : USINT; (*Tool specific homing mode for Cutting Unit 2*)
	END_STRUCT;
	RmIfData_Type : 	STRUCT  (*General data structure*)
		changeParaLatch : BOOL; (*Changing of parameters *)
		mainStep : USINT; (*main step of the registration mark control interface*)
	END_STRUCT;
	RmIfStatus_Type : 	STRUCT  (*Status structure*)
		initDone : BOOL; (*Basic interface initialisation completed*)
		rmReady : BOOL; (*registration mark task is ready for operation, may be reset during recipe loading etc.*)
		paraUpdateDone : BOOL; (*parameter update completed*)
		automaticActive : BOOL; (*status machine moves continuously, only stop allowed*)
		isMoving : BOOL; (*status machine is moving (any command)*)
		inSync : BOOL; (*status machine is in synchronized motion and "in gear"*)
		error : BOOL; (*status that at least one function block of the registration mark control has a PLCopen error*)
		ActData : ARRAY[0..MAX_RM_SENSORS_INDEX]OF RmIfStatusActVal_Type; (*Actual data, positions, differences etc.*)
	END_STRUCT;
	RmIfError_Type : 	STRUCT  (*error structure "current active" error*)
		AxisID : STRING[14]; (*axis type (Axis, Master or Slave)*)
		AxisIndex : USINT; (*index of error reporting axis (total axis index)*)
		ErrorText : ARRAY[0..4]OF STRING[79]; (*description of first active error or warning*)
		ErrorRecord : MC_ERRORRECORD_REF; (*error record information*)
		ErrorID : UDINT;
	END_STRUCT;		
		Cut_Type : 	STRUCT 
		MachCut : CutMachData_Type;
		CutUnitRecipe : rcp_prog_cutUnit_typ;
		rmMachineRec : rcp_machine_markpoint_typ; (*machine recipe structure*)
	END_STRUCT;
	rcp_machine_markpoint_typ : 	STRUCT 
		maxRmWidth : REAL; (*maximum width of one registration mark [µm]*)
		minRmWidth : REAL; (*minimum width of one registration mark [µm], minimum < maxmum!*)
		sensorDelay : DINT; (*sensor delay [µs]*)
		sensorToolDistance : REAL; (*distance between sensor and tool [µm]*)
	END_STRUCT;
	CutMachData_Type : 	STRUCT 
		Diam : REAL;
	END_STRUCT;
END_TYPE
