(********************************************************************
 * COPYRIGHT -- Microsoft
 ********************************************************************
 * Library: Bibliothek
 * Datei: Bibliothek.fun
 * Autor: Awalz
 * Erstellt: 31. März 2014
 ********************************************************************
 * Funktionen und Funktionsblöcke der Library Bibliothek
 ********************************************************************)

FUNCTION_BLOCK FB_CONST_MACHINE_MODES (*TODO: Bitte Kommentar hier einzufügen*)
	VAR_OUTPUT
		MANUAL : INT := 0;
		AUTOMATIC : INT := 1;
		PRODUCTION : INT := 2;
		SAFETYSTOP : INT := 7;
		RESET : INT := 8;
		EMERGENCYSTOP : INT := 9; (*texts : ARRAY[MANUAL..EMERGENCYSTOP] OF STRING[20] := ['MANUAL','AUTOMATIC','PRODUCTION','***3***','***4***','***5***','***6***','SAFETYSTOP','RESET','EMERGENCYSTOP'];*)
		texts : ARRAY[0..9] OF STRING[20] := ['MANUAL','AUTOMATIC','PRODUCTION','***3***','***4***','***5***','***6***','SAFETYSTOP','RESET','EMERGENCYSTOP'];
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK FB_CONST_AXIS_ACTIONS (*TODO: Bitte Kommentar hier einzufügen*)
	VAR_OUTPUT
		NOACTION : INT := 0;
		START : INT := 1;
		CALIBR : INT := 2;
		JOG_POS : INT := 3;
		JOG_NEG : INT := 4;
		SETPOS : INT := 6;
		CPLON : INT := 7;
		CPLOFF : INT := 8;
		STOP : INT := 9;
		RESET : INT := 10;
		OPEN : INT := 11; (* Break Open*)
		CLOSE : INT := 12; (* Break Close*)
		WRITE : INT := 13; (* Write Parameter*)
		READ : INT := 14; (* Read Parameter*)
		MOVE_VELOCITY : INT := 15;
		POWER_ON : INT := 16;
		VAXIS_ON : INT := 17;
		POWER_OFF : INT := 18;
		MOVE_CYCLIC_VELOCITY : INT := 20;
		SETPOSREL : INT := 21;
		SETPOSREL_NOLIMIT : INT := 22;
		EMERGENCY_DECELERATION : REAL := 1111111; (*200m/min 200*16666.67/2 in 2 sek*)
		texts : ARRAY[0..19] OF STRING[15] := ['NOACTION','START','CALIBR','JOG_POS','JOG_NEG','SETPOS','SETPOS','CPLON','CPLOFF','STOP','RESET','OPEN','CLOSE','WRITE','READ','MOVE_VELO','POWER_ON','VAXIS_ON','POWER_OFF'];
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK FB_CONST_MASCHINE (*TODO: Bitte Kommentar hier einzufügen*)
	VAR_INPUT
		MACHINEMODES : FB_CONST_MACHINE_MODES;
		AXIS : FB_CONST_AXIS_ACTIONS;
		LAMP : FB_CONST_LAMP;
		CUTTINGUNIT : FB_CONST_CUTTINGUNIT;
		UNITMODEs : FB_CONST_UNIT_MODES;
		ALARMS : FB_CONST_ALARMS;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK FB_ClkPulse (*TODO: Bitte Kommentar hier einzufügen*)
	VAR_INPUT
		enable : BOOL;
		TimeOn : TIME := T#100ms;
		TimeOff : TIME := T#100ms;
	END_VAR
	VAR_OUTPUT
		Output : BOOL := FALSE;
	END_VAR
	VAR CONSTANT
		CLOCK_ON : INT := 0;
		CLOCK_WAIT_ON : INT := 1;
		CLOCK_WAIT_OFF : INT := 3;
	END_VAR
	VAR
		state : INT := CLOCK_ON;
		timer : TON;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK FB_Clk (*TODO: Bitte Kommentar hier einzufügen*)
	VAR_OUTPUT
		c500 : FB_ClkPulse := (enable:=TRUE,TimeOn:=T#500ms,TimeOff:=T#500ms);
		c200 : FB_ClkPulse := (enable:=TRUE,TimeOn:=T#200ms,TimeOff:=T#200ms);
		c1000 : FB_ClkPulse := (enable:=TRUE,TimeOn:=T#1000ms,TimeOff:=T#1000ms);
		c5000 : FB_ClkPulse := (enable:=TRUE,TimeOn:=T#5000ms,TimeOff:=T#5000ms);
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK FB_CONST_LAMP (*TODO: Bitte Kommentar hier einzufügen*)
	VAR_OUTPUT
		OFF : INT := 0;
		ON : INT := 1;
		BLINK200 : INT := 2;
		BLINK500 : INT := 3;
		BLINK1000 : INT := 4;
		BLINK5000 : INT := 5;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK FB_CONST_CUTTINGUNIT (*TODO: Bitte Kommentar hier einzufügen*)
	VAR_INPUT
		MODEs : FB_CONST_CUTTINGUNIT_MODES;
		CMDs : FB_CONST_CUTTINGUNIT_CMDS;
		ERRORs : FB_CONST_CUTTINGUNIT_ERRORS;
		TOOLs : FB_CONST_CUTTINGUNIT_TOOLS;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK FB_CONST_CUTTINGUNIT_MODES (*TODO: Bitte Kommentar hier einzufügen*)
	VAR_OUTPUT
		DISABLE : UDINT := 0; (*BYTE *) (* nicht gekoppelt zur Achse vom Mastermodul *)
		FREE_RUN : UDINT := 1; (*BYTE *) (* freies Schneiden *)
		SYNC_RUN : UDINT := 2; (*BYTE *) (* synchronisieren z.B. Registermarken *)
		CROSS_CUT : UDINT := 3;
		END_MODE : UDINT := 10; (*BYTE *)
		texts : ARRAY[1..4] OF STRING[20] := ['DISABLE','FREE_RUN','SYNC_RUN','CROSS_CUT'];
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK FB_CONST_CUTTINGUNIT_CMDS (*TODO: Bitte Kommentar hier einzufügen*)
	VAR_OUTPUT
		NO_CMD : INT := 0;
		CALIBR : INT := 1;
		INIT : INT := 2;
		CPL_ON : INT := 3;
		CPL_OFF : INT := 4;
		DEINIT : INT := 5;
		SYNC : INT := 6;
		MOVEFW : INT := 7;
		MOVEBW : INT := 8;
		RESET : INT := 9;
		SETDATA : INT := 10;
		ABORT : INT := 11;
		texts : ARRAY[1..11] OF STRING[20] := ['NO_CMD','CALIBR','INT','CPL_ON','CPL_OFF','DEINIT','SYNC','MOVEFW','MOVEBW','RESET','SETDATA','ABORT'];
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK FB_CONST_UNIT_MODES (*TODO: Bitte Kommentar hier einzufügen*)
	VAR_OUTPUT
		DISABLE : UDINT := 0; (*BYTE*)
		ENABLE : UDINT := 1; (*BYTE*)
		AXIS_OFF : DINT := 2;
		texts : ARRAY[0..2] OF STRING[20] := ['DISABLE','ENABLE','AXIS_OFF'];
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK FB_CUTTINGUNIT_CMD (*TODO: Bitte Kommentar hier einzufügen*)
	VAR_INPUT
		value : INT;
		set : BOOL;
	END_VAR
	VAR_OUTPUT
		text : STRING[20];
	END_VAR
	VAR
		CONST : FB_CONST_MASCHINE;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK FB_TensionMeasure (*TODO: Bitte Kommentar hier einzufügen*)
	VAR_INPUT
		offsetVisu : LREAL;
		data : FB_TENSIONMEASUREDATA;
		init : BOOL;
	END_VAR
	VAR_OUTPUT
		status : FB_ModulStatus;
		actValue : LREAL;
	END_VAR
	VAR
		CyclicWrite : MC_BR_CyclicWrite;
		PIDControler : LCRPID; (* PID REGLER*)
		LCRPIDpara_TM : LCRPIDpara; (* Parameter für PID REGLER*)
		FilterPT1 : LCRPT1e;
		CONST : FB_CONST_MASCHINE;
	END_VAR
	VAR CONSTANT
		STEP_TM_INIT1 : USINT := 0; (*Initialisation step 1*)
		TENSION_T_FILTER : REAL := 0.016; (*tension filter time [s]*)
		STEP_TM_WAIT_POWER_ENABLED : USINT := 7; (*Wait until all available axes are enabled*)
		STEP_TM_READY : USINT := 10; (*General state after initialisation, waining for commands*)
		STEP_TM_LOAD_PARA_START : USINT := 20; (*Start parameter loading (e.g. PID controller parameter)*)
		STEP_TM_WAIT_LOAD_PARA_DONE : USINT := 21; (*Wait for parameter being loaded *)
		STEP_TM_WAIT_SWITCH_CTRL_ON : USINT := 40; (*Switch PID controller on*)
		STEP_TM_CTRL_ACTIVE : USINT := 41; (*Wait for commands in active control*)
		STEP_TM_CTRL_PAUSE : USINT := 42; (*Pausing control until the master velocity is back in the required range*)
		STEP_TM_CTRL_OFF : USINT := 43; (*Switch off web tension control*)
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK FB_TENSIONMEASUREDATA (*TODO: Bitte Kommentar hier einzufügen*)
	VAR_INPUT
		mode : UDINT; (*BYTE;*)
		setvalue : REAL;
	END_VAR
	VAR_OUTPUT
		newRecipe : BOOL;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK FB_Safety (*TODO: Bitte Kommentar hier einzufügen*)
	VAR_INPUT
		ResetSafeMC : BOOL; (*Reset input of SafeMC Function Blocks*)
		ResetStartupInhibit : BOOL; (*Reset emergency functions (quit startup inhibit)*)
		ResetUserSafeMC : BOOL;
		SLSmasterVeloScaled : REAL;
		Control_OFF : BOOL;
		CtrlPowerEmcyDel : BOOL;
		CtrlPowerEmcyUndel : BOOL; (* schaltet die Schützte für 24V Versorgung*)
		EnabDrives : BOOL;
		manuelmode : BOOL;
	END_VAR
	VAR_OUTPUT
		RequestSTO : BOOL; (*Emergency Stop is requested (active low)*)
		RequestSLS : BOOL; (*Safe Limited Speed requested by opening safety doors (active low)*)
		Request_ONdelay : BOOL;
		valid : BOOL;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK FB_ModulStatus (*TODO: Bitte Kommentar hier einzufügen*)
	VAR_INPUT
		id : UINT;
		name : STRING[30];
		isCoupled : BOOL;
		mode : UDINT; (* BYTE;*)
		ready : BOOL;
		reverse : BOOL;
		axiserror : BOOL;
	END_VAR
	VAR_OUTPUT
		modeName : STRING[80];
		error : BOOL;
		AxisState_status : STRING[20];
	END_VAR
	VAR_IN_OUT
		axisState : MC_ReadStatus;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK FB_Ampel (*TODO: Bitte Kommentar hier einzufügen*)
	VAR_INPUT
		Rot : FB_Lamp; (*DiDo_Type;*)
		Gelb : FB_Lamp; (*DiDo_Type;*)
		Gruen : FB_Lamp; (* DiDo_Type;*)
		horn : BOOL;
		hornoff : BOOL;
		hornPuls : FB_Lamp;
		ondelay : TIME;
	END_VAR
	VAR_OUTPUT
		horn_o : BOOL;
	END_VAR
	VAR_IN_OUT
		clk : FB_Clk;
	END_VAR
	VAR
		rtrig : R_TRIG;
		timer_TOF : TOF;
		timer_TON : TON;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK FB_Lamp (*TODO: Bitte Kommentar hier einzufügen*)
	VAR_INPUT
		aktion : INT := 0;
	END_VAR
	VAR_OUTPUT
		led : BOOL := FALSE;
		ledinv : BOOL := FALSE;
		button : BOOL;
		rtrig : R_TRIG;
		ftrig : F_TRIG;
	END_VAR
	VAR_IN_OUT
		clk : FB_Clk;
	END_VAR
	VAR
		CONST : FB_CONST_MASCHINE;
		output : BOOL := FALSE;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK FB_KeyLamp (*TODO: Bitte Kommentar hier einzufügen*)
	VAR_INPUT
		LDT : FB_Lamp;
	END_VAR
	VAR_IN_OUT
		clk : FB_Clk;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK FB_UnitChkStatus (*TODO: Bitte Kommentar hier einzufügen*)
	VAR_INPUT
		enable : BOOL;
		setMode : UDINT; (*BYTE;*)
	END_VAR
	VAR_OUTPUT
		ready : BOOL;
	END_VAR
	VAR_IN_OUT
		status : FB_ModulStatus;
	END_VAR
	VAR
		CONST : FB_CONST_MASCHINE;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK FB_PullBreakClampToggle (*TODO: Bitte Kommentar hier einzufügen*)
	VAR_INPUT
		buttomToggle : FB_KeyLamp;
		buttomToggle2 : FB_KeyLamp;
		limiterSwitchDrvSide : BOOL;
		limiterSwitchOpSide : BOOL;
		isup : BOOL;
		isdown : BOOL;
		enable : BOOL;
		init : BOOL;
		onewayini : BOOL;
	END_VAR
	VAR_OUTPUT
		toUp_o : BOOL;
		toDown_o : BOOL;
		limiterBackward_o : BOOL;
		limiterForward_o : BOOL;
	END_VAR
	VAR_IN_OUT
		clk : FB_Clk;
	END_VAR
	VAR
		Time1 : TON;
		state : USINT := 0;
		CONST : FB_CONST_MASCHINE;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK FB_ErrorHdl (*TODO: Bitte Kommentar hier einzufügen*)
	VAR_INPUT
		set : BOOL;
		reset : BOOL;
		flag : BOOL;
		id : DINT;
		state : DINT;
		text : STRING[256];
		fnc : STRING[128];
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK FB_Panel (*TODO: Bitte Kommentar hier einzufügen*)
	VAR_INPUT
		Emergency : FB_KeyLamp;
		EMCY_Button : BOOL;
		LDTRESET : FB_KeyLamp;
		LDTStop : FB_KeyLamp;
		LDTAutomatic : FB_KeyLamp;
		LDTJOG : FB_KeyLamp;
		LDTControlON : FB_KeyLamp;
		LDTControlOFF : FB_KeyLamp;
	END_VAR
	VAR_OUTPUT
		clk : FB_Clk;
		EMCY_Button_o : INT;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK FB_CONVEYOR_DATA (*TODO: Bitte Kommentar hier einzufügen*)
	VAR_INPUT
		gap : LREAL;
		pcs : INT;
		newParam2 : BOOL;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK FB_MASTERMODUL_DATA (*TODO: Bitte Kommentar hier einzufügen*)
	VAR_INPUT
		speedToCycleWebturrit : REAL;
		startSpeed : REAL;
		maxSpeed : REAL;
		periodLength : REAL;
		lenght1 : REAL;
		lenght2 : REAL;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK FB_MessageInstance (*TODO: Bitte Kommentar hier einzufügen*)
	VAR_INPUT
		active : BOOL;
		InstanceId : UDINT; (* Aggregat, Instaziertes Objekt *)
		ErrorId : UDINT;
		StationName : STRING[20];
	END_VAR
	VAR_OUTPUT
		err : FB_ErrorHdl;
		busy : BOOL;
	END_VAR
	VAR
		state : INT;
		sFormatString : STRING[29] := '';
		arrParaPointer : ARRAY[1..3] OF DINT;
		sPara1 : STRING[20];
		nPara2 : DINT;
		nPara3 : DINT; (*fbLogEvent:		ADSLOGEVENT := ( PORT:=110,
											  TMOUT := T#2s,
											  EventConfigData := ( 	Class := TCEVENTCLASS_ALARM,
																			Prio := TCEVENTPRIO_IMPLICIT,
																			ProgId := 'TcEventFormatter.TcXmlFormatter',
																			StreamType := TCEVENTSTREAM_NORMAL,
																			bQuitRequired := FALSE
																		)
											);*)
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK FB_WinderData (*TODO: Bitte Kommentar hier einzufügen*)
	VAR_INPUT
		recipeData : FB_WinderRecipeData;
		machData : FB_WinderMachData;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK FB_WinderRecipeData (*TODO: Bitte Kommentar hier einzufügen*)
	VAR_INPUT
		stopDiam : UDINT;
		warnDiam : UDINT;
		minDiamTension : UDINT; (*Mode*)
		maxDiamTension : UDINT; (*Mode*)
		mode : UDINT; (*Mode*)
		reverse : BOOL;
		dancersolPos : REAL;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK FB_WinderMachData (*TODO: Bitte Kommentar hier einzufügen*)
	VAR_INPUT
		coreDiam : UDINT;
		frictionCompensation : USINT := 0;
		velocityOverride : USINT := 0;
		GEAR_RATIO : REAL;
		axistyp : SINT; (* (-1: winder, +1: unwinder).*)
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK FB_ScalingPerimeter (*TODO: Bitte Kommentar hier einzufügen*)
	VAR_INPUT
		realperimeter : REAL; (* Umfang des Wekrzeuges *)
		NumberToolSegments : USINT; (*Anzahl der Nutzen auf dem Werkzeug/Stanzblech*)
	END_VAR
	VAR_OUTPUT
		Scaledperimeter : UDINT;
		ToolSegmentPeriod : UDINT;
	END_VAR
	VAR
		Remainder : DINT;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK FB_CUTTINGUNIT_STATUS (*TODO: Bitte Kommentar hier einzufügen*)
	VAR_INPUT
		id : UINT;
		tableid : UINT;
		name : STRING[30];
		dataOk : BOOL;
		isCalibrated : BOOL;
		isInitialized : BOOL;
		isCoupled : BOOL;
		isSynchronized : BOOL; (*	errors:					FB_CUTTINGUNIT_ERRORS;*) (*tmpData:				FB_CUTTINGUNIT_TMPDATA;*)
		errorstop : BOOL;
		extReady : BOOL := TRUE;
		mode : FB_CUTTING_MODE;
	END_VAR
	VAR_OUTPUT
		ready : BOOL;
		tmpCalibrated : BOOL;
		AxisState_status : STRING[20];
	END_VAR
	VAR_IN_OUT
		recipeMode : UDINT; (*	BYTE;*)
		axisState : MC_ReadStatus;
	END_VAR
	VAR
		CONST : FB_CONST_MASCHINE;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK FB_CUTTING_MODE (*TODO: Bitte Kommentar hier einzufügen*)
	VAR_INPUT
		value : UDINT; (*BYTE;*)
	END_VAR
	VAR_OUTPUT
		text : STRING[20];
	END_VAR
	VAR
		CONST : FB_CONST_MASCHINE;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK FB_PowerBridge (*TODO: Bitte Kommentar hier einzufügen*)
	VAR_INPUT
		bridgedownbutton : FB_CLAMP;
		withpressureSensor : BOOL;
		movebutton : FB_KeyLamp;
	END_VAR
	VAR_OUTPUT
		pressuredrvside : INT;
		pressureOperside : INT;
		button : BOOL; (*Button in der Visu*)
		valveOut : BOOL;
		pressurepresent : BOOL;
		toggle : FB_PullBreakClampToggle;
	END_VAR
	VAR_IN_OUT
		clk : FB_Clk;
	END_VAR
	VAR
		KNpressuredrvside : REAL;
		KNpressureOperside : REAL;
		pressurereference : REAL;
	END_VAR
	VAR CONSTANT
		SCALE_10V_TO_KN : REAL := (10.0/32767.0); (*10.0 V = 10 kN; 10.0 V = 32767*)
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK FB_CONST_CUTTINGUNIT_ERRORS (*TODO: Bitte Kommentar hier einzufügen*)
	VAR_OUTPUT
		REF_ERROR_UNIT_CLOSED : INT := 1;
		AXISERROR : INT := 2;
		SAFETY_SPEED : INT := 3;
		HAUBE1_VORN_OFFEN : INT := 8;
		HAUBE2_HINTEN_OFFEN : INT := 9;
		RECIPE_MODE_UNDEF : INT := 30;
		RECIPE_TOOLNR : INT := 31;
		RECIPE_SHAPE_CONFIG : INT := 32;
		CUTTER_DIAMETER : INT := 33;
		CUTTER_ZAEHNE : INT := 34;
		ANVILROLLER_ZAEHNE : INT := 35;
		ERROR_TABLE_CALC : INT := 36;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK FB_CONST_CUTTINGUNIT_TOOLS (*TODO: Bitte Kommentar hier einzufügen*)
	VAR_OUTPUT
		MIN_TOOLS : INT := 1;
		MAX_TOOLS : INT := 1000;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK FB_TurnGrWinKeysbox (*TODO: Bitte Kommentar hier einzufügen*)
	VAR_INPUT
		GridWinrightkey : FB_CLAMP;
		GridWinleftkey : FB_CLAMP;
		feederturnkey : FB_KeyLamp;
	END_VAR
	VAR_OUTPUT
		feederlimitswitch : BOOL;
		feederturn : BOOL;
		feederright : BOOL;
	END_VAR
	VAR_IN_OUT
		clk : FB_Clk;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK FB_SPLICETABLE (*TODO: Bitte Kommentar hier einzufügen*)
	VAR_INPUT
		disable : BOOL;
		clampBefore : FB_CLAMP;
		clampAfter : FB_CLAMP;
	END_VAR
	VAR_OUTPUT
		ready : BOOL;
	END_VAR
	VAR_IN_OUT
		clk : FB_Clk;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK FB_CLAMP (*TODO: Bitte Kommentar hier einzufügen*)
	VAR_INPUT
		buttonDown : FB_KeyLamp;
		buttonvisu : BOOL;
		toDown_o : BOOL;
		disable : BOOL;
	END_VAR
	VAR_IN_OUT
		clk : FB_Clk;
	END_VAR
	VAR
		visutrigg : R_TRIG;
		CONST : FB_CONST_MASCHINE;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK FB_Cylinder (*TODO: Bitte Kommentar hier einzufügen*)
	VAR_INPUT
		upVISU : BOOL;
		downVISU : BOOL;
		buttonUP : BOOL;
		buttonDown : BOOL;
		Enable : BOOL;
		up_o : BOOL;
		down_o : BOOL;
	END_VAR
	VAR_OUTPUT
		isUp : BOOL;
		isDown : BOOL;
		isdowndelayed : BOOL;
	END_VAR
	VAR
		timer : TON;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK FB_Hydraulic (*TODO: Bitte Kommentar hier einfügen*) (*$GROUP=Anwender*)
	VAR_INPUT
		enable : BOOL;
		buttonDown : BOOL;
		buttonUp : BOOL;
		limitswitch : BOOL; (* kein Endschalter für untern da nur Ventile aufgemacht werden und der Wickler drucklos bis zum Ende fährt*)
	END_VAR
	VAR_OUTPUT
		go_up : BOOL; (*go_down:		BOOL;*) (* da kein Ventil angesteuert wird nur das Ventil für hoch gelüftet wird*)
		commonValve : BOOL;
		LED_is_up : BOOL;
		LED_is_down : BOOL;
		pumpe : BOOL;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK FB_UnwinderfeederCtrl (*TODO: Bitte Kommentar hier einfügen*) (*$GROUP=Anwender*)
	VAR_INPUT
		cmd : INT;
		buttonRequestOpSide : FB_KeyLamp;
		buttonRightOpSide : FB_KeyLamp;
		buttonLeftOpSide : FB_KeyLamp;
		buttonRequestDrvSide : FB_KeyLamp;
		buttonRightDrvSide : FB_KeyLamp;
		buttonLeftDrvSide : FB_KeyLamp;
		LimitSwitchRight : BOOL;
		LimitSwitchLeft : BOOL;
		axisREF : UDINT;
		UnwFeeder_HW : SdcHwCfg_typ := (0);
		UnwFeeder_DrvIf : SdcDrvIf16_typ := (0);
		UnwFeeder_DiDoIf : SdcDiDoIf_typ := (0);
		UnwFeeder_ModuleOk : BOOL := 0;
		UnwFeederErrorAckn : BOOL;
		BasicControl : basic_typ;
	END_VAR
	VAR_OUTPUT
		feederFUleft : BOOL;
		feederFUright : BOOL;
		brakerelease : BOOL;
		ampelgelb : BOOL;
		horn : BOOL;
		MC_ReadStatus_0 : MC_ReadStatus;
		busy : BOOL;
		status : FB_ModulStatus;
	END_VAR
	VAR_IN_OUT
		machineaxis : FB_AxisCtrl;
		clk : FB_Clk;
	END_VAR
	VAR
		AxisStep : INT;
		cmdtmp : INT;
		trigOPSide : BOOL;
		trigDrvSide : BOOL;
		braketimer : BOOL;
		MC_BR_ReadDriveStatus_0 : MC_BR_ReadDriveStatus;
		firststart : BOOL := TRUE;
		State : USINT;
		CONST : FB_CONST_MASCHINE;
		MC_BR_JogVelocity_0 : MC_BR_JogVelocity;
		pAxis : REFERENCE TO ACP10AXIS_typ;
		MC_Power_0 : MC_Power;
		MC_Stop_0 : MC_Stop;
		MC_Reset_0 : MC_Reset;
		Start_timer : BOOL; (*timer_TOF : TON;*)
		timer_TON : TON;
		timerOPside_TOF : TOF; (*Scahltet den Regler ab und damit fällt die Bremse zu*)
		timerDrvside_TOF : TOF;
		timer_TP : TP;
	END_VAR
	VAR CONSTANT
		STATE_READY : INT := 0;
		STATE_POWER_ON : INT := 10;
		STATE_POWER_OFF : INT := 11;
		STATE_ERROR_RESET : INT := 12;
		STATE_QUIT : INT := 20;
		ST_WAIT : USINT := 0;
		ST_REQUEST : USINT := 10;
		ST_REQUEST_OpSide : USINT := 20;
		ST_REQUEST_DrvSide : USINT := 30;
		ST_END : USINT := 40;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK FB_DUBBLEUUNWINDERDATA (*TODO: Bitte Kommentar hier einfügen*) (*$GROUP=Anwender*)
	VAR_INPUT
		undwinderDRV : FB_WinderData; (*drive side*)
		unwinderOP : FB_WinderData; (*operator side*)
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK FB_UNWINDERUNITSTATUS (*TODO: Bitte Kommentar hier einfügen*) (*$GROUP=Anwender*)
	VAR_INPUT
		statusDrv : FB_ModulStatus;
		statusOP : FB_ModulStatus;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK FB_limitswitch (*TODO: Bitte Kommentar hier einfügen*) (*$GROUP=Anwender*)
	VAR_INPUT
		limitSWupper : BOOL;
		limitSWlower : BOOL;
		mechbrake : BOOL;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK FB_StartStopbox (*TODO: Bitte Kommentar hier einfügen*) (*$GROUP=Anwender*)
	VAR_INPUT
		start : FB_KeyLamp;
		stop : FB_KeyLamp;
		jog : FB_KeyLamp;
	END_VAR
	VAR_IN_OUT
		clk : FB_Clk;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK FB_SummeryStarStop (*TODO: Bitte Kommentar hier einfügen*) (*$GROUP=Anwender*)
	VAR_INPUT
		boxunwinder : FB_StartStopbox;
		boxwebbuffer : FB_StartStopbox;
		boxcutting1 : FB_StartStopbox;
		boxlongcutter : FB_StartStopbox;
		boxconveyor : FB_StartStopbox;
	END_VAR
	VAR_OUTPUT
		start : BOOL;
		stop : BOOL;
		jog : BOOL;
	END_VAR
	VAR_IN_OUT
		panel : FB_Panel;
		clk : FB_Clk;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK FB_WebGuiding (*TODO: Bitte Kommentar hier einfügen*) (*$GROUP=Anwender*)
	VAR_INPUT
		enable : BOOL;
		center : BOOL;
		auto : BOOL;
		hand : BOOL;
		moveRight : BOOL;
		moveLeft : BOOL;
		hardwareOK : BOOL;
	END_VAR
	VAR_OUTPUT
		manual : BOOL;
		neutral : BOOL;
		automatic : BOOL;
		centerSelect : BOOL;
		handSelect : BOOL;
		autoSelect : BOOL;
		active : BOOL;
		arrowRight : BOOL;
		arrowLeft : BOOL;
		hardwareActive : BOOL;
	END_VAR
	VAR
		TP_01 : TP;
		Start_timer : BOOL;
		handtrigg : R_TRIG;
		centertrigg : R_TRIG;
		autotrigg : R_TRIG;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK FB_SetGearRatio (*TODO: Bitte Kommentar hier einfügen*) (*$GROUP=Anwender*)
	VAR_INPUT
		UpdateRecipe : BOOL;
		setvalueVisuRecipe : REAL;
		enable : BOOL;
		step1 : BOOL;
		step10 : BOOL;
		step100 : BOOL;
		gearup : BOOL;
		gearlow : BOOL;
		Selectstep1 : BOOL;
		Selectstep10 : BOOL;
		Selectstep100 : BOOL;
		Selectenable : BOOL;
		limitvisupos : REAL;
		limitvisuneg : REAL;
		limitratiopos : INT;
		limitrationeg : INT;
		init : BOOL;
	END_VAR
	VAR_OUTPUT
		trigger : BOOL;
		ratioNumeratorOut : INT;
		ratioDenominator : UINT := 1000;
		setvalueVisu : REAL;
		stepvisu : REAL;
		ratio_inProcent_visu : REAL;
	END_VAR
	VAR
		offsetrecipe : REAL;
		trigP : R_TRIG;
		trigN : R_TRIG;
		ratio : INT := 1000;
		ratiotmp : INT;
		step : INT;
		TP_01 : TP;
		Start_timer : BOOL;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK FB_MarkPoints (*TODO: Bitte Kommentar hier einfügen*) (*$GROUP=Anwender*)
	VAR_INPUT
		MC_BR_TouchProbe_0 : MC_BR_TouchProbe;
		reset : BOOL;
		Enable : BOOL;
		TriggerInput : MC_BR_TRIGGER_REF; (*Input that is used as event source*)
		Axis : UDINT; (*Axis reference of slave*)
		SearchRM : BOOL; (*Initiate search of new RM on positive edge*)
		CutMasterPosition : DINT; (*Uncorrected next cut position [Master Units]*)
		RegMarkPosition : DINT; (*RegMark offset relative to cut position [Master Units]*)
		WindowNegative : REAL; (*Range before the expected position in which the trigger signal may occur [Master Units]*)
		WindowPositive : REAL; (*Range after the expected position in which the trigger signal may occur [Master Units]*)
		ProductLength : REAL; (*Interval between two expected trigger positions [Master Units]*)
		markpointlist : FB_Markpointarray;
	END_VAR
	VAR_OUTPUT
		RecordedValue : DINT; (*Most recent RM position [Master Units]*)
		lastrecocordedValue : DINT; (*last Position befor RM lost [Master Units]*)
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
END_FUNCTION_BLOCK

FUNCTION_BLOCK FB_CROSSCUTPAR (*TODO: Bitte Kommentar hier einfügen*) (*$GROUP=Anwender*)
	VAR_INPUT
		StartMasterVelocity : REAL; (*Master velocity at very first cut [Master Units/ s]*)
		MaxMasterVelocity : REAL; (*Maximum master velocity [Master Units/ s]*)
		Insetting : REAL; (*Insetting ratio for calculation of CutRangeMaster [%]*)
		MaxCorrection : DINT; (*Maximum correction movement per product cycle [Master Units]*)
		CutStartPos : DINT; (*Start of synchronisation within slave period [Slave Units]*)
		CutEndPos : DINT; (*End of synchronisation within slave period [Slave Units]*)
		CutRangeMaster : REAL;
		CutRangeSlave : REAL;
		ProductLength : REAL;
		CutPosition : REAL;
		StartMode : UINT;
		ProductLengthCorrection : REAL;
		MasterStartDistance : REAL;
		StartInterval : REAL;
		MinCutRangeSlave : REAL; (*Minimum synchronization distance [Slave Units]*)
		MinCompRangeSlave : REAL; (*Minimum effective compensation distance [Slave Units]*)
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK FB_GetNextCuttPos (*TODO: Bitte Kommentar hier einfügen*) (*$GROUP=Anwender*)
	VAR_INPUT
		Enable : BOOL;
		reset : BOOL;
		donecut : BOOL; (*wait until Cutter is done with a cut*)
		RecordedValue : DINT; (*Recorded RegMark position, e.g. from a MC_BR_Touchprobe instance [Master Units]*)
		RecordedValueValid : BOOL;
		CutPosition : DINT; (*Uncorrected next cut position [Master Units]*)
		DistanceToSensor : DINT; (*Distance between tool and sensor [Master Units]*)
		RegMarkPosition : DINT; (*RegMark offset relative to cut position [Master Units]*)
		ProductLength : DINT; (*Product length [Master Units]*) (*	Touchpobe: MC_BR_TouchProbe;*)
		setCutOffset : FB_SetCutOffset;
	END_VAR
	VAR_OUTPUT
		PositionError : DINT; (*Difference between corrected and uncorrected cut position [Master Units]*)
		PositionErrorValid : BOOL; (*TRUE for 1 cycle if "PositionError" is within current product cycle*)
		nextsyncpos : DINT; (* Position für die Sunchronisierung der Stanze /Querschneider*)
		newdata : UDINT;
	END_VAR
	VAR_IN_OUT
		markpoints : FB_MarkPoints;
		scalePerimeter : FB_ScalingPerimeter;
		machinemaster : FB_AxisCtrl;
	END_VAR
	VAR
		masterposMod : DINT;
		IncompensatinRtrig : R_TRIG;
		IncompensatinFtrig : F_TRIG;
		oldCutPosition : DINT;
		tmpCutPosition : DINT;
		actCutPosition : DINT;
		markposMod : DINT;
		ModDistanceToSensor : DINT;
		probecounter : UDINT;
		indx : UDINT;
		counter : UDINT;
		donecounter : UDINT;
		actmarkpos : UDINT;
		State : INT;
		CorrectedCutPosition : DINT;
		PositionErrorTemp : DINT;
	END_VAR
	VAR CONSTANT
		ST_IDLE : INT := 0;
		ST_READ_POS : INT := 1;
		ST_READ_POS_DONE : INT := 2;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK FB_SafeInputs (*TODO: Bitte Kommentar hier einfügen*) (*$GROUP=Anwender*)
	VAR_INPUT
		EMCY_Button1 : BOOL;
		EMCY_Button2 : BOOL;
		EMCY_Button3 : BOOL;
		EMCY_Button4 : BOOL;
		EMCY_Door1 : BOOL;
		EMCY_Door2 : BOOL;
		EMCY_Door3 : BOOL;
		EMCY_Door4 : BOOL;
		EMCY_Door5 : BOOL;
		EMCY_Door6 : BOOL;
		EMCY_pullwireOPs : BOOL;
		EMCY_pullwireDVRs : BOOL;
		EMCY_DoorsClosed : BOOL;
	END_VAR
	VAR_OUTPUT
		EMCY_Button1_o : INT;
		EMCY_Button2_o : INT;
		EMCY_Button3_o : INT;
		EMCY_Button4_o : INT;
		EMCY_Door1_o : INT;
		EMCY_Door2_o : INT;
		EMCY_Door3_o : INT;
		EMCY_Door4_o : INT;
		EMCY_Door5_o : INT;
		EMCY_Door6_o : INT;
		EMCY_pullwireOPs_o : INT;
		EMCY_pullwireDVRs_o : INT;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK FB_Markpointarray (*TODO: Bitte Kommentar hier einfügen*) (*$GROUP=Anwender*)
	VAR_INPUT
		rdpos : DINT; (*read position*)
		offset_posIdent : USINT;
		new_Ident : BOOL;
		reset : BOOL;
	END_VAR
	VAR_OUTPUT
		lastpos : DINT;
		actlenght : DINT;
		actpos : DINT;
		index_out : UDINT;
		valid : BOOL;
	END_VAR
	VAR
		poslist : ARRAY[0..200] OF DINT;
		points : ARRAY[0..200] OF FB_Points;
		in_posIdent : USINT;
		out_posIdent : USINT; (*	out_lastIdent:USINT;*)
		out_actIdent : USINT;
		maxposIdent : USINT;
		bufferRtrig : R_TRIG;
		visuIndex : USINT;
	END_VAR
	VAR CONSTANT
		maxVisuIndex : USINT := 17; (*Größe des angezeigten Registermarkenfeldes in der Visu *)
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK FB_SwitchCabinet (*TODO: Bitte Kommentar hier einfügen*) (*$GROUP=Anwender*)
	VAR_INPUT
		EMCY_Buttons : FB_SafeInputs;
		fusePlug1 : BOOL;
		fusePlug2 : BOOL;
		fusePlugCEE : BOOL;
		aircond : BOOL;
		fuseWebGuide1 : BOOL;
		fuseWebGuide2 : BOOL;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK FB_AxisCrtl_Home (*TODO: Bitte Kommentar hier einfügen*) (*$GROUP=Anwender*)
	VAR_INPUT
		cmd : INT;
		position : REAL;
		velocity : REAL;
		override : REAL;
		verzoegerung : REAL;
		ruck : REAL;
		AxisREF : UDINT;
		BasicControl : basic_typ;
		MC_refSwitchConfig_0 : MC_BR_SetHardwareInputs;
	END_VAR
	VAR_OUTPUT
		busy : BOOL;
		MC_BR_ReadDriveStatus_0 : MC_BR_ReadDriveStatus;
		MC_ReadStatus_0 : MC_ReadStatus;
		err : FB_ErrorHdl;
		MC_ReadActualPosition_0 : MC_ReadActualPosition;
	END_VAR
	VAR CONSTANT
		STATE_WAIT : USINT := 0; (*NOACTION*)
		STATE_POWER_ON : USINT := 1; (*START*)
		STATE_HOME : USINT := 2; (*CALIBR*)
		STATE_JOG_POSITIVE : USINT := 3;
		STATE_JOG_NEGATIVE : USINT := 4;
		STATE_IDLE : USINT := 5;
		STATE_STOP : USINT := 9;
		STATE_READY : USINT := 10;
		STATE_HALT : USINT := 12;
		STATE_MOVE_ABSOLUTE : USINT := 13;
		STATE_SETPOS : USINT := 14;
		STATE_MOVE_VELOCITY : USINT := 15;
		STATE_MOVE_ADDITIVE : USINT := 16;
		STATE_VAXIS_ON : USINT := 17;
		STATE_POWER_OFF : USINT := 18;
		STATE_QUIT : USINT := 19;
		STATE_ERROR_AXIS : USINT := 100;
		STATE_ERROR : USINT := 101;
		STATE_ERROR_RESET : USINT := 102;
	END_VAR
	VAR
		MC_Home_0 : MC_Home;
		MC_MoveAbsolute_0 : MC_MoveAbsolute;
		MC_MoveAdditive_0 : MC_MoveAdditive;
		MC_MoveVelocity_0 : MC_MoveVelocity;
		MC_Power_0 : MC_Power;
		MC_ReadActualVelocity_0 : MC_ReadActualVelocity;
		MC_ReadAxisError_0 : MC_ReadAxisError;
		MC_Reset_0 : MC_Reset;
		MC_Stop_0 : MC_Stop;
		MC_Halt_0 : MC_Halt; (*MC_GearIn_0 : MC_GearIn;*)
		AxisStep : UINT := STATE_WAIT;
		CONST : FB_CONST_MASCHINE;
		cmdtmp : INT;
		merker : BOOL;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK FB_AxisCtrl (*TODO: Bitte Kommentar hier einfügen*) (*$GROUP=Anwender*)
	VAR_INPUT
		cmd : INT;
		position : REAL;
		velocity : REAL;
		override : REAL;
		verzoegerung : REAL;
		ruck : REAL;
		AxisREF : UDINT;
		BasicControl : basic_typ;
	END_VAR
	VAR_OUTPUT
		busy : BOOL;
		MC_BR_ReadDriveStatus_0 : MC_BR_ReadDriveStatus;
		MC_ReadStatus_0 : MC_ReadStatus;
		err : FB_ErrorHdl;
		MC_ReadActualPosition_0 : MC_ReadActualPosition;
		MC_ReadActualVelocity_0 : MC_ReadActualVelocity;
	END_VAR
	VAR CONSTANT
		STATE_WAIT : USINT := 0; (*NOACTION*)
		STATE_POWER_ON : USINT := 1; (*START*)
		STATE_HOME : USINT := 2; (*CALIBR*)
		STATE_JOG_POSITIVE : USINT := 3;
		STATE_JOG_NEGATIVE : USINT := 4;
		STATE_IDLE : USINT := 5;
		STATE_STOP : USINT := 9;
		STATE_READY : USINT := 10;
		STATE_HALT : USINT := 12;
		STATE_MOVE_ABSOLUTE : USINT := 13;
		STATE_SETPOS : USINT := 14;
		STATE_MOVE_VELOCITY : USINT := 15;
		STATE_MOVE_ADDITIVE : USINT := 16;
		STATE_VAXIS_ON : USINT := 17;
		STATE_POWER_OFF : USINT := 18;
		STATE_QUIT : USINT := 19;
		STATE_ERROR_AXIS : USINT := 100;
		STATE_ERROR : USINT := 101;
		STATE_ERROR_RESET : USINT := 102;
	END_VAR
	VAR
		MC_Home_0 : MC_Home;
		MC_MoveAbsolute_0 : MC_MoveAbsolute;
		MC_MoveAdditive_0 : MC_MoveAdditive;
		MC_MoveVelocity_0 : MC_MoveVelocity;
		MC_Power_0 : MC_Power;
		MC_ReadAxisError_0 : MC_ReadAxisError;
		MC_Reset_0 : MC_Reset;
		MC_Stop_0 : MC_Stop;
		MC_Halt_0 : MC_Halt; (*MC_GearIn_0 : MC_GearIn;*)
		AxisStep : UINT := STATE_WAIT;
		CONST : FB_CONST_MASCHINE;
		cmdtmp : INT;
		merker : BOOL;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK FB_AxisCtrl_GridFeeder (*TODO: Bitte Kommentar hier einfügen*) (*$GROUP=Anwender*)
	VAR_INPUT
		cmd : INT;
		position : REAL;
		velocity : REAL;
		override : REAL;
		verzoegerung : REAL;
		ruck : REAL;
		AxisREF : UDINT;
		BasicControl : basic_typ;
	END_VAR
	VAR_OUTPUT
		busy : BOOL;
		MC_BR_ReadDriveStatus_0 : MC_BR_ReadDriveStatus;
		MC_ReadStatus_0 : MC_ReadStatus;
		err : FB_ErrorHdl;
		MC_ReadActualPosition_0 : MC_ReadActualPosition;
		MC_ReadActualVelocity_0 : MC_ReadActualVelocity;
	END_VAR
	VAR CONSTANT
		STATE_WAIT : USINT := 0; (*NOACTION*)
		STATE_POWER_ON : USINT := 1; (*START*)
		STATE_HOME : USINT := 2; (*CALIBR*)
		STATE_JOG_POSITIVE : USINT := 3;
		STATE_JOG_NEGATIVE : USINT := 4;
		STATE_IDLE : USINT := 5;
		STATE_STOP : USINT := 9;
		STATE_READY : USINT := 10;
		STATE_HALT : USINT := 12;
		STATE_MOVE_ABSOLUTE : USINT := 13;
		STATE_SETPOS : USINT := 14;
		STATE_MOVE_VELOCITY : USINT := 15;
		STATE_MOVE_ADDITIVE : USINT := 16;
		STATE_VAXIS_ON : USINT := 17;
		STATE_POWER_OFF : USINT := 18;
		STATE_QUIT : USINT := 19;
		STATE_ERROR_AXIS : USINT := 100;
		STATE_ERROR : USINT := 101;
		STATE_ERROR_RESET : USINT := 102;
	END_VAR
	VAR
		MC_Home_0 : MC_Home;
		MC_MoveAbsolute_0 : MC_MoveAbsolute;
		MC_MoveAdditive_0 : MC_MoveAdditive;
		MC_MoveVelocity_0 : MC_MoveVelocity;
		MC_Power_0 : MC_Power;
		MC_ReadAxisError_0 : MC_ReadAxisError;
		MC_Reset_0 : MC_Reset;
		MC_Stop_0 : MC_Stop;
		MC_Halt_0 : MC_Halt; (*MC_GearIn_0 : MC_GearIn;*)
		AxisStep : UINT := STATE_WAIT;
		CONST : FB_CONST_MASCHINE;
		cmdtmp : INT;
		merker : BOOL;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK FB_SetCutOffset (*TODO: Bitte Kommentar hier einfügen*) (*$GROUP=Anwender*)
	VAR_INPUT
		UpdateRecipe : BOOL;
		setvalueVisuRecipe : REAL;
		enable : BOOL;
		maxcorrection : REAL;
		step01 : BOOL;
		step1 : BOOL;
		step10 : BOOL;
		gearup : BOOL;
		gearlow : BOOL;
		Selectstep01 : BOOL;
		Selectstep1 : BOOL;
		Selectstep10 : BOOL;
		Selectenable : BOOL;
		limitvisupos : REAL;
		limitvisuneg : REAL;
	END_VAR
	VAR_OUTPUT
		setvalueVisu : REAL;
		setOffset_o : DINT := 0;
		stepvisu : REAL;
	END_VAR
	VAR
		trigP : R_TRIG;
		trigN : R_TRIG;
		ratio : REAL := 0.0;
		ratiotmp : REAL;
		step : REAL;
		TP_01 : TP;
		Start_timer : BOOL;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK FB_Points (*TODO: Bitte Kommentar hier einfügen*) (*$GROUP=Anwender*)
	VAR_INPUT
		pos : DINT;
		lenght : DINT;
		indx : DINT;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK FB_HandWheel (*TODO: Bitte Kommentar hier einfügen*) (*$GROUP=Anwender*)
	VAR_INPUT
		counterHandWheel : INT;
		limitspeed : REAL;
		actualVelocity : REAL;
		reset : BOOL;
		safetyspeedrequest : BOOL;
	END_VAR
	VAR_OUTPUT
		setVelocity : REAL;
	END_VAR
	VAR
		lastCounterValue : INT;
	END_VAR
	VAR CONSTANT
		velocityStep : REAL := 1666.67; (*0,1m Schritt*)
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK FB_Counter (*TODO: Bitte Kommentar hier einfügen*) (*$GROUP=Anwender*)
	VAR_INPUT
		triggerInput : BOOL;
		setPieces : UINT;
		reset : BOOL;
		countPlusVisu : BOOL;
		countMinusVisu : BOOL;
	END_VAR
	VAR_OUTPUT
		counter : UINT;
		counterTemp : UINT;
	END_VAR
	VAR
		R_trig : R_TRIG;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK FB_Counters (*TODO: Bitte Kommentar hier einfügen*) (*$GROUP=Anwender*)
	VAR_INPUT
		counter1 : FB_Counter;
		counter2 : FB_Counter;
		counter3 : FB_Counter;
		counter4 : FB_Counter;
		counter5 : FB_Counter;
		counter6 : FB_Counter;
		counter7 : FB_Counter;
		counter8 : FB_Counter;
		counter9 : FB_Counter;
		setPieces : UINT;
		reset : BOOL;
		visureset : BOOL;
		validpieces : UINT;
		manualButton : BOOL;
		manual : BOOL;
VisuOKButton : BOOL;
	END_VAR
	VAR_OUTPUT
		valid : BOOL;
		Nitto_Table_Full : BOOL;
RedLampOut : BOOL;
GreenLampOut : BOOL;
	END_VAR
	VAR
	zzEdge00000 : BOOL;
	zzEdge00001 : BOOL;
zzEdge00002 : BOOL;
TON_reset : TON;
TON_Nitto_Table_Full : TON;
TP_GreenLampOut : TP;
zzEdge00003 : BOOL;
	END_VAR
END_FUNCTION_BLOCK


FUNCTION_BLOCK FB_Alarms (*TODO: Bitte Kommentar hier einfügen*) (*$GROUP=Anwender*)
	VAR_INPUT
		reset : BOOL;
		alarmlist : ARRAY[0..100] OF BOOL;
	END_VAR
	VAR_OUTPUT
		stopRequest : BOOL;
	END_VAR
	VAR
		i : USINT;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK FB_CONST_ALARMS (*TODO: Bitte Kommentar hier einfügen*) (*$GROUP=Anwender*)
	VAR_OUTPUT
		EMCY_BUTTON_UNWINDER_OP_SIDE : INT := 1;
		EMCY_BUTTON_UNWINDER_DRV_SIDE : INT := 2;
		EMCY_BUTTON_BST : INT := 3;
		EMCY_BUTTON_GRIDWINDER : INT := 4;
		EMCY_BUTTON_PANEL : INT := 5;
		EMCY_BUTTON_LONGCUT_OP_SIDE : INT := 6;
		EMCY_BUTTON_LONGCUT_DRV_SIDE : INT := 7;
		EMCY_BUTTON_CONVEYOR_OP_SIDE : INT := 8;
		EMCY_BUTTON_CONVEYOR_DRV_SIDE : INT := 9;
		EMCY_BUTTON_SCHWITCHCABINET : INT := 10;
		EMCY_OUTSIDE_EXTRUDER : INT := 11;
		EMCY_BUTTON_OUTPUT : INT := 12;
		EMCY_PULLWIRE_OP_SIDE : INT := 15;
		EMCY_PULLWIRE_DRV_SIDE : INT := 16;
		EMCY_DOOR_WEBBUFFER_OP_SIDE : INT := 20;
		EMCY_DOOR_WEBBUFFER_DRV_SIDE : INT := 21;
		EMCY_FRDOOR_WEBBUF_OP_SIDE_LEFT : INT := 22;
		EMCY_FRDOOR_WEBBUF_OP_SIDE_MIDD : INT := 23;
		EMCY_FRDOOR_WEBBUF_OP_SIDE_RIGHT : INT := 24;
		EMCY_FRDOOR_WEBBUF_DRV_SIDE : INT := 25;
		EMCY_DOOR_PBS1 : INT := 26;
		EMCY_DOOR_CUT1_INFEED : INT := 27;
		EMCY_DOOR_CUT1_OUTFEED : INT := 28;
		EMCY_DOOR_LONGCUT : INT := 29;
		EMCY_DOOR_CUT2_INFEED : INT := 30;
		EMCY_DOOR_CUT2_OUTFEED : INT := 31;
		SAFETY_ERROR : INT := 35;
		SAFETY_SPEED : INT := 36;
		MASTER_NOTREADY : INT := 37;
		FUSE_PLUG1 : INT := 40;
		FUSE_PLUG2 : INT := 41;
		FUSE_CEE_PLUG : INT := 42;
		FUSE_WEB_GUIDE_CONTROL_1 : INT := 43;
		WEB_GUIDE_CONTROL_OK_1 : INT := 44;
		FUSE_WEB_GUIDE_CONTROL_2 : INT := 45;
		WEB_GUIDE_CONTROL_OK_2 : INT := 46;
		FUSE_AIR_CONDITIONING : INT := 47;
		AIR : INT := 48;
		UNWINDER_OP_SIDE_DIAMETER_WARN : INT := 50;
		UNWINDER_OP_SIDE_DIAMETER_STOP : INT := 51;
		UNWINDER_OP_SIDE_CLAMP : INT := 52;
		UNWINDER_DRV_SIDE_DIAMETER_WARN : INT := 55;
		UNWINDER_DRV_SIDE_DIAMETER_STOP : INT := 56;
		UNWINDER_DRV_SIDE_CLAMP : INT := 57;
		WEBBUFFER_CLAMP_INFEED : INT := 60;
		WEBBUFFER_EMPTY : INT := 61;
		WEBBUFFER_NOT_REFERENCED : INT := 62;
		SPLICE_TABLE_CLAMP_INFEED : INT := 65;
		SPLICE_TABLE_CLAMP_OUTFEED : INT := 66;
		CUT1_DRIVE_SAFETY : INT := 70;
		CUT1_NOT_REFERENCED : INT := 71;
		GRID_TURN_FEEDER_DRIVE_SAFETY : INT := 75;
		GRID_WINDDER_LEFT_DIAMETER_WARN : INT := 76;
		GRID_WINDDER_LEFT_DIAMETER_STOP : INT := 77;
		GRID_WINDDER_RIGHT_DIAMETER_WARN : INT := 78;
		GRID_WINDDER_RIGHT_DIAMETER_STOP : INT := 79;
		GRID_TURN_FEEDER_NOT_REFERENCED : INT := 80;
		LONGCUT_CLAMP : INT := 85;
		LONGCUT_DRIVE_SAFETY : INT := 86;
		LONGCUT_AXISERRORSTOP : INT := 87;
		LONGCUT_NOT_COUPLED : INT := 88;
		CUT2_DRIVE_SAFETY : INT := 90;
		CUT2_NOT_REFERENCED : INT := 91;
		RECIPEDATA_NOT_LOADED : INT := 95;
		RECIPEDATA_REQUEST_TIMEOUT : INT := 96;
		RECIPEDATA_ERROR : INT := 97;
		PULLBELT_IS_NOT_BELOW : INT := 99;
		CATCHBELT_NOT_COUPLED : INT := 100;
		CONVEYOR_NOT_COUPLED : INT := 101;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK FB_KeysWebbuffer (*TODO: Bitte Kommentar hier einfügen*) (*$GROUP=Anwender*)
	VAR_INPUT
		up : FB_KeyLamp;
		down : FB_KeyLamp;
		home : FB_KeyLamp;
	END_VAR
	VAR_IN_OUT
		clk : FB_Clk;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK FB_MachineSpeed (*TODO: Bitte Kommentar hier einfügen*) (*$GROUP=Anwender*)
	VAR_INPUT
		dancepos : INT;
		setDancerpos : REAL;
		ConveyerVelocity : INT; (*Geschw des HAuptbandes vom Extruders*)
		limitspeed : REAL; (*Limit für den Offset der tatsächlichen Geschw.*)
		reset : BOOL;
		maxMainVelocity : REAL; (*maximale Geschw. der Wert hängt von der Geschw. des Transportbandes bzw. des Extruders Einheit m/min*)
	END_VAR
	VAR_OUTPUT
		setVelocity : REAL;
	END_VAR
	VAR
		rDancepos : REAL;
		velocityramp : LCRRamp;
		TP_01 : TP;
		rtrig : R_TRIG;
		Start_timer : BOOL;
		lowPass : LCRPT1;
		lowPassSpeed : LCRPT1;
		test : INT;
		velocityOffset : REAL;
		inc_to_volt : REAL;
		volt_to_speed : REAL;
		tempvalue : REAL;
	END_VAR
	VAR CONSTANT
		velocityStep : REAL := 166.67; (*0,01m Schritt*)
		highlimitDancerpos : REAL := 400; (*oberste POsition*)
		lowlimitDancerpos : REAL := 830; (*unterste Position des Tänzers*)
		SCALE_INC_TO_V : REAL := (10.0/32767.0); (*(1000.0/32767.0); (*10.0 V = 1000 mm; 10.0 V = 32767*)
		SCALE_10V_TO_MM : REAL := (1000.0/32767.0);
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK FB_AxisState (*TODO: Bitte Kommentar hier einfügen*) (*$GROUP=Anwender*)
	VAR_INPUT
		newParam : BOOL;
	END_VAR
	VAR_IN_OUT
		readstatus : MC_ReadStatus;
	END_VAR
	VAR
		stati : ARRAY[0..10] OF BOOL;
		CONST : FB_CONST_AXIS_STATE;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK FB_CONST_AXIS_STATE (*TODO: Bitte Kommentar hier einfügen*) (*$GROUP=Anwender*)
	VAR_OUTPUT
		Error : INT := 1;
		Errorstop : INT := 2;
		Disabled : INT := 3;
		Stopping : INT := 4;
		StandStill : INT := 5;
		DiscreteMotion : INT := 6;
		ContinuousMotion : INT := 7;
		SynchronizedMotion : INT := 8;
		Homing : INT := 9;
		texts : ARRAY[1..9] OF STRING[20] := ['Error','Errorstop','Disabled','Stopping','StandStill','DiscreteMotion','ContinuousMotion','SynchronizedMotion','Homing'];
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK FB_SprayCtrl (*TODO: Bitte Kommentar hier einfügen*) (*$GROUP=Anwender*)
	VAR_INPUT
		valveout : BOOL;
		length1 : REAL;
		length2 : REAL;
	END_VAR
	VAR_OUTPUT
	END_VAR
	VAR_IN_OUT
		machineaxis : FB_AxisCtrl;
	END_VAR
	VAR
		rtrig : R_TRIG;
		timer_tof : TOF;
		merker : BOOL;
		time1_real : REAL;
		time2_real : REAL;
		time_tof : TIME;
		time2 : TP;
		time1 : TP;
		pulse : USINT := 1;
		F_TRIG_2 : F_TRIG;
		F_TRIG_1 : F_TRIG;
		R_TRIG_0 : R_TRIG;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK FB_Liftcrtl (*TODO: Bitte Kommentar hier einfügen*) (*$GROUP=Anwender*)
	VAR_INPUT
		buttomToggle : FB_KeyLamp;
		buttomToggle2 : FB_KeyLamp;
		limiterSwitchDrvSide : BOOL;
		limiterSwitchOpSide : BOOL;
		isup : BOOL;
		isdown : BOOL;
		enable : BOOL;
		init : BOOL;
		onewayini : BOOL;
	END_VAR
	VAR_OUTPUT
		toUp_o : BOOL;
		toDown_o : BOOL;
		limiterBackward_o : BOOL;
		limiterForward_o : BOOL;
	END_VAR
	VAR_IN_OUT
		clk : FB_Clk;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK FB_AxisCtrl_new (*TODO: Bitte Kommentar hier einfügen*) (*$GROUP=Anwender*)
	VAR_INPUT
		Cmd : INT;
		Position : REAL;
		Velocity : REAL;
		Acceleration : REAL;
		Deceleration : REAL;
		Jerk : REAL;
		Override : REAL;
		AxisREF : UDINT;
		BasicControl : basic_typ;
	END_VAR
	VAR_OUTPUT
		busy : BOOL;
		MC_BR_ReadDriveStatus_0 : MC_BR_ReadDriveStatus;
		MC_ReadStatus_0 : MC_ReadStatus;
		err : FB_ErrorHdl;
		MC_ReadActualPosition_0 : MC_ReadActualPosition;
		MC_ReadActualVelocity_0 : MC_ReadActualVelocity;
	END_VAR
	VAR CONSTANT
		STATE_WAIT : USINT := 0; (*NOACTION*)
		STATE_POWER_ON : USINT := 1; (*START*)
		STATE_HOME : USINT := 2; (*CALIBR*)
		STATE_JOG_POSITIVE : USINT := 3;
		STATE_JOG_NEGATIVE : USINT := 4;
		STATE_IDLE : USINT := 5;
		STATE_STOP : USINT := 9;
		STATE_READY : USINT := 10;
		STATE_HALT : USINT := 12;
		STATE_MOVE_ABSOLUTE : USINT := 13;
		STATE_SETPOS : USINT := 14;
		STATE_MOVE_VELOCITY : USINT := 15;
		STATE_MOVE_CYCLIC_VELOCITY : USINT := 20;
		STATE_MOVE_ADDITIVE : USINT := 16;
		STATE_VAXIS_ON : USINT := 17;
		STATE_POWER_OFF : USINT := 18;
		STATE_MOVE_ADDITIVELIMIT : USINT := 19;
		STATE_QUIT : USINT := 98;
		STATE_ERROR_AXIS : USINT := 100;
		STATE_ERROR : USINT := 99;
		STATE_ERROR_RESET : USINT := 102;
	END_VAR
	VAR
		MC_Home_0 : MC_Home;
		MC_BR_CyclicWrite_0 : MC_BR_CyclicWrite;
		CyclicVelocity : REAL;
		MC_MoveAbsolute_0 : MC_MoveAbsolute;
		MC_MoveAdditive_0 : MC_MoveAdditive;
		MC_MoveVelocity_0 : MC_MoveVelocity;
		MC_BR_JogVelocity_0 : MC_BR_JogVelocity;
		MC_BR_JogLimitPosition_0 : MC_BR_JogLimitPosition;
		MC_Power_0 : MC_Power;
		MC_ReadAxisError_0 : MC_ReadAxisError;
		MC_Reset_0 : MC_Reset;
		MC_Stop_0 : MC_Stop;
		MC_Halt_0 : MC_Halt;
		velocityTmp : REAL;
		AxisStep : UINT := STATE_WAIT;
		CONST : FB_CONST_MASCHINE;
		cmdtmp : INT;
		merker : BOOL;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK FB_PACKBELT_DATA (*TODO: Bitte Kommentar hier einfügen*) (*$GROUP=Anwender*)
	VAR_INPUT
		acceleration : REAL;
		deceleration : REAL;
		lowSpeed : REAL;
		highSpeed : REAL;
	END_VAR
END_FUNCTION_BLOCK
