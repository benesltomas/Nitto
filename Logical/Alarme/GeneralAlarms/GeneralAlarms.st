(********************************************************************
 * COPYRIGHT --  
 ********************************************************************
 * Programm: GeneralAlarms
 * Datei: GeneralAlarms.st
 * Autor: jkappelt
 * Erstellt: 3. Oktober 2012
 ********************************************************************
 * Implementierung des Programms GeneralAlarms
 ********************************************************************)

PROGRAM _INIT


(* TODO : Code hier einfügen *)


END_PROGRAM


PROGRAM _CYCLIC
// Reset Alarme
	IF gMachine.IO.DIn.LDT_FaultReset.Value.InVal THEN
		gMachine.Command.AutoStopRequestAlarm := FALSE;	//reset stop request
		FOR i := 0 TO 23 BY 1 DO
			GeneralAlarm[i] := 0;
			AlarmWinder[i]	:= 0;
		END_FOR;		
	END_IF;
			
//	
//	IF 	NOT	gMachine.IO.DIn.PressureCtrl.Value.InVal AND gMachine.IO.DIn.LDT_Reset.Value.State AND  AxisIf.Status.drivesEnabled THEN	
//		GeneralAlarm[ALARM_PRESSURE_LOW] := TRUE;
//	END_IF;
	GeneralAlarm[ALARM_FUSE_BST] :=	NOT	gMachine.IO.DIn.FuseBTS.Value.InVal;
	GeneralAlarm[ALARM_FUSE_QW258] :=	NOT	gMachine.IO.DIn.FuseQW258_262.Value.InVal;
//	GeneralAlarm[3] :=	NOT	gMachine.IO.DIn.FuseQW264_268.Value.InVal;
	// GeneralAlarm[4]:= siehe unten
	GeneralAlarm[ALARM_ESTOP_CABINET] := NOT gMachine.IO.DIn.EmergencyStopCabinet.Value.InVal;
	GeneralAlarm[ALARM_ESTOP_PANEL] := NOT gMachine.IO.DIn.EmergencyStopPanel.Value.InVal;
	GeneralAlarm[ALARM_ESTOP_UNWINDER] := NOT gMachine.IO.DIn.EmergencyStopUnwinder.Value.InVal;
	GeneralAlarm[ALARM_ESTOP_MIDDLE] := NOT gMachine.IO.DIn.EmergencyStopMiddle.Value.InVal;
	GeneralAlarm[ALARM_ESTOP_ENDMODULE] := NOT gMachine.IO.DIn.EmergencyStopEndModule.Value.InVal;
	GeneralAlarm[ALARM_ESTOP_BOOKLET] := NOT gMachine.IO.DIn.EmergencyStopBooklet.Value.InVal;
	
	//	GeneralAlarm[9] := NOT	gMachine.IO.DIn.EmergencyStopTandemWinder.Value.InVal;
	
//	GeneralAlarm[ALARM_FUSE_COOLER_UNWINDER] :=	NOT	gMachine.IO.DIn.FuseFanUnwind.Value.InVal ; 
	
	GeneralAlarm[ALARM_PLUG1] :=	NOT	gMachine.IO.DIn.FusePlug1.Value.InVal;
	GeneralAlarm[ALARM_PLUG2] :=	NOT	gMachine.IO.DIn.FusePlug2.Value.InVal;
	GeneralAlarm[ALARM_PLUGCEE] :=	NOT	gMachine.IO.DIn.FusePlugCEE.Value.InVal;
	GeneralAlarm[ALARM_FUSE_BOOKLET] :=	NOT	gMachine.IO.DIn.FuseBookletFeeder.Value.InVal;
	GeneralAlarm[ALARM_SAFEDOOR_BOOKLET] :=	NOT	gMachine.IO.DIn.SafetyDoorBooklet.Value.InVal AND gMachine.IO.DIn.EmergencyStopBooklet.Value.InVal;
	GeneralAlarm[ALARM_ESTOP_PULLWIRE] :=	NOT	gMachine.IO.DIn.EmergencyStopPullWire.Value.InVal;

	//	GeneralAlarm[ALARM_HVOLT_ANTISTATIC] :=	NOT	gMachine.IO.DIn.HighVoltageGenerator.Value.InVal; 

//	GeneralAlarm[ALARM_BST_NREADY] 		:= NOT	gMachine.IO.DIn.BST_OK.Value.InVal;
	GeneralAlarm[ALARM_SAFEDOOR_PUNCH1] := NOT gMachine.IO.DIn.SafetyDoorInfeedCut1.Value.InVal OR NOT gMachine.IO.DIn.SafetyDoorOutfeedCut1.Value.InVal;
	GeneralAlarm[ALARM_SAFEDOOR_PUNCH2] := NOT gMachine.IO.DIn.SafetyDoorInfeedCut2.Value.InVal OR NOT gMachine.IO.DIn.SafetyDoorOutfeedCut2.Value.InVal;
//	GeneralAlarm[ALARM_SAFEDOOR_PUNCH3] := NOT gMachine.IO.DIn.SafetyDoorInfeedCut3.Value.InVal OR NOT gMachine.IO.DIn.SafetyDoorOutfeedCut3.Value.InVal;
	GeneralAlarm[ALARM_SAFEDOOR_LONGCUT]:= NOT gMachine.IO.DIn.SafetyDoorLongCut.Value.InVal;
//	GeneralAlarm[ALARM_FUSE_LAMINATOR]	:= NOT gMachine.IO.DIn.Fuse_Laminator.Value.InVal;
	GeneralAlarm[ALARM_WEB_BREAK]		:= gMachine.Status.WebBreakLabeler;
	
	Speed_machine := REAL_TO_INT(gVisu.Status.ActVelocity /1000);

	IF Speed_machine <= 1 THEN
		Machine_Stop := 0;
	ELSE
		Machine_Stop := 1;
	END_IF;
	
	
	
	//reset Button am Panel Setz Fehler nummer zurück

	IF gMachine.IO.DIn.LDT_FaultReset.Value.InVal THEN	
		IF gMachine.IO.DIn.LDT_FaultReset.Value.InVal THEN
			AlarmUnwinder[1]:=0;
			AlarmEndModul[4] := 0;
			AlarmEndModul[5] := 0;
			GeneralAlarm[4] := 0;
		END_IF ;
	
	END_IF;
	//********************	Safety Status auf Panel anzeigen  *********************************************************
	IF (gMachine.Safety.RequestSTO) THEN
		StatusSafety	:=	STATUS_CONTVOL_OFF;
	ELSIF (gMachine.Safety.RequestSLS) THEN
		StatusSafety	:=	STATUS_SLS;
	ELSE
		StatusSafety	:=	STATUS_SAFETY_OK;
	END_IF;		
	//******************************************************************************************************************
	
	//********************	Stop-Anforderung durch Unterschreitung des min. Durchmessers Unwinder!!	********************
	TON_LowDiamUnwinder.PT	:= T#2s;
	TON_LowDiamUnwinder.IN	:= (gMachine.Status.CalcDiam.MainUnwind < gMachRecipe.mainUnwind.StopDiam) AND gMachine.Status.mAutoModeActive AND gApplRecipe.dancer.radiusCtrlOn;
	TON_LowDiamUnwinder();
	
	IF 	(TON_LowDiamUnwinder.Q) THEN
		gMachine.Command.AutoStopRequestAlarm := TRUE;
		AlarmUnwinder[1]:=1;
	END_IF;
	//****************************************************************************************************
	

	//** Splicetable Unwinder ******************************************************)
	IF gMachine.IO.DOut.VentCutTabOutfeedMoveUpDn.Value.State OR gMachine.IO.DOut.VentCutTabInfeedMoveUpDn.Value.State THEN 
		AlarmUnwinder[5]:= TRUE;
	END_IF
		
	//********************	Stop-Anforderung durch Überschreitung des max. Durchmessers Tandemwickler!!	********************
//	TON_HighDiamTWindTop.PT	:= T#3s;
//	TON_HighDiamTWindTop.IN	:= (gMachine.Status.Diam.TUnwindTop > gMachRecipe.topTandemWind.StopDiam) AND AxisIf.Status.isMoving;
//	TON_HighDiamTWindTop();
//	
//	IF (TON_HighDiamTWindTop.Q) THEN
//		gMachine.Command.AutoStopRequestAlarm := TRUE;
//		AlarmEndModul[4] := 1;
//	END_IF;
//
//	TON_HighDiamTWindBot.PT	:= T#3s;
//	TON_HighDiamTWindBot.IN	:= (gMachine.Status.Diam.TUnwindBot > gMachRecipe.botTandemWind.StopDiam) AND AxisIf.Status.isMoving;
//	TON_HighDiamTWindBot();
//	
//	IF 	(TON_HighDiamTWindBot.Q) THEN
//		gMachine.Command.AutoStopRequestAlarm := TRUE;
//		AlarmEndModul[5] := 1;
//	END_IF;	
	//****************************************************************************************************
	
    
	
	//********************	Stop-Anforderung der Aufwickler und Abwickler!!	********************
	
	// Spender //
	// Stop-Anforderung durch Überschreitung des min. Durchmessers Aufwickler!!
	IF 	gMachine.Status.Diam.Spend1	 > gMachRecipe.spender1.StopDiam AND (gApplRecipe.spender1.mode = 1)  THEN
		gMachine.Command.AutoStopRequestAlarm := TRUE;
		AlarmWinder[0] := 1;
	END_IF;
	// Stop-Anforderung durch Unterschreitung des min. Durchmessers Abwickler!!
	IF 	gMachine.Status.Diam.Spend2 < gMachRecipe.spender2.StopDiam  AND  (gApplRecipe.spender1.mode = 1) THEN
		gMachine.Command.AutoStopRequestAlarm := TRUE;	
		AlarmWinder[1] := 1;
	END_IF;
	
	// Laminierer //
	// Stop-Anforderung durch Unterschreitung des min. Durchmessers Abwickler!!
	IF 	gMachine.Status.Diam.Laminator1 < gMachRecipe.laminator1.StopDiam  AND (gApplRecipe.laminator2.mode = 36 )  THEN
		gMachine.Command.AutoStopRequestAlarm := TRUE;
		AlarmWinder[2] := 1;
	END_IF;
	// Stop-Anforderung durch Überschreitung des min. Durchmessers Aufwickler!!
	IF 	gMachine.Status.Diam.Laminator2	 > gMachRecipe.laminator2.StopDiam AND (gApplRecipe.laminator2.mode = 36 )  THEN
		gMachine.Command.AutoStopRequestAlarm := TRUE;	
		AlarmWinder[3] := 1;
	END_IF;
	
	// Gitteraufwickler 1 //
	// Stop-Anforderung durch Überschreitung des min. Durchmessers Aufwickler!!
	IF 	gMachine.Status.Diam.Grid1	 > gMachRecipe.grid1.StopDiam AND (gApplRecipe.grid1.mode = 36)  THEN
		gMachine.Command.AutoStopRequestAlarm := TRUE;
		AlarmWinder[4] := 1;
	END_IF;
	// Gitteraufwickler 2 //
	// Stop-Anforderung durch Überschreitung des min. Durchmessers Aufwickler!!
	IF 	gMachine.Status.Diam.Grid2	 > gMachRecipe.grid2.StopDiam AND (gApplRecipe.grid2.mode = 36)  THEN
		gMachine.Command.AutoStopRequestAlarm := TRUE;
		AlarmWinder[5] := 1;
	END_IF;
	//****************************************************************************************************
	
	//********************	Stop-Anforderung durch Unterschreitung der Bahnspannung!!	********************
//	TON_LowTension.PT	:= T#1s;
//	TON_LowTension.IN	:= 
//	(gMachine.IO.AIn.FlengeDMS.Value.Scaled < 5.0)
//	AND gMachine.Status.mAutoModeActive
//	AND AxisHandle[AXIS_PULL_BRAKE_ST1].Data.config.IS_ACTIVE;
	
	TON_LowTension();
	
	IF (TON_LowTension.Q) THEN
		gMachine.Command.AutoStopRequestAlarm := TRUE;
		GeneralAlarm[4] := 1;
	END_IF;	
	//****************************************************************************************************

	//********************	Stop-Anforderung durch Bahnriss am Spender!!	********************
	IF (gMachine.Status.WebBreakLabeler) THEN
		gMachine.Command.AutoStopRequestAlarm := TRUE;
		GeneralAlarm[21] := 1;
	END_IF;	
	//****************************************************************************************************
	
	// Warnung Regelung der Abwicklung nicht aktiv
	IF (gApplRecipe.mainUnwind.mode = 0) THEN
		AlarmUnwinder[11]:=1;
	END_IF	
	//*******************************************************************************************************
	
	// Erzeugung der Vorwarnungen für min. und max. Diameter
	
	// Reset Warnmeldungen
	IF gMachine.IO.DIn.LDT_FaultReset.Value.InVal THEN
		AlarmUnwinder[10]:=0;
		AlarmUnwinder[11]:=0;
	
		AlarmEndModul[10] := 0;
		AlarmEndModul[11] := 0;
	END_IF ;
	// Warnnung max. Durchmessers!!
	IF 	(gMachine.Status.CalcDiam.MainUnwind < gMachRecipe.mainUnwind.WarnDiam) AND gMachine.Status.mAutoModeActive
		AND gApplRecipe.dancer.radiusCtrlOn THEN
		AlarmUnwinder[10]:=1;
	END_IF;
	

//	// Warnnung max. Durchmessers!!
//	IF 	(gMachine.Status.Diam.TUnwindTop	 > gMachRecipe.topTandemWind.WarnDiam) AND  AxisIf.Status.isMoving AND	
//		((gApplRecipe.endModule.mode = 41) OR (gApplRecipe.endModule.mode = 43)) THEN
//		AlarmEndModul[10] := 1;
//	END_IF;
//	// Warnnung max. Durchmessers!!
//	IF 	(gMachine.Status.Diam.TUnwindBot> gMachRecipe.botTandemWind.WarnDiam) AND  AxisIf.Status.isMoving AND
//		((gApplRecipe.endModule.mode = 42) OR (gApplRecipe.endModule.mode = 43)) THEN
//		AlarmEndModul[11] := 1;
//	END_IF;	
//	

END_PROGRAM
