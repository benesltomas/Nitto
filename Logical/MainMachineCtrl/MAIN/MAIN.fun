(********************************************************************
 * COPYRIGHT -- Microsoft
 ********************************************************************
 * Programm: MAIN
 * Datei: MAIN.fun
 * Autor: Awalz
 * Erstellt: 26. März 2014
 ********************************************************************
 * Funktionen und Funktionsblöcke des Programmes MAIN
 ********************************************************************)

FUNCTION_BLOCK FB_Machine (* Beinhaltet aller Baugrupen  der Maschine*)
	VAR_INPUT
		ctrl : FB_MachineCtrl;
		masterModul : FB_MASTERMODUL;
		UnwinderUnit : FB_UNWINDERUNIT;
		webbuffer : FB_WEBBUFFER;
		pullbreak : FB_PULLBREAKUNIT;
		cuttingunit1 : FB_CuttingUnit;
		turngridwinder : FB_TurnGridWinderUnit;
		longcutter : FB_LONGCUTTER; (*FB_CONVEYOR;*)
		cuttingunit2 : FB_CuttingUnit;
		pullbreakSt : FB_PULLBREAKUNIT; (*ZUgeinheit hängt an der Stanze dran*)
		catchbelt : FB_CONVEYOR;
		conveyor : FB_CONVEYOR;
		webguidingbuffer : FB_WebGuiding;
		webguiding : FB_WebGuiding;
		emcy_inputs : FB_SafeInputs; (*	winder : FB_Winder;*)
		IOs : FB_MachineIOs;
		panel : FB_Panel;
		safety : FB_Safety;
		switchcabinet : FB_SwitchCabinet;
		gVarMachine : FB_GlobalMachineVar;
		summerystartstop : FB_SummeryStarStop;
		packbelt : FB_PackBelt;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK FB_MachineCtrl (*TODO: Bitte Kommentar hier einzufügen*)
	VAR_INPUT
		alarms : FB_Alarms;
	END_VAR
	VAR_OUTPUT
		err : FB_ErrorHdl;
		hydraulicPump : BOOL;
		valveterminal : USINT;
		valveterminal2 : USINT;
		valveterminal22 : USINT;
		valveterminal23 : USINT;
		mode : FB_MachineSetModeCtrl;
		tasktimerPos : BOOL;
		tasktimerNeg : BOOL;
	END_VAR
	VAR_IN_OUT
		masterModul : FB_MASTERMODUL;
		UnwinderUnit : FB_UNWINDERUNIT; (*FB_MAINUNWINDER;*)
		webbuffer : FB_WEBBUFFER;
		pullbreak : FB_PULLBREAKUNIT;
		cuttingunit1 : FB_CuttingUnit;
		turngridwinder : FB_TurnGridWinderUnit;
		longcutter : FB_LONGCUTTER; (*FB_CONVEYOR;*)
		cuttingunit2 : FB_CuttingUnit;
		pullbreakSt : FB_PULLBREAKUNIT;
		catchbelt : FB_CONVEYOR;
		conveyor : FB_CONVEYOR;
		webguiding : FB_WebGuiding;
		webguidingbuffer : FB_WebGuiding; (*winder : FB_Winder;*)
		IOs : FB_MachineIOs;
		panel : FB_Panel;
		safety : FB_Safety;
		switchcabinet : FB_SwitchCabinet;
		emcy_inputs : FB_SafeInputs;
		gVarMachine : FB_GlobalMachineVar;
		summerystartstop : FB_SummeryStarStop;
		packbelt : FB_PackBelt;
	END_VAR
	VAR
		webclamptrig : R_TRIG;
		webclamprClose : R_TRIG;
		CONST : FB_CONST_MASCHINE; (*mode : FB_MachineSetModeCtrl;*)
		state : INT;
		tmpMode : INT;
		busy : BOOL;
		bufferbrake_open : BOOL;
		unwinderOFFrtrig : R_TRIG;
		hornRtrig : R_TRIG;
		R_TRIG_Automatic : R_TRIG;
		hornFtrig : F_TRIG;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK FB_UNWINDERUNIT (*TODO: Bitte Kommentar hier einfügen*) (*$GROUP=Anwender*)
	VAR_INPUT
		ctrl : FB_MainUnwinderCtrl;
		unwinderOp : FB_UNWINDER; (*Operator side*)
		unwinderDrv : FB_UNWINDER; (* Drive side*)
		feederCtrl : FB_UnwinderfeederCtrl; (* Getriebemotor mit FU*)
		splicetable : FB_SPLICETABLE; (*zweiter Schneidtisch*)
		clamp : FB_CLAMP; (*SchneidtischHälfte an der Maschine*)
		emcy_inputs : FB_SafeInputs;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK FB_MainUnwinderCtrl (*TODO: Bitte Kommentar  CTRL_FIRST_START hier einzufügen*)
	VAR_INPUT
		BetrCtrl : FB_MACHINE_MODE; (* wird in FB FB_MachineSetMode gesezt*)
		buffertofull : BOOL; (* wird von der Visu gesetzt*)
	END_VAR
	VAR_OUTPUT
		BetrStatus : FB_MACHINE_MODE;
		err : FB_ErrorHdl;
		busy : BOOL;
		diameterStop : BOOL;
		diameterWarning : BOOL;
		valveterminal : USINT;
	END_VAR
	VAR_IN_OUT
		machineaxis : FB_AxisCtrl;
		unwinderOp : FB_UNWINDER; (*Operator side*)
		unwinderDrv : FB_UNWINDER; (* Drive side*)
		webbuffer : FB_WEBBUFFER;
		clamp : FB_CLAMP;
		splicetable : FB_SPLICETABLE;
		emcy_inputs : FB_SafeInputs;
		feederCtrl : FB_UnwinderfeederCtrl;
		clk : FB_Clk;
		panel : FB_Panel;
		IOs : FB_MachineIOs;
	END_VAR
	VAR
		testpos : REAL;
		feederstatus : FB_ModulStatus;
		CONST : FB_CONST_MASCHINE;
		StateCtrl : INT;
		state : INT := ST_IDLE;
		firstStart : BOOL;
	END_VAR
	VAR CONSTANT
		ST_IDLE : INT := 0;
		ST_AXIS_STOP : INT := 4;
		ST_AXIS_RUN : INT := 6;
		ST_AXIS_OFF : INT := 8;
		ST_AXIS_ON : INT := 10;
		ST_AXIS_ON_DIS : INT := 12;
		ST_QUIT : INT := 14;
	END_VAR
	VAR
		unwinderOP : ACP10SMCCFGIN_typ;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK FB_UNWINDER (*TODO: Daten FB  	ctrl: 		FB_MainUnwinderCtrl; für Abwickler *)
	VAR_INPUT
		ctrl : FB_UnwinderCtrl; (*FB_MainUnwinderCtrl;*)
		unwinderaxis : FB_WinderAxis; (*	FB_UnwinderAxis;*)
		data : FB_WinderData;
		status : FB_ModulStatus;
		clamp : FB_CLAMP;
		lift : FB_Hydraulic; (*FB_Cylinder;*)
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK FB_UnwinderCtrl (*TODO: Bitte Kommentar hier einfügen*) (*$GROUP=Anwender*)
	VAR_INPUT
		BetrCtrl : FB_MACHINE_MODE;
		buffertofull : BOOL;
	END_VAR
	VAR_OUTPUT
		BetrStatus : FB_MACHINE_MODE;
		err : FB_ErrorHdl;
		busy : BOOL;
		diameterStop : BOOL;
		diameterWarning : BOOL;
	END_VAR
	VAR_IN_OUT
		machineaxis : FB_AxisCtrl;
		unwinderaxis : FB_WinderAxis; (*FB_UnwinderAxis;*)
		webbuffer : FB_WEBBUFFER; (* in der zweiten Übergabe schein in AS nicht zu funktionieren *)
		data : FB_WinderData;
		status : FB_ModulStatus; (*dancer : 		FB_Dancer;*)
		IOs : FB_MachineIOs;
		clamp : FB_CLAMP; (*splicetable : FB_SPLICETABLE;*)
		panel : FB_Panel;
		lift : FB_Hydraulic; (*FB_Cylinder;*)
		clk : FB_Clk;
	END_VAR
	VAR
		testpos : REAL;
		CONST : FB_CONST_MASCHINE;
		StateCtrl : INT;
		state : INT := ST_IDLE;
		buffertofullRtrig : R_TRIG;
		firstStart : BOOL;
		timer : TON;
		supplydelay : TON;
		cmdtmp : INT;
		cmd : INT := 99;
	END_VAR
	VAR CONSTANT
		ST_IDLE : INT := 0;
		ST_AXIS_STOP : INT := 4;
		ST_AXIS_RUN : INT := 6;
		ST_AXIS_OFF : INT := 8;
		ST_AXIS_ON : INT := 10;
		ST_AXIS_ON_DIS : INT := 12;
		ST_ERROR : INT := 98;
		ST_QUIT : INT := 99;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK FB_UnwinderAxis (*TODO: hier wird der Betriebmodus umgeschalten*)
	VAR_INPUT
		cmd : INT;
		position : REAL;
		velocity : REAL;
		override : REAL;
		verzoegerung : REAL;
		ruck : REAL;
		AxisREF : UDINT; (*ACP10AXIS : ACP10AXIS_typ;*)
		BasicControl : basic_typ;
	END_VAR
	VAR_OUTPUT
		MC_BR_ReadDriveStatus_0 : MC_BR_ReadDriveStatus;
		WNCCalcDiam_Unwinder : WNCCalcDiam;
		MC_BR_VelocityControl_Unwinder : MC_BR_VelocityControl;
		BetrStatus : FB_MACHINE_MODE;
		MC_ReadStatus_0 : MC_ReadStatus;
		err : FB_ErrorHdl;
		busy : BOOL;
	END_VAR
	VAR_IN_OUT
		machineaxis : FB_AxisCtrl;
		data : FB_WinderData;
		status : FB_ModulStatus;
	END_VAR
	VAR
		CONST : FB_CONST_MASCHINE;
		LCRLimit_0 : LCRLimit;
		AutoModeActive : BOOL;
		masteraxisREF : REFERENCE TO ACP10AXIS_typ;
		WNCProcessCtrl_Unwinder : WNCProcessCtrl;
		WNCCalcFFCtrl_Unwinder : WNCCalcFFCtrl; (*WNCCalcDiam_Unwinder : WNCCalcDiam;*)
		WNCLipSctrlPara_Unwinder : WNCLipSctrlPara;
		UnwinderEstPara : wnc_estPara_typ;
		UnwinderSysPara : wnc_sysPara_typ;
		UnwinderPidPara : wnc_pidPara_typ;
		vecTN : ARRAY[0..4] OF REAL;
		vecKV : ARRAY[0..4] OF REAL;
		vecD : ARRAY[0..4] OF REAL;
		Enable_Rtrig : R_TRIG;
		MC_Power_0 : MC_Power;
		MC_ReadActualPosition_0 : MC_ReadActualPosition;
		MC_Reset_0 : MC_Reset;
		MC_Stop_0 : MC_Stop;
		DriveStatus : MC_DRIVESTATUS_TYP;
		firststart : BOOL := TRUE;
		pAxis : REFERENCE TO ACP10AXIS_typ;
		AxisStep : USINT;
		cmdtmp : INT;
	END_VAR
	VAR CONSTANT
		STATE_WAIT : USINT := 0; (*NOACTION*)
		STATE_POWER_ON : USINT := 1; (*START*)
		STATE_HOME : USINT := 2; (*CALIBR*)
		STATE_JOG_POSITIVE : USINT := 3;
		STATE_JOG_NEGATIVE : USINT := 4;
		STATE_IDLE : USINT := 5;
		STATE_STOP : USINT := 9;
		STATE_READY : USINT := 0;
		STATE_HALT : USINT := 12;
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
END_FUNCTION_BLOCK

FUNCTION_BLOCK FB_Dancer (*TODO: Bitte Kommentar hier einzufügen*)
	VAR_INPUT
		Mastervelocity : REAL;
		Pos : INT; (* EINGANG POS Sesor*)
		DMS_In : DINT; (* EINGANG DMS KLEMME*)
		forcefactor : REAL;
		setTension : REAL; (* DATAinput*)
	END_VAR
	VAR_OUTPUT
		pos_out : REAL;
		visuOut : REAL;
		tension_output : INT; (* Ausgang für den Propventil um eine Bahnspannung zu erzeugen*)
		tension_scaled : REAL;
		State : BOOL;
		FlengeDMS : USINT;
	END_VAR
	VAR
		Start_dancer : BOOL;
		offset : REAL := -197900.0; (*Eigengewicht der Messwalze wird ermittelt wenn die Walze im zuglosen Zustand ist*)
	END_VAR
	VAR CONSTANT
		CFG_FLENGE_DMS_AIN : USINT := 0; (*Binary 1010 for 1000 samples per second*)
		SCALE_INT_TO_200MM : REAL := (200/32767.0); (*10.0 V = 200 mm; 10.0 V = 32767 Poti Arbeitsbereich ist 200mm*)
		SCALE_100N_TO_INT : REAL := (100.0 /32767.0); (* 10.V = 100N; 10.0 V = 32767*)
		SCALE_DINT_TO_400N : REAL := (400.0/978356.0); (*400N ist der Messbereich (pro Sensor 200N) 2^19,9 ist die Auflösung*)
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK FB_MASTERMODUL (*TODO: Bitte Kommentar hier einzufügen*)
	VAR_INPUT
		ctrl : FB_MasterModulCtrl;
		axis : FB_AxisCtrl;
		data : FB_MASTERMODUL_DATA; (*rcp_prog_general_typ;*) (*	summerystartstop : FB_SummeryStarStop;*)
		status : FB_ModulStatus;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK FB_MasterModulCtrl (*TODO: Bitte Kommentar hier einzufügen*)
	VAR_INPUT
		BetrCtrl : FB_MACHINE_MODE;
		gMachine : Machine_Type;
		handWheel : FB_HandWheel;
		inlineVelocity : FB_SpeedCtlrPid; (*FB_MachineSpeed;*)
		inline : BOOL;
		mainconvoyerrun : BOOL;
	END_VAR
	VAR_OUTPUT
		BetrStatus : FB_MACHINE_MODE;
		unitsStatus : FB_UnitsStatus;
		err : FB_ErrorHdl;
		alarms : FB_Alarms;
		sprayCtrl : FB_SprayCtrl;
	END_VAR
	VAR_IN_OUT
		axis : FB_AxisCtrl;
		UnwinderUnit : FB_UNWINDERUNIT;
		webbuffer : FB_WEBBUFFER;
		pullbreak : FB_PULLBREAKUNIT;
		cuttingunit1 : FB_CuttingUnit;
		turngridwinder : FB_TurnGridWinderUnit;
		longcutter : FB_LONGCUTTER;
		cuttingunit2 : FB_CuttingUnit;
		pullbreakSt : FB_PULLBREAKUNIT;
		catchbelt : FB_CONVEYOR;
		conveyor : FB_CONVEYOR;
		summerystartstop : FB_SummeryStarStop;
		data : FB_MASTERMODUL_DATA;
		IOs : FB_MachineIOs;
		panel : FB_Panel;
		emcy_inputs : FB_SafeInputs;
		switchcabinet : FB_SwitchCabinet;
		safety : FB_Safety;
		webguidingbuffer : FB_WebGuiding;
		webguiding : FB_WebGuiding;
		packbelt : FB_PackBelt;
	END_VAR
	VAR CONSTANT
		ST_IDLE : INT := 0;
		ST_AXIS_RUN : INT := 2;
		ST_AXIS_RUN_SLOW : INT := 4;
		ST_AXIS_RUN_FAST : INT := 6;
		ST_AXIS_VELO_CHANGE : INT := 8;
		ST_AXIS_RUN_SLOW_CUT1 : INT := 10;
		ST_AXIS_RUN_SLOW_CUT2 : INT := 12;
		ST_AXIS_RUN_SLOW_PB1 : INT := 14;
		ST_AXIS_STOP : INT := 18;
		ST_AXIS_UNWINDER_STOP : INT := 70;
		ST_AXIS_DURCHMSTOP : INT := 72;
		ST_RESET_WAIT : INT := 80;
		ST_BAHN_END : INT := 85;
		ST_ERROR : INT := 98;
		ST_QUIT : INT := 99;
		STARTVELO : LREAL := 3000;
	END_VAR
	VAR
		CONST : FB_CONST_MASCHINE;
		StateCtrl : INT;
		state : INT;
		busy : BOOL;
		mastervelocity : REAL;
		errorDiameterStop : FB_MessageInstance;
		errorclampingback : FB_MessageInstance;
		errorclampingfront : FB_MessageInstance;
		errorUnwinderNotUp : FB_MessageInstance;
		buttonSprayVisu : BOOL;
	END_VAR
END_FUNCTION_BLOCK
(*	handWheel :FB_HandWheel;*)

FUNCTION_BLOCK FB_PULLBREAKUNIT (*TODO: Bitte Kommentar hier einzufügen*)
	VAR_INPUT
		ctrl : FB_PullbreakUnitCtrl;
		axis : FB_PULLBREAK_AXIS; (*FB_AxisCtrl;*)
		clamp : FB_CLAMP;
		hubctrl : FB_Liftcrtl; (*FB_PullBreakClampToggle;*)
		safety : FB_Safety;
		emcy_inputs : FB_SafeInputs;
		status : FB_ModulStatus;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK FB_PULLBREAK_AXIS (*TODO: Bitte Kommentar hier einzufügen*)
	VAR_INPUT
		ctrl : FB_AxisCtrl;
		cplOn : MC_GearIn;
		cplOff : MC_GearOut;
		Offset_TM : MC_BR_Offset;
		setGearRatio : FB_SetGearRatio;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK FB_PullbreakUnitCtrl (*TODO: Bitte Kommentar hier einzufügen*)
	VAR_INPUT
		BetrCtrl : FB_MACHINE_MODE;
		cmdCtrl : FB_CUTTINGUNIT_CMD;
		mode : UDINT; (*BYTE;*)
		tensioncontol : LREAL;
		NewData : BOOL;
	END_VAR
	VAR_OUTPUT
		BetrStatus : FB_MACHINE_MODE;
		cmdStatus : FB_CUTTINGUNIT_CMD;
		err : FB_ErrorHdl;
		busy : BOOL;
	END_VAR
	VAR_IN_OUT
		machineMaster : FB_AxisCtrl;
		axis : FB_PULLBREAK_AXIS; (*FB_AxisCtrl;*)
		status : FB_ModulStatus;
		clamp : FB_CLAMP; (* FB_PullBreakClampToggle;*)
		hubctrl : FB_Liftcrtl; (*FB_PullBreakClampToggle;*)
		emcy_inputs : FB_SafeInputs;
		panel : FB_Panel;
		safety : FB_Safety;
		clk : FB_Clk;
	END_VAR
	VAR
		CONST : FB_CONST_MASCHINE;
		config : FB_PullBreakUnitConfig;
		chkStatus : FB_UnitChkStatus;
		state : INT;
		timer : TON;
		supplydelay : TON;
		StateCtrl : INT := ST_IDLE; (*:= CTRL_FIRST_START*)
		manualFirst : BOOL;
	END_VAR
	VAR CONSTANT
		ST_IDLE : INT := 0;
		ST_CPL_WAIT : INT := 1;
		ST_FUNCTION_START : INT := 10;
		ST_FUNCTION : INT := 12;
		ST_FUNCTION_QUIT : INT := 14;
		ST_MOVE_START : INT := 20;
		ST_MOVE : INT := 22;
		ST_MOVE_QUIT : INT := 24;
		ST_ERROR : INT := 98;
		ST_QUIT : INT := 99;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK FB_PullBreakUnitConfig (*TODO: Bitte Kommentar hier einzufügen*)
	VAR_INPUT
		cmd : INT;
	END_VAR
	VAR_OUTPUT
		busy : BOOL;
		err : FB_ErrorHdl;
	END_VAR
	VAR_IN_OUT
		machineMasterCtrl : FB_AxisCtrl; (*FB_MASTERMODUL_AXIS *)
		axis : FB_PULLBREAK_AXIS;
		status : FB_ModulStatus;
	END_VAR
	VAR
		CONST : FB_CONST_MASCHINE;
		state : INT := ST_IDLE;
		cmdtmp : INT;
	END_VAR
	VAR CONSTANT
		ST_IDLE : INT := 0;
		ST_CPL_START : INT := 30;
		ST_CPL_WAIT : INT := 31;
		ST_CPLOFF_START : INT := 32;
		ST_CPLOFF_WAIT : INT := 33;
		ST_MOVE_START : INT := 40;
		ST_MOVE_WAIT : INT := 41;
		ST_MOVE_QUIT : INT := 42;
		ST_ABORT : INT := 90;
		ST_ABORT_QUIT : INT := 91;
		ST_ERROR : INT := 96;
		ST_QUIT : INT := 99;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK FB_MachineSetModeCtrl (*TODO: Bitte Kommentar hier einzufügen*)
	VAR_INPUT
		gVisu : Visu_Type;
		status : FB_MACHINE_MODE;
	END_VAR
	VAR_OUTPUT
		ctrl : FB_MACHINE_MODE;
		visuLocking : INT := 0;
	END_VAR
	VAR_IN_OUT
		safety : FB_Safety;
		IOs : FB_MachineIOs;
		panel : FB_Panel;
		summerystartstop : FB_SummeryStarStop;
		masterModul : FB_MASTERMODUL;
	END_VAR
	VAR
		CONST : FB_CONST_MASCHINE;
		state : INT;
		timer : TP;
		R_TRIG : R_TRIG;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK FB_MachineIOs (*TODO: Bitte Kommentar hier einzufügen*)
	VAR_INPUT
		ampel : FB_Ampel;
		CtrlPowerEmcyDel : DiDo_Type;
		CtrlPowerEmcyUndel : DiDo_Type;
		inline : BOOL;
		controlOn : BOOL;
		ValveAirON : BOOL;
		antistatik : BOOL;
		hydraulicPump : BOOL;
		aIn : MachineIoAi_Type;
		CEEPlugON : BOOL;
		machineReady : BOOL;
		Nitto_Table : BOOL;
		Unwinder_OP_Led : BOOL;
		Unwinder_Drv_Led : BOOL;
		Unwinder_OP_Button : BOOL;
		Unwinder_Drv_Button : BOOL;
	END_VAR
	VAR_OUTPUT
		CEEPlug_o : BOOL;
	END_VAR
	VAR_IN_OUT
		panel : FB_Panel;
	END_VAR
END_FUNCTION_BLOCK
(*dIn : MachineIoDi_Type;
		dOut : MachineIoDo_Type;
		aOut : MachineIoAo_Type;*)

FUNCTION_BLOCK FB_MACHINE_MODE (*TODO: Bitte Kommentar hier einzufügen*)
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

FUNCTION_BLOCK FB_UnitsStatus (*TODO: Bitte Kommentar hier einzufügen*)
	VAR_OUTPUT
		ready : BOOL;
		diameterStop : BOOL;
		diameterwarning : BOOL;
		clampingfront : BOOL; (* Clamp Tables by Unwinding *)
		clampingback : BOOL;
		clampingsplicetable : BOOL;
	END_VAR
	VAR_IN_OUT
		UnwinderUnit : FB_UNWINDERUNIT;
		pullbreak : FB_PULLBREAKUNIT;
		pullbreakSt : FB_PULLBREAKUNIT;
		longcutter : FB_LONGCUTTER;
		cuttingunit1 : FB_CuttingUnit;
		cuttingunit2 : FB_CuttingUnit;
		conveyor : FB_CONVEYOR;
		catchbelt : FB_CONVEYOR;
		webbuffer : FB_WEBBUFFER;
		turngridwinder : FB_TurnGridWinderUnit;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK FB_LONGCUTTER (*TODO: Bitte Kommentar hier einfügen*)
	VAR_INPUT
		ctrl : FB_LongcutterCtrl; (* FB_ConveyorCtrl;*)
		axis : FB_CONVEYOR_AXIS;
		data : FB_CONVEYOR_DATA;
		cutterUp : FB_PullBreakClampToggle; (*nur für den Längsschneider*)
		discmovesupp : FB_CLAMP;
		webclamp : FB_CLAMP;
		movebutton : FB_KeyLamp;
		emcy_inputs : FB_SafeInputs;
		status : FB_ModulStatus;
		safety : FB_Safety;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK FB_LongcutterCtrl (*TODO: Bitte Kommentar hier einfügen*)
	VAR_INPUT
		BetrCtrl : FB_MACHINE_MODE;
		cmdCtrl : FB_CUTTINGUNIT_CMD;
		mode : UDINT; (*BYTE;*)
		NewData : BOOL;
	END_VAR
	VAR_OUTPUT
		BetrStatus : FB_MACHINE_MODE;
		cmdStatus : FB_CUTTINGUNIT_CMD;
		err : FB_ErrorHdl;
		busy : BOOL;
	END_VAR
	VAR_IN_OUT
		machineMaster : FB_AxisCtrl;
		axis : FB_CONVEYOR_AXIS; (*FB_AxisCtrl;*)
		status : FB_ModulStatus;
		cutterUp : FB_PullBreakClampToggle;
		discmovesupp : FB_CLAMP;
		movebutton : FB_KeyLamp;
		data : FB_CONVEYOR_DATA;
		emcy_inputs : FB_SafeInputs;
		webclamp : FB_CLAMP;
		safety : FB_Safety;
		clk : FB_Clk;
	END_VAR
	VAR
		CONST : FB_CONST_MASCHINE;
		config : FB_ConveyorConfig;
		chkStatus : FB_UnitChkStatus;
		state : INT;
		timer : TON;
		supplydelay : TON;
		StateCtrl : INT := ST_IDLE; (*:= CTRL_FIRST_START*)
		stateCPL : INT;
		manualFirst : BOOL;
		axisCpl : BOOL;
	END_VAR
	VAR CONSTANT
		cpl_idle : INT := 0;
		clp_cpl : INT := 1;
		ST_IDLE : INT := 0;
		ST_CPL_WAIT : INT := 1;
		ST_FUNCTION_START : INT := 10;
		ST_FUNCTION : INT := 12;
		ST_FUNCTION_QUIT : INT := 14;
		ST_AXIS_OFF : INT := 16;
		ST_AXIS_ON : INT := 18;
		ST_MOVE_START : INT := 20;
		ST_MOVE : INT := 22;
		ST_MOVE_QUIT : INT := 24;
		ST_ERROR : INT := 98;
		ST_QUIT : INT := 99;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK FB_CONVEYOR (*TODO: Bitte Kommentar hier einzufügen*)
	VAR_INPUT
		ctrl : FB_ConveyorCtrl;
		axis : FB_CONVEYOR_AXIS;
		data : FB_CONVEYOR_DATA;
		status : FB_ModulStatus;
		safety : FB_Safety;
		emcy_inputs : FB_SafeInputs;
		counters : FB_Counters;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK FB_CONVEYOR_AXIS (*TODO: Bitte Kommentar hier einzufügen*)
	VAR_INPUT
		ctrl : FB_AxisCtrl;
		cplOn : MC_GearIn;
		cplOff : MC_GearOut;
		moveAdditive : MC_MoveAdditive;
		setGearRatio : FB_SetGearRatio;
		MC_BR_Phasing_0 : MC_BR_Phasing;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK FB_ConveyorCtrl (*TODO: Bitte Kommentar hier einzufügen*)
	VAR_INPUT
		BetrCtrl : FB_MACHINE_MODE;
		cmdCtrl : FB_CUTTINGUNIT_CMD;
		mode : UDINT; (*BYTE;*)
		NewData : BOOL;
	END_VAR
	VAR_OUTPUT
		BetrStatus : FB_MACHINE_MODE;
		cmdStatus : FB_CUTTINGUNIT_CMD;
		err : FB_ErrorHdl;
		busy : BOOL;
	END_VAR
	VAR_IN_OUT
		machineMaster : FB_AxisCtrl;
		axis : FB_CONVEYOR_AXIS; (*FB_AxisCtrl;*)
		status : FB_ModulStatus;
		data : FB_CONVEYOR_DATA;
		safety : FB_Safety;
		counters : FB_Counters;
		panel : FB_Panel;
		emcy_inputs : FB_SafeInputs;
	END_VAR
	VAR
		CONST : FB_CONST_MASCHINE;
		config : FB_ConveyorConfig;
		chkStatus : FB_UnitChkStatus;
		state : INT;
		timer : TON;
		supplydelay : TON;
		StateCtrl : INT := ST_IDLE; (*:= CTRL_FIRST_START*)
		manualFirst : BOOL;
		visuReset : BOOL;
	END_VAR
	VAR CONSTANT
		ST_IDLE : INT := 0;
		ST_CPL_WAIT : INT := 1;
		ST_FUNCTION_START : INT := 10;
		ST_FUNCTION : INT := 12;
		ST_FUNCTION_QUIT : INT := 14;
		ST_ERROR : INT := 98;
		ST_QUIT : INT := 99;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK FB_ConveyorConfig (*TODO: Bitte Kommentar hier einzufügen*)
	VAR_INPUT
		cmd : INT;
		state : INT := ST_IDLE;
		busy : BOOL;
	END_VAR
	VAR_OUTPUT
		err : FB_ErrorHdl;
	END_VAR
	VAR_IN_OUT
		machineMasterCtrl : FB_AxisCtrl; (*FB_MASTERMODUL_AXIS *)
		axis : FB_CONVEYOR_AXIS;
		status : FB_ModulStatus;
	END_VAR
	VAR
		CONST : FB_CONST_MASCHINE;
		TON_delay : TON;
		TOF_delay : TOF;
		cmdtmp : INT;
	END_VAR
	VAR CONSTANT
		ST_IDLE : INT := 0;
		ST_CPL_START : INT := 32;
		ST_CPL_WAIT : INT := 33;
		ST_CPLOFF_START : INT := 35;
		ST_CPLOFF_WAIT : INT := 36;
		ST_MOVE_START : INT := 40;
		ST_MOVE_WAIT : INT := 41;
		ST_MOVE_QUIT : INT := 42;
		ST_ABORT : INT := 90;
		ST_ABORT_QUIT : INT := 91;
		ST_QUIT : INT := 98;
		ST_ERROR : INT := 99;
	END_VAR
	VAR
		zzEdge00000 : BOOL;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK FB_WinderAxis (*TODO: Bitte Kommentar hier einzufügen*)
	VAR_INPUT
		enable : BOOL;
		cmd : INT; (*position : REAL;*)
		velocity : REAL;
		deceleration : REAL;
		mode : BOOL;
		bufferUpDownKeys : BOOL;
		AxisREF : UDINT;
		ACP10AXIS : ACP10AXIS_typ;
		BasicControl : basic_typ;
		WNCCalcDiam_0 : WNCCalcDiam;
		startdiameter : REAL;
	END_VAR
	VAR_OUTPUT
		BetrStatus : FB_MACHINE_MODE;
		err : FB_ErrorHdl;
		busy : BOOL;
		MC_ReadStatus_0 : MC_ReadStatus;
		MC_BR_ReadDriveStatus_0 : MC_BR_ReadDriveStatus;
		MC_TorqueControl_0 : MC_TorqueControl; (*WNCCalcDiam_0 : WNCCalcDiam;*)
		LCRLimit_0 : LCRLimit;
	END_VAR
	VAR_IN_OUT
		machineaxis : FB_AxisCtrl; (*status : FB_ModulStatus;*)
		data : FB_WinderData;
	END_VAR
	VAR
		settorque : REAL;
		merker : BOOL;
		test : REAL;
		enablemerker : BOOL;
		MC_Stop_0 : MC_Stop;
		MC_Power_0 : MC_Power;
		CONST : FB_CONST_MASCHINE;
		AutoModeActive : BOOL;
		MC_ReadActualPosition_0 : MC_ReadActualPosition;
		MC_ReadActualVelocity_0 : MC_ReadActualVelocity;
		MC_Reset_0 : MC_Reset;
		TC_Winder_0 : TC_Winder;
		SysPara : wnc_sysPara_typ;
		EstPara : wnc_estPara_typ;
		test1 : REAL;
		test2 : REAL;
		firststart : BOOL := TRUE;
		torqueoffset : REAL := 1.2;
		pMasteraxisREF : REFERENCE TO ACP10AXIS_typ;
		pAxis : REFERENCE TO ACP10AXIS_typ;
		cmdtmp : INT;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK FB_Winder (*TODO: Bitte Kommentar hier einzufügen*)
	VAR_INPUT
		ctrl : FB_WinderCtrl;
		axis : FB_WinderAxis;
		data : FB_WinderData;
		IOs : FB_MachineIOs;
		status : FB_ModulStatus;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK FB_WinderCtrl (*TODO: Bitte Kommentar hier einzufügen*)
	VAR_INPUT
		BetrCtrl : FB_MACHINE_MODE; (* wird in FB FB_MachineSetMode gesezt*)
	END_VAR
	VAR_OUTPUT
		BetrStatus : FB_MACHINE_MODE;
		err : FB_ErrorHdl;
		busy : BOOL;
		diameterStop : BOOL;
		diameterWarning : BOOL;
	END_VAR
	VAR_IN_OUT
		machineMaster : FB_AxisCtrl;
		winderaxis : FB_WinderAxis;
		data : FB_WinderData;
		status : FB_ModulStatus;
		IOs : FB_MachineIOs;
	END_VAR
	VAR
		chkStatus : FB_UnitChkStatus;
		CONST : FB_CONST_MASCHINE;
		StateCtrl : INT;
		state : INT := ST_IDLE;
		firstStart : BOOL;
		timer : TON;
		supplydelay : TON;
	END_VAR
	VAR CONSTANT
		ST_IDLE : INT := 0;
		ST_CPLON : INT := 4;
		ST_CPLON_WAIT : INT := 6;
		ST_AXIS_OFF : INT := 8;
		ST_ERROR : INT := 98;
		ST_QUIT : INT := 99;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK FB_CuttingUnit (*TODO: Bitte Kommentar hier einzufügen*)
	VAR_INPUT
		ctrl : FB_CuttingCtrl;
		axis : FB_CutterAxis;
		moderCtrl : FB_CuttingModeCtrl;
		status : FB_CUTTINGUNIT_STATUS;
		powerbridge : FB_PowerBridge; (*safety : FB_Safety;*)
		data : FB_CUTTINGUNIT_DATA;
		emcy_inputs : FB_SafeInputs;
		markpoints : FB_MarkPoints;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK FB_CutterAxis
	VAR_INPUT
		ctrl : FB_AxisCtrl_new; (*FB_AxisCtrl;  (**) (*	crosscutter : FB_CrossCutter;*)
		cplCam : MC_CamIn;
		MC_BR_Phasing_0 : MC_BR_Phasing;
		refSwitchConfig : MC_BR_SetHardwareInputs; (*SwitchConfiguration;*)
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK FB_CrossCutter (*TODO: Bitte Kommentar hier einzufügen*)
	VAR_INPUT
		cmd : INT;
		SlaveREF : UDINT; (*Slave axis reference*)
		Enable : BOOL;
		EnableMove : BOOL; (*Allow this FUB to execute movements*)
		SearchRM : BOOL; (*Initiate search of new RM on positive edge*)
		RestartAllowed : BOOL; (*Execute a synchronization movement (only possible when "Move" is TRUE)**)
		VRmCorrection : DINT; (*Correction value for virtual marks*) (*ProductLength : DINT; (*Product length [Master Units]*)
		VRmRecordedPosition : DINT; (*Recorded position when using virtual registration mark*)
		RegMarkPar : SPR_REG_MARK_PAR_TYP; (*Parameters for registration mark detection and evaluation*)
		crosscuttpar : FB_CROSSCUTPAR; (*Cam automat parameters*) (*SyncPar : SPR_SYNC_PAR_TYP; (*Parameters for the synchronization movement*)
		SetupPar : SPR_SETUP_PAR_TYP; (*Parameters for setting up the axis before coupling*)
	END_VAR
	VAR_OUTPUT
		Active : BOOL; (*Cam automat is running*)
		Error : BOOL;
		ErrorID : UINT;
		SetupComplete : BOOL; (*Setup movement complete, punch clamp can be closed*)
		CutMasterPosition : DINT; (*Cut master position [Master Units]*)
		ProbeCounter : UDINT; (*Counter for valid trigger events*)
		MissedTriggers : UDINT; (*Counter for missed trigger events*)
		ActPositionError : DINT; (*Actual reg mark position error [Master Units]*)
		MC_BR_ReadDriveStatus_0 : MC_BR_ReadDriveStatus;
		MC_ReadStatus_0 : MC_ReadStatus;
		MC_BR_CrossCutterControl_0 : MC_BR_CrossCutterControl; (*Cam automat*)
		busy : BOOL;
	END_VAR
	VAR_IN_OUT
		machineMaster : FB_AxisCtrl;
		data : FB_CUTTINGUNIT_DATA;
		scalePerimeter : FB_ScalingPerimeter;
		GetNextCuttPos : FB_GetNextCuttPos;
		markpoints : FB_MarkPoints;
	END_VAR
	VAR
		State : INT;
		OffsetValue1 : DINT; (*cumulated offset correction*)
		OffsetValue : DINT; (*cumulated offset correction*)
		CutCntOld : UDINT;
		OffsetErrorValid : BOOL;
		PositionErrorValid : BOOL;
		PositionError : DINT;
		usercorrection : DINT; (* Offset des Schnitts von der VISU*)
		R_TRIG_InCompensation : R_TRIG;
		MC_BR_Phasing_0 : MC_BR_Phasing; (*Synchronization movement*)
		MC_Reset_0 : MC_Reset;
		MC_MoveAbsolute_0 : MC_MoveAbsolute; (*Setup movement before coupling*)
		MC_BR_ReadAutPosition_0 : MC_BR_ReadAutPosition; (*Reading of actual automat position for restart*)
		MC_ReadParameter_AxisPeriod : MC_ReadParameter; (*Reading of axis period for setup movement*)
		LCRLimit_Correction : LCRLimit; (*Limit RM correction movement*)
		RelativeShift : DINT; (*Relative shift for RM correction*)
		EnableRestart : BOOL; (*Enable cam automat restart*)
		MC_ReadActualPosition_0 : MC_ReadActualPosition;
		ShiftInProgress : BOOL;
		NeutralPosition : REAL; (*Neutral position where axis is not in synchronisation*)
		LCRLimScal_CutRangeMaster : LCRLimScal;
		SPR_RmCalcPosError_Virtual : SPR_RmCalcPosError; (*Calculate position error for virtual registration marks*)
		CutCount_1 : UDINT;
		CccTriggerInit : BOOL; (*Trigger inititalization of CCC*)
		CccInitMasterMaxVel : BOOL; (*Init max. maste*) (*VTrigger : ARRAY[0..MAX_TRIGGER_INDEX] OF VTriggerParameters_typ;*) (*Parameters for virtual trigger signal*)
		MC_BR_ReadAxisError_0 : MC_BR_ReadAxisError;
		DriveStatus : MC_DRIVESTATUS_TYP;
		CONST : FB_CONST_MASCHINE;
		syncFtrig : F_TRIG;
		syncRtrig : R_TRIG;
		initdata : BOOL;
	END_VAR
	VAR CONSTANT
		MAX_TRIGGERS : USINT := 3;
		MAX_TRIGGER_INDEX : USINT := 2;
		STATE_DISABLED : INT := 0;
		STATE_INIT : INT := 1;
		STATE_IDLE : INT := 2;
		STATE_CHECK_STANDBY : INT := 3;
		STATE_READ_AUT_POS : INT := 4;
		STATE_MOVE_TO_AUT_POS : INT := 5;
		STATE_MOVE_TO_NEUTRAL_POS : INT := 6;
		STATE_W4_REG_MARK : INT := 7;
		STATE_START_AUTOMAT : INT := 8;
		STATE_RUNNING : INT := 9;
		STATE_W4_RESET : INT := 10;
		STATE_ERROR : INT := 11;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK FB_CuttingCtrl (*TODO: Bitte Kommentar hier einzufügen*)
	VAR_INPUT
		BetrCtrl : FB_MACHINE_MODE;
		cmdCtrl : FB_CUTTINGUNIT_CMD;
		mode : BYTE;
		check : FB_CuttingCheckData;
		setCutOffset : FB_SetCutOffset;
	END_VAR
	VAR_OUTPUT
		BetrStatus : FB_MACHINE_MODE;
		cmdStatus : FB_CUTTINGUNIT_CMD;
		err : FB_ErrorHdl;
		busy : BOOL;
	END_VAR
	VAR_IN_OUT
		machineMaster : FB_AxisCtrl;
		axis : FB_CutterAxis;
		modeCtrl : FB_CuttingModeCtrl;
		data : FB_CUTTINGUNIT_DATA;
		status : FB_CUTTINGUNIT_STATUS;
		IOs : FB_MachineIOs;
		safety : FB_Safety;
		powerbridge : FB_PowerBridge;
		clk : FB_Clk;
		emcy_inputs : FB_SafeInputs;
		markpoints : FB_MarkPoints;
		panel : FB_Panel;
	END_VAR
	VAR
		scalePerimeter : FB_ScalingPerimeter;
		CONST : FB_CONST_MASCHINE;
		config : FB_CuttingConfig;
		camtable : FB_CreateCamTable;
		camCtrl : FB_CuttingCamCtrl;
		getNextUnitSyncPos : FB_GetNextCuttingSynPos;
		chkStatus : FB_UnitChkStatus;
		tmpData : FB_CUTTINGUNIT_TMPDATA;
		state : INT;
		timer : TON;
		supplydelay : TON;
		StateCtrl : INT := ST_IDLE; (*:= CTRL_FIRST_START*)
		manualFirst : BOOL;
		axisreset : BOOL;
	END_VAR
	VAR CONSTANT
		ST_IDLE : INT := 0;
		ST_SETDATA_WAIT : INT := 2;
		ST_CPL_WAIT : INT := 6;
		ST_FUNCTION_START : INT := 10;
		ST_FUNCTION : INT := 12;
		ST_FUNCTION_ABORT_WAIT : INT := 14;
		ST_FUNCTION_QUIT : INT := 16;
		ST_MOVE_START : INT := 20;
		ST_MOVE : INT := 22;
		ST_MOVE_QUIT : INT := 24;
		ST_CPLON : INT := 34;
		ST_CPLON_WAIT : INT := 36;
		ST_CPLON_ABORTED : INT := 38;
		ST_DEINIT_WAIT : INT := 50;
		ST_ERROR : INT := 98;
		ST_QUIT : INT := 99;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK FB_CuttingConfig (*TODO: Bitte Kommentar hier einzufügen*)
	VAR_INPUT
		cmd : INT;
		liftedUp : BOOL;
	END_VAR
	VAR_OUTPUT
		err : FB_ErrorHdl;
		busy : BOOL;
		copple : BOOL;
	END_VAR
	VAR_IN_OUT
		machineMaster : FB_AxisCtrl;
		axis : FB_CutterAxis;
		camtable : FB_CreateCamTable;
		status : FB_CUTTINGUNIT_STATUS;
		data : FB_CUTTINGUNIT_DATA;
		scalePerimeter : FB_ScalingPerimeter;
		IOs : FB_MachineIOs;
		getNextUnitSyncPos : FB_GetNextCuttingSynPos;
		markpoints : FB_MarkPoints; (*getNextCuttPos : FB_GetNextCuttPos;*)
		powerbridge : FB_PowerBridge;
		setCutOffset : FB_SetCutOffset;
	END_VAR
	VAR
		state : INT;
		cmdtmp : INT;
		corr : REAL;
		MAX_TRIGGER_INDEX : INT;
		writeEncoder : FB_WriteEncoder;
		InitAxisSubjectPar : MC_BR_InitAxisSubjectPar;
		CONST : FB_CONST_MASCHINE;
		syncDiff : REAL;
		timer : TON;
		pAxis : REFERENCE TO ACP10AXIS_typ;
	END_VAR
	VAR CONSTANT
		ST_IDLE : INT := 0;
		ST_SETDATA_START : INT := 2;
		ST_SETDATA_WAIT : INT := 4;
		ST_INIT_START : INT := 10;
		ST_CALIBR_START : INT := 20;
		ST_CALIBR_WAIT : INT := 22;
		ST_CALIBR_START_NULLPOS : INT := 24;
		ST_CALIBR_WAIT_NULLPOS : INT := 26;
		ST_CALIBR_RESET_WAIT : INT := 28;
		ST_CALIBR_STOP : INT := 29;
		ST_GENERATE_TABLE_START : INT := 35;
		ST_GENERATE_TABLE_WAIT : INT := 36;
		ST_CPL_TABLE_START : INT := 37;
		ST_CPL_CAMTABLE : INT := 38;
		ST_CPL_EXECUTE : INT := 39;
		ST_MOVE_START : INT := 40;
		ST_MOVE_WAIT : INT := 41;
		ST_MOVE_QUIT : INT := 42;
		ST_MOVECUTTER_WAIT : INT := 45;
		ST_DEINIT_CPLSLAVEOFF_START : INT := 66;
		ST_DEINIT : INT := 67;
		ST_SYNC_START : INT := 70;
		ST_SYNC_CPLOFF_START : INT := 71;
		ST_SYNC_CPLOFF_WAIT : INT := 72;
		ST_SYNC_START_CORRECTION : INT := 73;
		ST_SYNC_WAIT_CORRECTION : INT := 74;
		ST_SYNC_CPLON : INT := 76;
		ST_CPL_WAIT : INT := 77;
		ST_CPL_START : INT := 78;
		ST_CPLOFF_START : INT := 80;
		ST_CPLOFF_WAIT : INT := 81;
		ST_ABORT : INT := 90;
		ST_ABORT_QUIT : INT := 91;
		ST_ERROR : INT := 99;
		ST_QUIT : INT := 98;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK FB_CuttingModeCtrl (*TODO: Bitte Kommentar hier einzufügen*)
	VAR_INPUT
		mode : UDINT; (*BYTE;*)
		visureset : BOOL; (*Crosscutter reseten aus der Visu . Sensorauswahl*)
		reset : BOOL;
	END_VAR
	VAR_OUTPUT
		busy : BOOL := TRUE;
		err : FB_ErrorHdl;
	END_VAR
	VAR_IN_OUT
		machineMaster : FB_AxisCtrl;
		axis : FB_CutterAxis;
		scalePerimeter : FB_ScalingPerimeter;
		data : FB_CUTTINGUNIT_DATA;
		status : FB_CUTTINGUNIT_STATUS;
		camCtrl : FB_CuttingCamCtrl;
		getNextUnitSyncPos : FB_GetNextCuttingSynPos;
		markpoints : FB_MarkPoints;
		syncData : FB_SyncData;
		setCutOffset : FB_SetCutOffset; (*FB_SetCutOffset;*)
	END_VAR
	VAR
		CONST : FB_CONST_MASCHINE;
		state : INT;
	END_VAR
	VAR CONSTANT
		MAX_TRIGGERS : USINT := 3;
		MAX_TRIGGER_INDEX : USINT := 2;
		ST_IDLE_BEFORE : INT := 0;
		ST_IDLE : INT := 1;
		ST_IDLE_QUIT : INT := 2;
		ST_FREECUTTING_BEFORE : INT := 10;
		ST_FREECUTTING : INT := 20;
		ST_SYNCCUTTING_BEFORE : INT := 30;
		ST_SYNCCUTTING : INT := 32;
		ST_SYNCCUTTING_AFTER : INT := 34;
		ST_CROSSCUTTING_BEFOR : INT := 40;
		ST_CROSSCUTTING : INT := 42;
		ST_CROSSCUTTING_AFTER : INT := 44;
		ST_ABORT : INT := 90;
		ST_ABORT_QUIT : INT := 91;
		ST_ERROR : INT := 96;
		ST_QUIT : INT := 99;
	END_VAR
END_FUNCTION_BLOCK
(*	camCtrl : FB_CuttingCamCtrl;*)

FUNCTION_BLOCK FB_CuttingCamCtrl (*TODO: Bitte Kommentar hier einfügen*) (*$GROUP=Anwender*)
	VAR_INPUT
		enable : BOOL; (* *) (*	markpoints:  	FB_MarkPoints;*)
	END_VAR
	VAR_IN_OUT
		machineMaster : FB_AxisCtrl;
		axis : FB_CutterAxis;
		scalePerimeter : FB_ScalingPerimeter;
		data : FB_CUTTINGUNIT_DATA;
		status : FB_CUTTINGUNIT_STATUS; (*	getNextCuttPos : FB_GetNextCuttPos;*)
		getNextUnitSyncPos : FB_GetNextCuttingSynPos;
		markpoints : FB_MarkPoints;
		setCutOffset : FB_SetCutOffset;
		CONST : FB_CONST_MASCHINE;
	END_VAR
	VAR
		syncData : FB_SyncData;
		usercorrtemp : DINT;
		usercorrection : DINT; (* Offset des Schnitts von der VISU*)
		state : INT;
		actSyncPosIdent : UDINT;
		counter : UDINT;
		donecounter : UDINT;
		errorcounter : UDINT;
		shiftValuetmp : REAL;
		corrfactor : REAL;
		shifttmp : REAL;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK FB_WriteEncoder (*TODO: Bitte Kommentar hier einzufügen*)
	VAR_INPUT
		InverseDirection : BOOL;
		enable : BOOL;
		AxisREF : UDINT; (*ACP10AXIS: 		 ACP10AXIS_typ;*)
		check : BOOL;
	END_VAR
	VAR_OUTPUT
		EncIf_InitValid : BOOL;
		busy : BOOL;
		err : FB_ErrorHdl;
	END_VAR
	VAR_IN_OUT
		data : FB_CUTTINGUNIT_DATA;
		scalePerimeter : FB_ScalingPerimeter;
	END_VAR
	VAR
		EncIf_Act : ACP10ENCPA_typ;
		EncIf_Set : ACP10ENCPA_typ;
		MC_ReadAxisError_0 : MC_ReadAxisError;
		MC_ReadStatus_0 : MC_ReadStatus;
		MC_BR_ReadDriveStatus_0 : MC_BR_ReadDriveStatus;
		MC_BR_InitAxisSubjectPar_0 : MC_BR_InitAxisSubjectPar;
		MC_BR_InitModPos_0 : MC_BR_InitModPos;
		SetupRelease_0 : SPR_SetupRelease;
		DriveStatus : MC_DRIVESTATUS_TYP;
		ModPeriod_Act : UDINT;
		ModPeriod_Set : UDINT;
		state : INT;
		pAxis : REFERENCE TO ACP10AXIS_typ;
	END_VAR
	VAR CONSTANT
		ST_IDLE : INT := 0;
		ST_SETDATA_START : INT := 1;
		ST_SETDATA_WAIT : INT := 2;
		ST_SET_MODULO : INT := 3;
		ST_ERROR : INT := 4;
		ST_QUIT : INT := 5;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK FB_CuttingCheckData
	VAR_OUTPUT
		err : FB_ErrorHdl;
		valid : BOOL;
	END_VAR
	VAR_IN_OUT
		recipe : rcp_prog_cutUnit_typ;
		machdata : rcp_machine_cutUnit_typ;
		general : rcp_prog_general_typ;
		modeCtrl : FB_CuttingModeCtrl;
	END_VAR
	VAR
		tmpString : STRING[40];
		CONST : FB_CONST_MASCHINE;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK FB_CUTTINGUNIT_DATA
	VAR_INPUT
		newRecipe : BOOL;
		newMach : BOOL;
		newTools : BOOL;
		loaded : BOOL;
		recipe : rcp_prog_cutUnit_typ;
		machdata : rcp_machine_cutUnit_typ;
		general : rcp_prog_general_typ; (*	check : FB_CuttingCheckData;*)
		tmpData : FB_CUTTINGUNIT_TMPDATA;
		err : FB_ErrorHdl;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK FB_CUTTINGUNIT_TMPDATA
	VAR_INPUT
		set : BOOL;
		compare : BOOL;
		actMasterModulData : rcp_prog_general_typ;
		actMach : rcp_machine_cutUnit_typ;
		actRecipe : rcp_prog_cutUnit_typ;
	END_VAR
	VAR_OUTPUT
		changed : BOOL;
		changedText : STRING[80];
		err : FB_ErrorHdl;
	END_VAR
	VAR_IN_OUT
		setMasterModulData : rcp_prog_general_typ;
		setMach : rcp_machine_cutUnit_typ;
		setRecipe : rcp_prog_cutUnit_typ;
		BetrCtrl : FB_MACHINE_MODE;
	END_VAR
	VAR
		CONST : FB_CONST_MASCHINE;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK FB_GlobalMachineVar (*TODO: Bitte Kommentar hier einzufügen*)
	VAR_INPUT
		gMachine : Machine_Type;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK FB_TurnGridWinderUnit (*TODO: Bitte Kommentar hier einzufügen*)
	VAR_INPUT
		ctrl : FB_TurnGridUnitCtrl; (*FB_TunrGridWinCtrl;*)
		gridwinderright : FB_GRIDWINDER;
		gridwinderleft : FB_GRIDWINDER;
		feeder : FB_AxisCtrl_GridFeeder;
		status : FB_UNWINDERUNITSTATUS; (*FB_ModulStatus;*)
		TurnGrWinKeysbox : FB_TurnGrWinKeysbox; (*data:				FB_DUBBLEUUNWINDERDATA;*)
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK FB_TurnGridUnitCtrl (*TODO: Bitte Kommentar hier einfügen*) (*$GROUP=Anwend_er*)
	VAR_INPUT
		BetrCtrl : FB_MACHINE_MODE; (* wird in FB FB_MachineSetMode gesezt*)
		refSwitchConfig : MC_BR_SetHardwareInputs; (*SwitchConfiguration;*)
		SwitchConfig : SwitchConfiguration;
	END_VAR
	VAR_OUTPUT
		BetrStatus : FB_MACHINE_MODE;
		err : FB_ErrorHdl;
		busy : BOOL;
		diameterStop : BOOL;
		diameterWarning : BOOL;
		valveterminal : USINT;
	END_VAR
	VAR_IN_OUT
		panel : FB_Panel;
		machineaxis : FB_AxisCtrl;
		gridwinderright : FB_GRIDWINDER;
		gridwinderleft : FB_GRIDWINDER;
		feeder : FB_AxisCtrl_GridFeeder;
		TurnGrWinKeysbox : FB_TurnGrWinKeysbox; (*data:				FB_DUBBLEUUNWINDERDATA;
		status: 			FB_UNWINDERUNITSTATUS;*)
		clk : FB_Clk;
	END_VAR
	VAR
		feederstatus : FB_ModulStatus;
		feedertrig : R_TRIG;
		rtig : BOOL;
		CONST : FB_CONST_MASCHINE;
		StateCtrl : INT;
		feederPosTmp : REAL;
		state : INT := ST_IDLE;
		axisstep : INT := ST_IDLE;
		timer : TON;
		test : BOOL;
		merker : BOOL;
		supplydelay : TON;
		FeederHomeButton : BOOL;
		testStop : BOOL;
	END_VAR
	VAR CONSTANT
		ST_IDLE : INT := 0;
		ST_STOP : INT := 1;
		ST_NOACTION : INT := 2;
		ST_CPLON : INT := 4;
		ST_CPLON_WAIT : INT := 6;
		ST_TURN_WAIT_LEFT : INT := 8;
		ST_TURN_WAIT_RIGHT : INT := 10;
		ST_ERROR : INT := 98;
		ST_QUIT : INT := 99;
	END_VAR
	VAR
		R_TRIG_feederturnkey : R_TRIG;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK FB_GRIDWINDER (*TODO: Bitte Kommentar hier einfügen*) (*$GROUP=Anwender*)
	VAR_INPUT
		ctrl : FB_TunrGridWinCtrl; (*FB_UnwinderCtrl;(*FB_MainUnwinderCtrl;*)
		axis : FB_WinderAxis; (*FB_UnwinderAxis;*)
		data : FB_WinderData;
		status : FB_ModulStatus;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK FB_TunrGridWinCtrl
	VAR_INPUT
		BetrCtrl : FB_MACHINE_MODE;
	END_VAR
	VAR_OUTPUT
		BetrStatus : FB_MACHINE_MODE;
		busy : BOOL;
		err : FB_ErrorHdl;
		diameterStop : BOOL;
		diameterWarning : BOOL;
	END_VAR
	VAR_IN_OUT
		machineaxis : FB_AxisCtrl;
		axis : FB_WinderAxis; (* FB_UnwinderAxis;*)
		data : FB_WinderData;
		status : FB_ModulStatus;
	END_VAR
	VAR
		StateCtrl : INT;
		state : INT;
		CONST : FB_CONST_MASCHINE;
		chkStatus : FB_UnitChkStatus;
		timer : TON;
		supplydelay : TON;
		manualFirst : BOOL;
	END_VAR
	VAR CONSTANT
		ST_IDLE : INT := 0;
		ST_AXIS_STOP : INT := 4;
		ST_AXIS_RUN : INT := 6;
		ST_AXIS_OFF : INT := 8;
		ST_AXIS_ON : INT := 10;
		ST_AXIS_ON_DIS : INT := 12;
		ST_ERROR : INT := 98;
		ST_QUIT : INT := 99;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK FB_WEBBUFFER (*TODO: Bitte Kommentar hier einfügen*)
	VAR_INPUT
		ctrl : FB_WebbufferCtrl; (*FB_PullbreakUnitCtrl;*)
		axis : FB_Bufferaxis; (* FB_AxisCtrl;  (**)
		safety : FB_Safety;
		status : FB_ModulStatus;
		dancer : FB_Dancer;
		data : FB_BUFFER_DATA; (*FB_WinderData;*)
		emcy_inputs : FB_SafeInputs;
		keys : FB_KeysWebbuffer;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK FB_WebbufferCtrl (*TODO: Bitte Kommentar hier einfügen*)
	VAR_INPUT
		BetrCtrl : FB_MACHINE_MODE;
		cmdCtrl : FB_CUTTINGUNIT_CMD;
		mode : UDINT; (*BYTE;*)
		torquelow : BOOL;
		online : BOOL;
	END_VAR
	VAR_OUTPUT
		BetrStatus : FB_MACHINE_MODE;
		cmdStatus : FB_CUTTINGUNIT_CMD;
		err : FB_ErrorHdl;
		busy : BOOL;
		unwinderOFF : BOOL;
		mechbrakeON_OFF : BOOL;
	END_VAR
	VAR_IN_OUT
		machineaxis : FB_AxisCtrl;
		axis : FB_Bufferaxis; (*FB_AxisCtrl*) (*FB_PULLBREAK_AXIS;*)
		status : FB_ModulStatus;
		data : FB_BUFFER_DATA;
		safety : FB_Safety;
		keys : FB_KeysWebbuffer;
		dancer : FB_Dancer;
		clk : FB_Clk;
		emcy_inputs : FB_SafeInputs;
	END_VAR
	VAR
		buffertofullRtrig : R_TRIG;
		config : FB_BufferConfig; (*	data : FB_WinderData;*)
		CONST : FB_CONST_MASCHINE;
		chkStatus : FB_UnitChkStatus;
		torqueoffset : FB_SetGearRatio;
		state : INT;
		timer : TON;
		firstStart : BOOL;
		supplydelay : TON;
		brakeholddelay : TON;
		StateCtrl : INT := ST_IDLE; (*:= CTRL_FIRST_START*)
		manualFirst : BOOL;
		test : BOOL;
		test1 : BOOL;
		fulltorque : REAL := 5;
		settorquelow : REAL := 1.1;
		settorquehigh : REAL := 1.8;
	END_VAR
	VAR CONSTANT
		setposition : REAL := 2600; (*600000*)
		ST_IDLE : INT := 0;
		ST_CPL_WAIT : INT := 1;
		ST_FUNCTION_START : INT := 10;
		ST_FUNCTION : INT := 12;
		ST_FUNCTION_QUIT : INT := 14;
		ST_MOVE_START : INT := 16;
		ST_MOVE : INT := 18;
		ST_MOVE_QUIT : INT := 20;
		ST_ERROR : INT := 98;
		ST_QUIT : INT := 99;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK FB_Bufferaxis (*TODO: Bitte Kommentar hier einfügen*) (*$GROUP=Anwender*)
	VAR_INPUT
		ctrl : FB_AxisCrtl_Home; (*FB_AxisCtrl ;*)
		bufferaxis : FB_BufferTensionCtrl; (*FB_TorqueAxis;*)
		refSwitchConfig : MC_BR_SetHardwareInputs;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK FB_BufferConfig (*TODO: Bitte Kommentar hier einfügen*) (*$GROUP=Anwender*)
	VAR_INPUT
		cmd : INT;
	END_VAR
	VAR_OUTPUT
		busy : BOOL;
		err : FB_ErrorHdl;
	END_VAR
	VAR_IN_OUT
		axis : FB_Bufferaxis;
		status : FB_ModulStatus; (*FB_CUTTINGUNIT_STATUS;*)
	END_VAR
	VAR
		state : INT;
		cmdtmp : INT;
		CONST : FB_CONST_MASCHINE;
		pAxis : REFERENCE TO ACP10AXIS_typ;
		InitAxisSubjectPar : MC_BR_InitAxisSubjectPar; (*MC_BR_InitModPos_0 : MC_BR_InitModPos;*
		ModPeriod_Act : UDINT;
		ModPeriod_Set : UDINT;*)
	END_VAR
	VAR CONSTANT
		ST_INIT_START : INT := 10;
		ST_REF_START : INT := 12;
		ST_MOVE_START : INT := 20;
		ST_MOVE_WAIT : INT := 30;
		ST_MOVE_QUIT : INT := 31;
		ST_CALIBR_START_NULLPOS : INT := 40;
		ST_CALIBR_WAIT : INT := 42;
		ST_ABORT : INT := 90;
		ST_ABORT_QUIT : INT := 91;
		ST_ERROR : INT := 92;
		ST_QUIT : INT := 99;
	END_VAR
END_FUNCTION_BLOCK
(*ST_SET_MODULO: INT:= 5;*)

FUNCTION_BLOCK FB_TorqueAxis (*TODO: Bitte Kommentar hier einfügen*) (*$GROUP=Anwender*)
	VAR_INPUT
		cmd : INT;
		position : REAL;
		velocity : REAL;
		override : REAL;
		verzoegerung : REAL;
		settorque : REAL;
		setvelocity : REAL;
		AxisREF : UDINT;
		BasicControl : basic_typ;
	END_VAR
	VAR_OUTPUT
		err : FB_ErrorHdl;
		busy : BOOL;
		MC_ReadStatus_0 : MC_ReadStatus;
		MC_BR_ReadDriveStatus_0 : MC_BR_ReadDriveStatus;
		MC_TorqueControl_0 : MC_TorqueControl;
	END_VAR
	VAR_IN_OUT
		machineaxis : FB_AxisCtrl; (*status : FB_ModulStatus;*)
		data : FB_WinderData;
	END_VAR
	VAR
		enablemerker : BOOL;
		test : REAL := 1.95;
		MC_Stop_0 : MC_Stop;
		LCRLimit_0 : LCRLimit;
		MC_Power_0 : MC_Power;
		CONST : FB_CONST_MASCHINE;
		AutoModeActive : BOOL;
		MC_ReadActualPosition_0 : MC_ReadActualPosition;
		MC_Reset_0 : MC_Reset; (*DriveStatus : MC_DRIVESTATUS_TYP;*) (*MC_TorqueControl_0 : MC_TorqueControl;*)
		TC_Winder_0 : TC_Winder;
		SysPara : wnc_sysPara_typ;
		EstPara : wnc_estPara_typ;
		WNCCalcDiam_0 : WNCCalcDiam;
		test1 : REAL;
		test2 : REAL;
		firststart : BOOL := TRUE;
		masteraxisREF : REFERENCE TO ACP10AXIS_typ;
		pAxis : REFERENCE TO ACP10AXIS_typ;
		cmdtmp : INT;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK FB_BUFFER_DATA (*TODO: Bitte Kommentar hier einfügen*) (*$GROUP=Anwender*)
	VAR_INPUT
		recipe : FB_BUFFER_RECIPE_DATA;
		machData : FB_WinderMachData;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK FB_BufferTensionCtrl (*TODO: Bitte Kommentar hier einfügen*) (*$GROUP=Anwender*)
	VAR_INPUT
		cmd : INT;
		position : REAL;
		velocity : REAL;
		override : REAL;
		verzoegerung : REAL;
		ruck : REAL;
		AxisREF : UDINT; (*ACP10AXIS : ACP10AXIS_typ;*)
		BasicControl : basic_typ;
	END_VAR
	VAR_OUTPUT
		MC_BR_ReadDriveStatus_0 : MC_BR_ReadDriveStatus;
		MC_BR_VelocityControl_0 : MC_BR_VelocityControl; (*	BetrStatus : FB_Machine_Mode;*) (*MC_BR_TorqueControl_0:	MC_BR_TorqueControl;*)
		MC_ReadStatus_0 : MC_ReadStatus;
		err : FB_ErrorHdl;
		busy : BOOL;
	END_VAR
	VAR_IN_OUT
		machineaxis : FB_AxisCtrl;
		data : FB_BUFFER_DATA;
		dancer : FB_Dancer;
		CONST : FB_CONST_MASCHINE;
		tensionoffset : FB_SetGearRatio;
	END_VAR
	VAR
		LCRPID_0 : LCRPID; (*PID Controller*)
		LCRPIDpara_0 : LCRPIDpara; (*Parameter of PID controller*)
		LCRPT1e_ActTension : LCRPT1e; (*Lowpass filter for sensor signal*) (*	MC_BR_CyclicWrite_0:MC_BR_CyclicWrite;*)
		CyclicVelocity : REAL;
		TM_SCALE_PID_OUT_TO_OFFSET : REAL := 3;
		settorque : REAL := 6;
		OutPID : REAL;
		LCRLimit_0 : LCRLimit;
		AutoModeActive : BOOL;
		merker : BOOL;
		Enable_Rtrig : R_TRIG;
		MC_Power_0 : MC_Power;
		MC_ReadActualPosition_0 : MC_ReadActualPosition; (*MC_Reset_0: 		MC_Reset;
		MC_Stop_0: 			MC_Stop;*)
		DriveStatus : MC_DRIVESTATUS_TYP;
		firststart : BOOL := TRUE;
		pAxis : REFERENCE TO ACP10AXIS_typ;
		AxisStep : USINT;
		cmdtmp : INT;
	END_VAR
	VAR CONSTANT
		TENSION_T_FILTER : REAL := 1; (*tension filter time [s]*) (*	TM_SCALE_PID_OUT_TO_OFFSET : REAL := 1000.0;*)
		ST_INIT1 : USINT := 0; (*NOACTION*)
		ST_READY : USINT := 1; (*START*)
		ST_WAIT_POWER_ENABLED : USINT := 2;
		ST_LOAD_PARA_START : USINT := 4;
		ST_WAIT_LOAD_PARA_DONE : USINT := 6;
		ST_WAIT_SWITCH_CTRL_ON : USINT := 8;
		ST_CTRL_ACTIVE : USINT := 10;
		ST_MOVE_POS : USINT := 12;
		ST_MOVE_NEG : SINT := 14;
		ST_CTRL_PAUSE : USINT := 18;
		ST_CTRL_OFF : USINT := 20;
		STATE_ERROR_AXIS : USINT := 22;
		STATE_ERROR : USINT := 99;
		STATE_ERROR_RESET : USINT := 101;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK FB_BUFFER_RECIPE_DATA (*TODO: Bitte Kommentar hier einfügen*) (*$GROUP=Anwender*)
	VAR_INPUT
		SetTension : REAL; (*Tension setpoint*)
		mode : UDINT;
		newParam2 : BOOL;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK FB_SpeedCtlrPid (*TODO: Bitte Kommentar hier einfügen*) (*$GROUP=Anwender*)
	VAR_INPUT
		dancepos : INT;
		setDancerpos : REAL;
		ConveyerVelocity : INT; (*Geschw des HAuptbandes vom Extruders*)
		limitspeed : REAL; (*Limit für den Offset der tatsächlichen Geschw.*)
		reset : BOOL;
		maxMainVelocity : REAL; (*maximale Geschw. der Wert hängt von der Geschw. des Transportbandes bzw. des Extruders Einheit m/min*)
		startCycleWebturrit : BOOL;
		speedToCycleWebturrit : REAL;
	END_VAR
	VAR_OUTPUT
		setVelocity : REAL;
	END_VAR
	VAR
		dancerWasEmpty : BOOL;
		TM_SCALE_PID_OUT_TO_OFFSET : REAL := 3;
		firststart : BOOL := TRUE;
		LCRPID_0 : LCRPID; (*PID Controller*)
		LCRPIDpara_0 : LCRPIDpara; (*Parameter of PID controller*)
		rDancepos : REAL;
		velocityramp : LCRRamp;
		lowPass : LCRPT1;
		lowPassSpeed : LCRPT1;
		PID_Kp : REAL := 0.3; (*Taenzer Inline Verstaerkung OKrebs 09.09.21*)
		test : INT;
		AxisStep : USINT;
		velocityOffset : REAL;
		inc_to_volt : REAL;
		volt_to_speed : REAL;
		tempvalue : REAL;
		minDancerPos : REAL := 350;
		maxDancerPos : REAL := 750;
		zeitkonstante : REAL;
		lowPassEnable : BOOL;
	END_VAR
	VAR CONSTANT
		velocityStep : REAL := 166.67; (*0,01m Schritt*)
		highlimitDancerpos : REAL := 400; (*oberste POsition*)
		lowlimitDancerpos : REAL := 830; (*unterste Position des Tänzers*)
		SCALE_INC_TO_V : REAL := (10.0/32767.0); (*(1000.0/32767.0); (*10.0 V = 1000 mm; 10.0 V = 32767*)
		SCALE_10V_TO_MM : REAL := (1000.0/32767.0);
		ST_INIT1 : USINT := 0; (*NOACTION*)
		ST_READY : USINT := 1; (*START*)
		ST_WAIT_POWER_ENABLED : USINT := 2;
		ST_LOAD_PARA_START : USINT := 4;
		ST_WAIT_LOAD_PARA_DONE : USINT := 6;
		ST_WAIT_SWITCH_CTRL_ON : USINT := 8;
		ST_CTRL_ACTIVE : USINT := 10;
		ST_MOVE_POS : USINT := 12;
		ST_MOVE_NEG : SINT := 14;
		ST_CTRL_PAUSE : USINT := 18;
		ST_CTRL_OFF : USINT := 20;
		STATE_ERROR_AXIS : USINT := 22;
		STATE_ERROR : USINT := 99;
		STATE_ERROR_RESET : USINT := 101;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK FB_GetNextCuttingSynPos (*TODO: Bitte Kommentar hier einfügen*) (*$GROUP=Anwender*)
	VAR_INPUT
		getMark : FB_GetCuttingMark;
		trigger : BOOL;
	END_VAR
	VAR_OUTPUT
		syncDataBefore : FB_SyncData;
		syncDataAfter : FB_SyncData;
		MC_BR_ReadCyclicPosition_0 : MC_BR_ReadCyclicPosition;
		MC_BR_ReadCyclicPosition_1 : MC_BR_ReadCyclicPosition;
	END_VAR
	VAR_IN_OUT
		machineMaster : FB_AxisCtrl; (*MaschinenMaster vertuelle Achse*)
		uAxis : FB_AxisCtrl_new; (*FB_AxisCrtl_Home;*)
		markpoints : FB_MarkPoints;
		uData : FB_CUTTINGUNIT_DATA;
		scalePerimeter : FB_ScalingPerimeter; (*camtable:				FB_CAMTABLE;*)
		setCutOffset : FB_SetCutOffset;
		CONST : FB_CONST_MASCHINE;
	END_VAR
	VAR
		correctionTotal : REAL;
		countRtrig : R_TRIG;
		correctionTotal1 : REAL;
		correctionTotalInt : DINT;
		correctionTmp : REAL;
		correctionTmpInt : DINT;
		period : DINT;
		moduloBeforePosition : REAL;
		tmpvalue : REAL;
		tmpvalue1 : REAL;
		periodLength : REAL;
		tmpcounter : DINT; (* Table Perioden zur SyncPosition *)
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK FB_GetCuttingMark (*TODO: Bitte Kommentar hier einfügen*) (*$GROUP=Anwender*)
	VAR_INPUT
		cuttingModuloPos : REAL;
		usercorrec : REAL;
	END_VAR
	VAR_OUTPUT
		markBefore : FB_MARK_POSITION; (* erste gültige Position vor der CuttingUnit *)
		markAfter : FB_MARK_POSITION; (* erste gültige Position nach der CuttingUnit *)
		diffToUnitBefore : REAL;
		diffToUnitAfter : REAL;
		absMarkPos : REAL; (* aktuelle, absolute Markemposition in der Maschine *)
		syncData : FB_SyncData;
		actMarkDiff : REAL;
		configError : BOOL;
	END_VAR
	VAR_IN_OUT
		uData : FB_CUTTINGUNIT_DATA;
		machineMaster : FB_AxisCtrl;
		uAxis : FB_AxisCtrl_new;
		markpoints : FB_MarkPoints;
	END_VAR
	VAR
		pMasterAxisREF : REFERENCE TO ACP10AXIS_typ;
		pSlaveAxisREF : REFERENCE TO ACP10AXIS_typ;
		myRefposition : REAL;
		tmpcounter : DINT;
		test : DINT;
		masterPos : REAL; (* Markenverschiebung zur der aufgenommenen Position *)
		unitPos : REAL; (* korrigierte Cuttingunit position *)
		absPos : REAL;
		moduloPos : REAL;
		argument : REAL;
		merker : BOOL;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK FB_SyncData (*TODO: Bitte Kommentar hier einfügen*) (*$GROUP=Anwender*)
	VAR_INPUT
		valid : BOOL;
		correction : REAL; (* aktueller Korrektur*)
		correctionNoLimit : REAL;
		diffToUnit : REAL;
		diffToUnitPeriod : DINT;
		diffToUnitSubPeriod : DINT; (* wenn Unterteilung stattfindet *)
		markIndx : DINT; (*Druckmarken Zähler dient als Trigger*)
		range : REAL := 20;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK FB_MARK_POSITION (*TODO: Bitte Kommentar hier einfügen*) (*$GROUP=Anwender*)
	VAR_INPUT
		ident : UINT; (* eindeutige Ident*)
		periodIdx : BYTE; (* Periodenorientierter Index *)
		value : LREAL;
		diff : LREAL; (* differenz zur Vorposition *)
		diff2 : LREAL; (* differenz zur 2 Vorposition *)
		valid : BOOL;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK FB_CreateCamTable (*TODO: Bitte Kommentar hier einfügen*) (*$GROUP=Anwender*)
	VAR_INPUT
		createCam : BOOL;
		AxisREF : UDINT;
		MasterAxisREF : UDINT;
		index : UINT;
	END_VAR
	VAR_OUTPUT
		MC_BR_DownloadCamProfileObj_0 : MC_BR_DownloadCamProfileObj;
		MC_CamTableSelect_0 : MC_CamTableSelect;
		err : FB_ErrorHdl;
		done : BOOL;
		camTableID : USINT;
	END_VAR
	VAR_IN_OUT
		data : FB_CUTTINGUNIT_DATA;
		scalePerimeter : FB_ScalingPerimeter;
		CONST : FB_CONST_MASCHINE;
		Name : STRING[12];
	END_VAR
	VAR
		state : INT;
		maxIdx : USINT;
		idx : USINT;
		jdx : USINT;
		partOfPerimeter : REAL; (* wenn mehrere Nutzen auf dem Zylinder dann ist es die lLänge des Bereichs*)
		partOfSync : REAL; (* synchroner Bereich *)
		MC_BR_SaveCamProfileObj_0 : MC_BR_SaveCamProfileObj;
		MC_BR_CalcCamFromSections_0 : MC_BR_CalcCamFromSections;
		MC_CAMPROFILE_TYP_0 : MC_CAMPROFILE_TYP;
		CamSections : MC_CAM_SECTIONS_TYP;
		axis1ErrorID : UDINT;
	END_VAR
	VAR CONSTANT
		STATE_READY : INT := 0;
		STATE_CALCULATE_CAM1 : INT := 10;
		STATE_CALCULATE_CAM2 : INT := 11;
		STATE_CALC_CAM_FROM_SECTIONS : INT := 20;
		STATE_SAVE_CAM_PROFILE : INT := 30;
		STATE_DOWNLOAD_CAMPROFILEDATA : INT := 40;
		STATE_CAMTABLE_SEL : INT := 50;
		STATE_COMPLETED : INT := 60;
		STATE_ERROR : INT := 99;
	END_VAR
END_FUNCTION_BLOCK
(*MC_BR_DownloadCamProfileData_0: MC_BR_DownloadCamProfileData;*)

FUNCTION_BLOCK FB_PackBelt (*TODO: Bitte Kommentar hier einfügen*) (*$GROUP=Anwender*)
	VAR_INPUT
		ctrl : FB_PackBeltCtrl;
		data : FB_PACKBELT_DATA;
		emcy_inputs : FB_SafeInputs;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK FB_PackBeltCtrl (*TODO: Bitte Kommentar hier einfügen*) (*$GROUP=Anwender*)
	VAR_INPUT
		axisREF : UDINT;
		PackBelt_HW : SdcHwCfg_typ := (0);
		PackBelt_DrvIf : SdcDrvIf16_typ := (0);
		PackBelt_DiDoIf : SdcDiDoIf_typ := (0);
		PackBelt_ModuleOk : BOOL := 0;
		PackBeltErrorAckn : BOOL;
		switchManual : BOOL;
		switchAutomatic : BOOL;
		buttonStart : BOOL;
		sensorLowerSpeed : BOOL;
		sensorStop : BOOL;
		sensorBoxesPresent : BOOL;
	END_VAR
	VAR_IN_OUT
		clk : FB_Clk;
		conveyor : FB_CONVEYOR;
		masterModul : FB_MASTERMODUL;
		panel : FB_Panel;
		data : FB_PACKBELT_DATA;
	END_VAR
	VAR
		pAxis : REFERENCE TO ACP10AXIS_typ;
		firststart : BOOL := TRUE;
		MC_BR_JogVelocity_0 : MC_BR_JogVelocity;
		MC_Power_0 : MC_Power;
		MC_Stop_0 : MC_Stop;
		MC_Reset_0 : MC_Reset;
		MC_ReadStatus_0 : MC_ReadStatus;
		Start_TP_PowerOn : BOOL;
		TP_PowerOn : TP;
		Time_Conveyor_To_Box_s : REAL;
		TON_Nitto_Table_Full : TON;
		Range_Conveyor_To_Box : REAL;
		state : USINT;
		testLowerSpeed : BOOL;
		TestStop : BOOL;
		R_TRIG_LowerSpeed : R_TRIG;
		R_TRIG_Stop : R_TRIG;
		R_TRIG_NittoTableFull : R_TRIG;
	END_VAR
	VAR CONSTANT
		ST_WAIT : USINT := 0;
		ST_MOVE_FAST : USINT := 10;
		ST_MOVE_SLOW : USINT := 20;
	END_VAR
END_FUNCTION_BLOCK
