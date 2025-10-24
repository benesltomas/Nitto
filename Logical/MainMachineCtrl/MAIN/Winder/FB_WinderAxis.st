(********************************************************************
 * COPYRIGHT -- Microsoft
 ********************************************************************
 * Programm: MAIN
 * Datei: FB_Winder.st
 * Autor: okrebs
 * Erstellt: 6. Mai 2014
 ********************************************************************
 * Implementierung des Programms MAIN
 ********************************************************************) 

(* TODO: Bitte Kommentar hier einzufügen *)
FUNCTION_BLOCK FB_WinderAxis
	IF firststart THEN
		//**********	diameter estimation	Top winder ****************
		// set winder parameters 
		pAxis ACCESS AxisREF;
		pMasteraxisREF ACCESS machineaxis.AxisREF; 
		SysPara.minDiam			:= 80; //gMachRecipe.Winders.CoreDiam; // [mm] 
		SysPara.xDiam			:= 80; //gMachRecipe.Winders.CoreDiam; // [mm] 
		SysPara.maxDiam			:= 600; //gMachRecipe.topTandemWind.StopDiam; // [mm] 
		SysPara.minInertia		:= 1.0; // [kgm^2] 
		SysPara.xInertia		:= 1.0; // [kgm^2] 
		SysPara.gearRatio		:= data.machData.GEAR_RATIO; // [1]GEAR_RATIO_TOP_TWIND;  
		SysPara.kvTorque		:= 0.01; // [Nms] 
		SysPara.posTorque		:= 0.1; // [Nm] 
		SysPara.negTorque		:= 0.1; // [Nm] 
		SysPara.matThickness	:= 200.00; // [um] 
		SysPara.wndWidth		:= 650.00; // [mm] 
		SysPara.lineUnits		:= 1000000; // [units/m] 
		SysPara.wndUnits		:= pAxis.encoder_if.parameter.scaling.load.units; // gTWindTop.encoder_if.parameter.scaling.load.units; 	// [units] 
		SysPara.revMotor		:= pAxis.encoder_if.parameter.scaling.load.rev_motor; // gTWindTop.encoder_if.parameter.scaling.load.rev_motor; // [units] 
		SysPara.axisType		:= data.machData.axistyp; (*-1;*) // rewinder (* (-1: winder, +1: unwinder).*)
	
		EstPara.cycEstTrig 		:= 100; // [units]
		EstPara.cycEstWindow 	:= 100; // [units]
		EstPara.filterMode 		:= 2; // LQ filter
		EstPara.filterWindow 	:= 300; // 3 times cycEstTrig
	
		WNCCalcDiam_0.pSysPara	:= ADR(SysPara);
		WNCCalcDiam_0.pEstPara	:= ADR(EstPara);
		//**************************************************	
		firststart := FALSE;
	
	END_IF 	
	(********************MC_BR_READDRIVESTATUS***********************)
	MC_BR_ReadDriveStatus_0.Enable := NOT(MC_BR_ReadDriveStatus_0.Error);
	MC_BR_ReadDriveStatus_0.Axis := AxisREF;
	MC_BR_ReadDriveStatus_0.AdrDriveStatus := ADR(BasicControl.Status.DriveStatus);
	MC_BR_ReadDriveStatus_0();
	(************************ MC_READSTATUS *************************)
	MC_ReadStatus_0.Enable :=  NOT MC_ReadStatus_0.Error;
	MC_ReadStatus_0.Axis := AxisREF;
	MC_ReadStatus_0();  

	//**********	diameter estimation	top winder	******************
	MC_ReadActualPosition_0.Axis 	:= AxisREF;
	MC_ReadActualPosition_0.Enable 	:= TRUE;
	MC_ReadActualPosition_0();
	MC_ReadActualVelocity_0.Axis 	:= AxisREF;
	MC_ReadActualVelocity_0.Enable	:= TRUE;
	MC_ReadActualVelocity_0();
	machineaxis.MC_ReadActualPosition_0();
	machineaxis.MC_ReadActualVelocity_0();
	WNCCalcDiam_0.enable			:= TRUE;
	WNCCalcDiam_0.startDiam 		:= startdiameter; // estimation of start diameter in [mm]
	
	WNCCalcDiam_0.actLinePos		:=  pMasteraxisREF.monitor.s; // gMaster1.monitor.s;
	//	WNCCalcDiam_0.actLinePos		:= REAL_TO_DINT (machineaxis.MC_ReadActualPosition_0.Position); (*( masteraxisREF.monitor.s);*)
	//	WNCCalcDiam_0.actLineSpeed		:=  machineaxis.MC_ReadActualVelocity_0.Velocity;
	WNCCalcDiam_0.actLineSpeed		:= pMasteraxisREF.monitor.v;
	IF data.recipeData.reverse (*AND NOT  MC_TorqueControl_0.Active*) AND data.machData.axistyp = 1 THEN
		(*	WNCCalcDiam_0.actWndPos		:=  REAL_TO_DINT (MC_ReadActualPosition_0.Position); // gTWindTop.monitor.s;*)
		WNCCalcDiam_0.actWndPos		:= pAxis.monitor.s; //06.03.15
		WNCCalcDiam_0.actWndSpeed	:= MC_ReadActualVelocity_0.Velocity;
	ELSIF NOT data.recipeData.reverse (*AND NOT  MC_TorqueControl_0.Active*)  AND data.machData.axistyp = 1 THEN
		(*	WNCCalcDiam_0.actWndPos		:= - REAL_TO_DINT (MC_ReadActualPosition_0.Position); /*)// gTWindTop.monitor.s;
		WNCCalcDiam_0.actWndPos		:= - pAxis.monitor.s; //06.03.15
		WNCCalcDiam_0.actWndSpeed	:= -MC_ReadActualVelocity_0.Velocity;
	END_IF
	IF data.recipeData.reverse AND data.machData.axistyp = - 1 THEN
		(*WNCCalcDiam_0.actWndPos		:= -REAL_TO_DINT (MC_ReadActualPosition_0.Position);*) // gTWindTop.monitor.s;
		WNCCalcDiam_0.actWndPos		:= - pAxis.monitor.s; //06.03.15
	ELSIF NOT data.recipeData.reverse AND data.machData.axistyp = - 1 THEN	
		(*WNCCalcDiam_0.actWndPos		:= REAL_TO_DINT (MC_ReadActualPosition_0.Position);*) // gTWindTop.monitor.s;
		WNCCalcDiam_0.actWndPos		:=  pAxis.monitor.s; //06.03.15
	END_IF

	IF machineaxis.MC_ReadStatus_0.ContinuousMotion THEN (*anhalten des Durchmesserrechners*)
		WNCCalcDiam_0.hold := FALSE;
	ELSE
		WNCCalcDiam_0.hold := TRUE;
	END_IF
	WNCCalcDiam_0.mode			:= 1;(*1 = Position 2 = Speed*)
//	WNCCalcDiam_0.setStartDiam	:= TRUE; // gMachine.Status.mManualModeActive;
	WNCCalcDiam_0();
	
	LCRLimit_0.min_value				:= 90;
	LCRLimit_0.max_value				:= 600;
	LCRLimit_0.in						:= WNCCalcDiam_0.actDiam;
	LCRLimit_0();			
	
	//************************* Bahnrissüberwachung *******************
	IF machineaxis.MC_ReadStatus_0.StandStill THEN 
		IF  merker THEN 
			test1 :=  fmod(MC_ReadActualPosition_0.Position,DINT_TO_REAL (LCRLimit_0.out));
			merker := FALSE;
		END_IF
		IF 	test1 < fmod(MC_ReadActualPosition_0.Position,DINT_TO_REAL (LCRLimit_0.out)) THEN 
//	 		MC_TorqueControl_0.Execute := FALSE;
		END_IF
	ELSIF machineaxis.MC_ReadStatus_0.ContinuousMotion THEN 
			merker := TRUE;
	END_IF
	//*****************************************************************
	
	
	TC_Winder_0.ActDiameter				:= LCRLimit_0.out * SCALE_MM_TO_DRIVE_UNITS; // gMachine.Status.Diam.TUnwindTop * SCALE_MM_TO_DRIVE_UNITS;
	TC_Winder_0.EncoderIf				:= pAxis.encoder_if.parameter; // gTWindTop.encoder_if.parameter;
	TC_Winder_0.GearRatio				:= data.machData.GEAR_RATIO;
	TC_Winder_0.LineUnits				:= MACHINE_UNITS_PER_METER; 	
	//	TC_Winder_0.SetLineSpeed			:= machineaxis.MC_ReadActualVelocity_0.Velocity; (*machineaxis.velocity;*)  //AxisIf.Status.ActMasterVelocity;
	TC_Winder_0.SetLineSpeed			:= pMasteraxisREF.monitor.v;//23.03.15
	TC_Winder_0.RefDiameter[0]			:= data.machData.coreDiam; //gApplRecipe.endModule.minDiamValueTop;
//	TC_Winder_0.RefDiameter[1]			:= data.machData.stopDiam * SCALE_MM_TO_DRIVE_UNITS;//gMachRecipe.topTandemWind.StopDiam * SCALE_MM_TO_DRIVE_UNITS;
	TC_Winder_0.RefTension[0]			:= LIMIT(0, data.recipeData.minDiamTension, 80); // gApplRecipe.endModule.minDiamTensionTop;
	TC_Winder_0.RefTension[1]			:= LIMIT (0, data.recipeData.maxDiamTension, 80); //gApplRecipe.endModule.maxDiamTensionTop;
	TC_Winder_0();
	
	// Reduzierung des Momentes zum hoch und runterfahren des 

	IF NOT mode THEN (* reduzierung des Moments damit der Bahnspeicher nach oben (Füllen) fahren kann*)		
		IF data.recipeData.reverse(* AND NOT  MC_TorqueControl_0.Active*) THEN
			settorque	:= LIMIT(-80, -1 * (TC_Winder_0.SetMotorTorque + data.machData.frictionCompensation), 0);
		ELSE
			settorque	:= LIMIT (0, TC_Winder_0.SetMotorTorque + data.machData.frictionCompensation, 80);
		END_IF;
	ELSE
		IF data.recipeData.reverse  (*AND NOT  MC_TorqueControl_0.Active*) THEN
			settorque	:= LIMIT(-80, (-1 * TC_Winder_0.SetMotorTorque) + torqueoffset, 0);
		ELSE
			settorque	:= LIMIT (0, TC_Winder_0.SetMotorTorque - torqueoffset, 80);
		END_IF;
	END_IF
	
	// Reduzierung des Momentes zum hoch und runterfahren des // OKrebs 16.09.14
	IF	bufferUpDownKeys THEN
		IF data.recipeData.reverse  (*AND NOT  MC_TorqueControl_0.Active*) THEN
			settorque	:= LIMIT(-80, (-1 * TC_Winder_0.SetMotorTorque) + torqueoffset, 0);
		ELSE
			settorque	:= LIMIT (0, TC_Winder_0.SetMotorTorque - torqueoffset, 80);
		END_IF;
	END_IF
	//////////
	
	MC_TorqueControl_0.Velocity	:= TC_Winder_0.SetWndSpeed * ( 102/ 100.0) (*AxisIf.Para.WinderVeloOffsetHz*data.machData.velocityOverride  *);	
	IF ABS (MC_TorqueControl_0.Torque) <> ABS (settorque) (*AND data.recipeData.mode = CONST.UNITMODEs.ENABLE*) THEN (* wenn das Moment sich aendert muss Exucute weg genommen werden*)
		MC_TorqueControl_0.Execute := FALSE;
		cmd := CONST.AXIS.START; 
		enablemerker := TRUE;
	END_IF

	MC_TorqueControl_0.TorqueRamp := 10;
	MC_TorqueControl_0.Acceleration := 20000;
	MC_TorqueControl_0.Axis		:= AxisREF;
 	MC_TorqueControl_0.Torque	:= settorque;
(*	MC_TorqueControl_0();*)	
	IF 	(cmd = CONST.AXIS.START AND NOT MC_TorqueControl_0.InTorque )AND (MC_ReadStatus_0.StandStill OR MC_ReadStatus_0.ContinuousMotion) THEN
		(*MC_Stop_0.Execute := FALSE*);
		MC_TorqueControl_0.Execute := TRUE;
		cmdtmp := cmd;
		cmd:= CONST.AXIS.NOACTION;
	END_IF
	IF MC_TorqueControl_0.Execute AND MC_TorqueControl_0.CommandAborted AND cmdtmp = CONST.AXIS.START THEN
		MC_TorqueControl_0.Execute := FALSE;
//	ELSIF NOT MC_TorqueControl_0.Execute  AND cmdtmp = CONST.AXIS.POWER_ON AND NOT MC_TorqueControl_0.Error AND MC_ReadStatus_0.StandStill THEN
//		MC_TorqueControl_0.Execute := TRUE;
	END_IF
	MC_TorqueControl_0();	
//	IF enablemerker (*AND NOT MC_TorqueControl_0.Active*) THEN
//		MC_TorqueControl_0.Execute := TRUE;(*wieder einschalten*)
//		enablemerker := FALSE;
//	END_IF	
	IF cmd = CONST.AXIS.POWER_ON THEN 
		MC_Power_0.Enable := TRUE;
		IF MC_Power_0.Status THEN 
			cmdtmp := cmd;
			WNCCalcDiam_0.setStartDiam 		:= TRUE; // set startDiam when FB is enabled
			cmd := CONST.AXIS.NOACTION;
		END_IF
	ELSIF cmd = CONST.AXIS.POWER_OFF THEN
		MC_Power_0.Enable := FALSE;
		MC_TorqueControl_0.Execute := FALSE;
		IF NOT MC_Power_0.Status THEN
			cmdtmp := cmd;
			WNCCalcDiam_0.setStartDiam 		:= FALSE; // set startDiam when FB is enabled
			cmd:= CONST.AXIS.NOACTION;
		END_IF
	ELSIF cmd = CONST.AXIS.RESET THEN
		MC_Stop_0.Execute := FALSE;
		MC_Power_0.Enable := FALSE;
		MC_Reset_0.Execute := TRUE;
		IF MC_Reset_0.Done THEN
			MC_Reset_0.Execute := FALSE;
			cmdtmp := cmd;
			cmd:= CONST.AXIS.NOACTION;
		END_IF
		
	END_IF
	MC_Stop_0.Deceleration	:= deceleration;
	IF cmd = CONST.AXIS.STOP THEN
		IF  MC_ReadStatus_0.ContinuousMotion OR MC_ReadStatus_0.DiscreteMotion 
			OR MC_ReadStatus_0.SynchronizedMotion THEN
				MC_TorqueControl_0.Execute := FALSE;
				MC_Stop_0.Execute := TRUE;
		END_IF
		IF MC_Stop_0.Done THEN 
			MC_Stop_0.Execute := FALSE;
			cmdtmp := cmd;
			cmd := CONST.AXIS.NOACTION;
		END_IF
	END_IF
	(***************************************************************
        FUNCTION Block Calls
	(************************** MC_STOP *****************************)
	MC_Stop_0.Axis := AxisREF;
	MC_Stop_0();
	(************************** MC_POWER ****************************)
	MC_Power_0.Axis := AxisREF;  (* pointer to axis *)
	MC_Power_0();
	(************************** MC_RESET ****************************)
	MC_Reset_0.Axis := AxisREF;
	MC_Reset_0();
END_FUNCTION_BLOCK