(********************************************************************
 * COPYRIGHT -- Microsoft
 ********************************************************************
 * Programm: MAIN
 * Datei: ac_cyclic.st
 * Autor: Awalz
 * Erstellt: 31. März 2014
 ********************************************************************
 * Implementierung des Programms MAIN
 ********************************************************************) 

 (*<$Description$> Fügt eine neue Aktion zum IEC Programm oder Bibliothek </$Description$>*)
ACTION ac_cyclic: 
	masterModul.ctrl(axis := masterModul.axis, UnwinderUnit:= UnwinderUnit, webbuffer := webbuffer, pullbreak:= pullbreak, 
				 	cuttingunit1 := cuttingunit1, turngridwinder := turngridwinder, longcutter := longcutter, cuttingunit2 := cuttingunit2, 
					pullbreakSt := pullbreakSt, conveyor := conveyor, catchbelt := catchbelt, data:= masterModul.data, IOs := IOs, panel := panel,
					summerystartstop := (*masterModul.*)summerystartstop, (*handWheel := masterModul.handWheel,*) emcy_inputs := emcy_inputs,
					switchcabinet := switchcabinet, safety := safety, webguidingbuffer := webguidingbuffer, webguiding := webguiding, packbelt := packbelt);
///////////////////////////////////////UNWINDERUNIT///////////////////////////////////////////////////////////////////////////////////	
	UnwinderUnit.ctrl(machineaxis := masterModul.axis, unwinderOp := UnwinderUnit.unwinderOp, unwinderDrv:= UnwinderUnit.unwinderDrv, 
					splicetable := UnwinderUnit.splicetable, clk := panel.clk, IOs := IOs, feederCtrl := UnwinderUnit.feederCtrl,
					splicetable := UnwinderUnit.splicetable, clamp := UnwinderUnit.clamp, emcy_inputs:= UnwinderUnit.emcy_inputs, 
					webbuffer := webbuffer, panel := panel);
					(*unwinderDRV.ctrl.buffer := webbuffer);*)
//	hydraulicPump:= UnwinderUnit.unwinderDrv.lift.pumpe OR UnwinderUnit.unwinderOp.lift.pumpe;
	IOs.hydraulicPump := UnwinderUnit.unwinderDrv.lift.pumpe OR UnwinderUnit.unwinderOp.lift.pumpe;
///////////////////////////////////////WEBBUFFER///////////////////////////////////////////////////////////////////////////////////
	webbuffer.ctrl(machineaxis := masterModul.axis, axis := webbuffer.axis, clk := panel.clk, status := webbuffer.status, data := webbuffer.data, 
					dancer := webbuffer.dancer,	safety  := safety,  emcy_inputs:= webbuffer.emcy_inputs, keys := webbuffer.keys,  online := IOs.inline);

///////////////////////////////////////PULLBREAK///////////////////////////////////////////////////////////////////////////////////
	pullbreak.ctrl(	machineMaster := masterModul.axis, axis := pullbreak.axis, status := pullbreak.status, 
					clk := panel.clk, clamp := pullbreak.clamp ,safety := pullbreak.safety, hubctrl:= pullbreak.hubctrl, panel := panel,
					 emcy_inputs:= pullbreak.emcy_inputs);
	pullbreak.safety :=safety; (* da es nur nur in machine.input verknüpft muss es weiter gegeben werden*)

///////////////////////////////////////CUTTINGUNIT1///////////////////////////////////////////////////////////////////////////////////
	cuttingunit1.ctrl(machineMaster := masterModul.axis, axis := cuttingunit1.axis, modeCtrl := cuttingunit1.moderCtrl, 
					status := cuttingunit1.status , data := cuttingunit1.data, panel := panel,
					IOs := IOs, safety := safety, clk := panel.clk, powerbridge := cuttingunit1.powerbridge, 
					emcy_inputs:= cuttingunit1.emcy_inputs, markpoints :=cuttingunit1.markpoints);

///////////////////////////////////////TURNGRIDWINDER///////////////////////////////////////////////////////////////////////////////////
	turngridwinder.ctrl( machineaxis := masterModul.axis,  gridwinderleft := turngridwinder.gridwinderleft, 
						gridwinderright := turngridwinder.gridwinderright, feeder := turngridwinder.feeder, 
						TurnGrWinKeysbox := turngridwinder.TurnGrWinKeysbox, clk := panel.clk, panel := panel );
///////////////////////////////////////LONGCUTTER///////////////////////////////////////////////////////////////////////////////////
	longcutter.ctrl(machineMaster := masterModul.axis, axis := longcutter.axis, status := longcutter.status, data := longcutter.data, 
					cutterUp := longcutter.cutterUp, discmovesupp := longcutter.discmovesupp, 
						safety := safety, movebutton := longcutter.movebutton, clk := panel.clk, emcy_inputs:= longcutter.emcy_inputs, webclamp := longcutter.webclamp);
///////////////////////////////////////CUTTINGUNIT2///////////////////////////////////////////////////////////////////////////////////					
	cuttingunit2.ctrl(machineMaster := masterModul.axis, axis := cuttingunit2.axis, modeCtrl := cuttingunit2.moderCtrl, 
					status := cuttingunit2.status , data := cuttingunit2.data, panel := panel,
					IOs := IOs, safety := safety, clk := panel.clk, powerbridge := cuttingunit2.powerbridge, 
					emcy_inputs:= cuttingunit2.emcy_inputs, markpoints := cuttingunit2.markpoints);
///////////////////////////////////////PULLBREAK"///////////////////////////////////////////////////////////////////////////////////					
	pullbreakSt.ctrl(machineMaster := masterModul.axis, axis := pullbreakSt.axis, status := pullbreakSt.status,  panel := panel,
					clk := panel.clk, clamp := pullbreakSt.clamp ,safety := safety, hubctrl:= pullbreak.hubctrl, emcy_inputs:= pullbreakSt.emcy_inputs,);
	pullbreakSt.safety := safety;	

//	pullbreakSt.axis.setGearRatio.enable := TRUE;
//	pullbreakSt.clamp.onewayini := TRUE; (* mit einem INI*)
///////////////////////////////////////CATCHBELT///////////////////////////////////////////////////////////////////////////////////
	catchbelt.ctrl(machineMaster := masterModul.axis, axis := catchbelt.axis, status := catchbelt.status, data := catchbelt.data, safety := safety, panel := panel,
				counters := catchbelt.counters, emcy_inputs:= catchbelt.emcy_inputs);
//	catchbelt.ctrl.mode := CONST.UNITMODEs.ENABLE;
//	catchbelt.axis.setGearRatio.enable := TRUE;
///////////////////////////////////////CONVEYOR///////////////////////////////////////////////////////////////////////////////////
	conveyor.ctrl(machineMaster := masterModul.axis, axis := conveyor.axis, status := conveyor.status, data := conveyor.data, safety := safety, panel := panel,
				 counters := conveyor.counters, emcy_inputs:= conveyor.emcy_inputs);
//	conveyor.ctrl.mode := CONST.UNITMODEs.ENABLE;
//	winder.ctrl(machineMaster := masterModul.axis, winderaxis := winder.axis, data := winder.data, status := winder.status, IOs := winder.IOs);
	///////////////////////////////////////PACKBELT/////////////////////////////////////////////////////// neu // OKrebs // 23.11.16
	packbelt.ctrl(clk := panel.clk, conveyor := conveyor, masterModul := masterModul, data := packbelt.data, panel := panel);
	// ende neu
	mode(IOs := IOs, panel := panel, safety := safety, summerystartstop := summerystartstop, masterModul := masterModul); // 14.01.16 OKrebs "masterModul := masterModul" wurde dazu eingefügt
	webguiding(enable := TRUE);
	webguidingbuffer(enable := TRUE);
	IOs(panel := panel);
	panel();
	safety();
	emcy_inputs();
	summerystartstop(panel := panel, clk := panel.clk);
//	safety.ResetUserSafeMC := IOs.dIn.EmergencyStopPanel.Value.InVal AND  IOs.dIn.EmergencyStopCabinet.Value.InVal AND IOs.dIn.EmergencyStopUnwinder.Value.InVal 
//								AND IOs.dIn.EmergencyStopMiddle.Value.InVal AND IOs.dIn.EmergencyStopEndModule.Value.InVal;
//								
	IF 	gVarMachine.gMachine.Status.recipeUpdateDone THEN(* Rezepte neu laden*)
		cuttingunit1.data.newRecipe := TRUE;
		cuttingunit1.data.newTools := TRUE;
		cuttingunit2.data.newRecipe := TRUE;
		cuttingunit2.data.newTools := TRUE;
	END_IF	
	IF  mode.ctrl.value  = CONST.MACHINEMODES.MANUAL THEN
		cuttingunit1.data.loaded := TRUE;
		cuttingunit2.data.loaded := TRUE;
	ELSE 
		cuttingunit1.data.loaded := FALSE;
		cuttingunit2.data.loaded := FALSE;
	END_IF	
	pullbreakSt.hubctrl.enable := TRUE;
	IF masterModul.axis.MC_ReadStatus_0.ContinuousMotion OR (*18.03.15*)catchbelt.axis.ctrl.MC_ReadStatus_0.ContinuousMotion OR (*24.07.18* OKrebs*)conveyor.axis.ctrl.MC_ReadStatus_0.ContinuousMotion OR (*24.07.18* OKrebs*)catchbelt.axis.ctrl.MC_ReadStatus_0.SynchronizedMotion OR (*24.07.18* OKrebs*)conveyor.axis.ctrl.MC_ReadStatus_0.SynchronizedMotion THEN
		valveterminal23.0 := TRUE;(*Luftkissen Fangband*)
		alarms.alarmlist[CONST.ALARMS.CATCHBELT_NOT_COUPLED] := NOT catchbelt.axis.ctrl.MC_ReadStatus_0.SynchronizedMotion;//10.02.15
		alarms.alarmlist[CONST.ALARMS.CONVEYOR_NOT_COUPLED] := NOT conveyor.axis.ctrl.MC_ReadStatus_0.SynchronizedMotion;//10.02.15
		alarms.alarmlist[CONST.ALARMS.LONGCUT_NOT_COUPLED] := NOT longcutter.axis.ctrl.MC_ReadStatus_0.SynchronizedMotion;//10.02.15
		(*longcutter.webclamp.toDown_o := TRUE;*)
	ELSE
		valveterminal23.0 := FALSE; 
	END_IF	
/////webbuffer MOment reduuieren///
	IF IOs.inline AND UnwinderUnit.clamp.toDown_o THEN 
		webbuffer.ctrl.torquelow := TRUE; (* wenn Inlinemode dann vom <clamp abhängig weil die  BAhn anders verläuft*)
	ELSIF NOT IOs.inline AND UnwinderUnit.splicetable.clampAfter.toDown_o THEN
		webbuffer.ctrl.torquelow := TRUE;
	ELSE 
		webbuffer.ctrl.torquelow := FALSE;
	END_IF
	(*automatic close and open the webclamp on the longcutter*)
	webclamptrig(CLK:= masterModul.axis.MC_ReadStatus_0.ContinuousMotion);
	IF 	longcutter.webclamp.toDown_o THEN
		longcutter.webclamp.buttonvisu:= webclamptrig.Q;
	END_IF
	IF 	UnwinderUnit.clamp.toDown_o THEN
		UnwinderUnit.clamp.buttonvisu := webclamprClose.Q;
	END_IF
	IF UnwinderUnit.splicetable.clampAfter.toDown_o THEN
		UnwinderUnit.splicetable.clampAfter.buttonvisu := webclamprClose.Q;
	END_IF
	IF UnwinderUnit.splicetable.clampBefore.toDown_o THEN
		UnwinderUnit.splicetable.clampBefore.buttonvisu := webclamprClose.Q;
	END_IF
	webclamprClose(CLK:= masterModul.axis.MC_ReadStatus_0.StandStill);
	IF NOT longcutter.webclamp.toDown_o THEN
		longcutter.webclamp.buttonvisu:= webclamprClose.Q;
	END_IF

	unwinderOFFrtrig(CLK := webbuffer.ctrl.unwinderOFF);
	IF unwinderOFFrtrig.Q THEN (*beim Referenzieren die Wickler ausschalten damit man den Puffer verfahren kann*)
		UnwinderUnit.unwinderDrv.data.recipeData.mode:= CONST.UNITMODEs.AXIS_OFF;
		UnwinderUnit.unwinderOp.data.recipeData.mode := CONST.UNITMODEs.AXIS_OFF;
	END_IF
	

	//////Ventilinsel1//////////////////////////////
	valveterminal.0	:= UnwinderUnit.unwinderOp.clamp.toDown_o;(*richtig*)
	valveterminal.1 := UnwinderUnit.clamp.toDown_o;(*schneidtisch1 Auslauf richtig*)
	valveterminal.2 := UnwinderUnit.splicetable.clampBefore.toDown_o; 
	valveterminal.3	:= UnwinderUnit.splicetable.clampAfter.toDown_o;
	//	valveterminal.4 := 
	valveterminal.5 := webbuffer.ctrl.mechbrakeON_OFF;
	(*BUnnpufferbremse ein = valveterminal.4* und valveterminal.5 ist Bremse aus*)
	valveterminal.6 := pullbreak.clamp.toDown_o;
	valveterminal.7	:= UnwinderUnit.unwinderDrv.clamp.toDown_o;(*richtig*)
	/////Ventilinsel2 Steuerwort1//////////////////////////////
   	valveterminal2.0 := cuttingunit1.powerbridge.bridgedownbutton.toDown_o;
	valveterminal2.1 := cuttingunit2.powerbridge.bridgedownbutton.toDown_o;
	valveterminal2.2 := turngridwinder.TurnGrWinKeysbox.GridWinrightkey.toDown_o;  
	valveterminal2.3 := turngridwinder.TurnGrWinKeysbox.GridWinleftkey.toDown_o;
	valveterminal2.4 := longcutter.cutterUp.toUp_o;
	valveterminal2.5 := longcutter.cutterUp.toDown_o;
	valveterminal2.6 := longcutter.discmovesupp.toDown_o;
	valveterminal2.7 := NOT longcutter.discmovesupp.toDown_o;	
	/////Ventilinsel2 Steuerwort2//////////////////////////////
	pullbreakSt.hubctrl(clk := panel.clk);
	valveterminal22.0 := pullbreakSt.hubctrl.toUp_o;
	valveterminal22.1 := pullbreakSt.hubctrl.toDown_o;
//	valveterminal22.2 := Zahnradsperre ein
//	valveterminal22.3 := Zahnradsperre aus
	valveterminal22.4 := pullbreakSt.hubctrl.limiterBackward_o; 
	valveterminal22.5 := pullbreakSt.hubctrl.limiterForward_o;
	valveterminal22.6 := NOT cuttingunit1.powerbridge.bridgedownbutton.toDown_o;
	valveterminal22.7 := NOT cuttingunit2.powerbridge.bridgedownbutton.toDown_o;
	/////Ventilinsel2 Steuerwort3//////////////////////////////	
	valveterminal23.1 := masterModul.ctrl.sprayCtrl.valveout;
	valveterminal23.2 := NOT longcutter.webclamp.toDown_o;
	valveterminal23.3 := longcutter.webclamp.toDown_o;

	//Verknüpfen der Alarme für die Visualisierung*************************************************************
	R_TRIG_Automatic(CLK := (mode.ctrl.value  = CONST.MACHINEMODES.AUTOMATIC));
	IF R_TRIG_Automatic.Q THEN 
		IOs.ampel.hornoff := FALSE; // Damit Horn im Automatik Betrieb wieder an geht // OKrebs 17.09.14
	END_IF
	IF (UnwinderUnit.unwinderOp.ctrl.diameterWarning OR UnwinderUnit.unwinderDrv.ctrl.diameterWarning OR alarms.alarmlist[49]
		OR turngridwinder.gridwinderleft.ctrl.diameterWarning OR turngridwinder.gridwinderright.ctrl.diameterWarning OR conveyor.counters.RedLampOut) AND NOT IOs.ampel.hornoff THEN
		IOs.ampel.hornPuls.aktion := CONST.LAMP.BLINK1000;
	ELSE
		IOs.ampel.hornPuls.aktion := CONST.LAMP.OFF;
	END_IF
	IOs.ampel(clk := panel.clk);

	hornFtrig (CLK := conveyor.counters.valid OR UnwinderUnit.feederCtrl.horn );
	IF UnwinderUnit.feederCtrl.horn  THEN
		IOs.ampel.ondelay := T#12s;
		IOs.ampel.horn := TRUE;
	ELSIF conveyor.counters.valid THEN
		IOs.ampel.ondelay := T#2s;
		IOs.ampel.horn := TRUE;
	ELSIF hornFtrig.Q THEN
		IOs.ampel.horn := FALSE;
	END_IF
	
	alarms.alarmlist[CONST.ALARMS.EMCY_BUTTON_UNWINDER_OP_SIDE] := NOT UnwinderUnit.emcy_inputs.EMCY_Button1;
	alarms.alarmlist[CONST.ALARMS.EMCY_BUTTON_UNWINDER_DRV_SIDE] := NOT UnwinderUnit.emcy_inputs.EMCY_Button2;
	alarms.alarmlist[CONST.ALARMS.EMCY_BUTTON_BST] := NOT emcy_inputs.EMCY_Button1;
	alarms.alarmlist[CONST.ALARMS.EMCY_BUTTON_GRIDWINDER] := NOT emcy_inputs.EMCY_Button2;
//	alarms.alarmlist[CONST.ALARMS.EMCY_OUTSIDE_EXTRUDER] := NOT switchcabinet.EMCY_Buttons.EMCY_Button2;

	alarms.alarmlist[CONST.ALARMS.EMCY_BUTTON_LONGCUT_OP_SIDE] := NOT emcy_inputs.EMCY_Button4;
	alarms.alarmlist[CONST.ALARMS.EMCY_BUTTON_LONGCUT_DRV_SIDE] := NOT emcy_inputs.EMCY_Button3;

	alarms.alarmlist[CONST.ALARMS.EMCY_BUTTON_CONVEYOR_OP_SIDE] := NOT conveyor.emcy_inputs.EMCY_Button1;
	alarms.alarmlist[CONST.ALARMS.EMCY_BUTTON_CONVEYOR_DRV_SIDE] := NOT conveyor.emcy_inputs.EMCY_Button2;
	alarms.alarmlist[CONST.ALARMS.EMCY_BUTTON_OUTPUT] := NOT conveyor.emcy_inputs.EMCY_Button3;
	alarms.alarmlist[CONST.ALARMS.EMCY_PULLWIRE_OP_SIDE] := NOT emcy_inputs.EMCY_pullwireOPs;
	alarms.alarmlist[CONST.ALARMS.EMCY_PULLWIRE_DRV_SIDE] := NOT emcy_inputs.EMCY_pullwireDVRs;

	alarms.alarmlist[CONST.ALARMS.MASTER_NOTREADY] := NOT masterModul.ctrl.unitsStatus.ready;

	alarms.alarmlist[CONST.ALARMS.EMCY_DOOR_WEBBUFFER_OP_SIDE] := NOT webbuffer.emcy_inputs.EMCY_Door1;
	alarms.alarmlist[CONST.ALARMS.EMCY_DOOR_WEBBUFFER_DRV_SIDE] := NOT webbuffer.emcy_inputs.EMCY_Door2;
	alarms.alarmlist[CONST.ALARMS.EMCY_FRDOOR_WEBBUF_OP_SIDE_LEFT] := NOT webbuffer.emcy_inputs.EMCY_Door3;
	alarms.alarmlist[CONST.ALARMS.EMCY_FRDOOR_WEBBUF_OP_SIDE_MIDD] := NOT webbuffer.emcy_inputs.EMCY_Door4;
	alarms.alarmlist[CONST.ALARMS.EMCY_FRDOOR_WEBBUF_OP_SIDE_RIGHT] := NOT webbuffer.emcy_inputs.EMCY_Door5;
	alarms.alarmlist[CONST.ALARMS.EMCY_FRDOOR_WEBBUF_DRV_SIDE] := NOT webbuffer.emcy_inputs.EMCY_Door6;

	alarms.alarmlist[CONST.ALARMS.EMCY_DOOR_PBS1] := NOT pullbreak.emcy_inputs.EMCY_Door1;
	alarms.alarmlist[CONST.ALARMS.EMCY_DOOR_CUT1_INFEED] := NOT cuttingunit1.emcy_inputs.EMCY_Door1;
	alarms.alarmlist[CONST.ALARMS.EMCY_DOOR_CUT1_OUTFEED] := NOT cuttingunit1.emcy_inputs.EMCY_Door2;
	alarms.alarmlist[CONST.ALARMS.EMCY_DOOR_LONGCUT] := NOT longcutter.emcy_inputs.EMCY_Door1;
	alarms.alarmlist[CONST.ALARMS.EMCY_DOOR_CUT2_INFEED] := NOT cuttingunit2.emcy_inputs.EMCY_Door1;
	alarms.alarmlist[CONST.ALARMS.EMCY_DOOR_CUT2_OUTFEED] := NOT cuttingunit2.emcy_inputs.EMCY_Door2;

//	alarms.alarmlist[CONST.ALARMS.SAFETY_ERROR] := NOT emcy_inputs.EMCY_Button3;
	alarms.alarmlist[CONST.ALARMS.SAFETY_SPEED] := NOT safety.RequestSLS;

	alarms.alarmlist[CONST.ALARMS.FUSE_PLUG1] := NOT switchcabinet.fusePlug1;
	alarms.alarmlist[CONST.ALARMS.FUSE_PLUG2] := NOT switchcabinet.fusePlug2;
	alarms.alarmlist[CONST.ALARMS.FUSE_CEE_PLUG] := NOT switchcabinet.fusePlugCEE;
	alarms.alarmlist[CONST.ALARMS.FUSE_WEB_GUIDE_CONTROL_1] := NOT switchcabinet.fuseWebGuide1;
	alarms.alarmlist[CONST.ALARMS.WEB_GUIDE_CONTROL_OK_1] := webguidingbuffer.hardwareActive;
	alarms.alarmlist[CONST.ALARMS.FUSE_WEB_GUIDE_CONTROL_2] := NOT switchcabinet.fuseWebGuide2;
	alarms.alarmlist[CONST.ALARMS.WEB_GUIDE_CONTROL_OK_2] := webguiding.hardwareActive;	// OKrebs 09.12.15
	alarms.alarmlist[CONST.ALARMS.FUSE_AIR_CONDITIONING] := NOT switchcabinet.aircond;
//	alarms.alarmlist[CONST.ALARMS.AIR] := NOT emcy_inputs.EMCY_Button3;

	alarms.alarmlist[CONST.ALARMS.UNWINDER_OP_SIDE_DIAMETER_WARN] := UnwinderUnit.unwinderOp.ctrl.diameterWarning;
	alarms.alarmlist[CONST.ALARMS.UNWINDER_OP_SIDE_DIAMETER_STOP] := UnwinderUnit.unwinderOp.ctrl.diameterStop;
	alarms.alarmlist[CONST.ALARMS.UNWINDER_OP_SIDE_CLAMP] := UnwinderUnit.unwinderOp.clamp.toDown_o;
	alarms.alarmlist[CONST.ALARMS.UNWINDER_DRV_SIDE_DIAMETER_WARN] := UnwinderUnit.unwinderDrv.ctrl.diameterWarning;


	alarms.alarmlist[CONST.ALARMS.UNWINDER_DRV_SIDE_DIAMETER_STOP] := UnwinderUnit.unwinderDrv.ctrl.diameterStop;
	alarms.alarmlist[CONST.ALARMS.UNWINDER_DRV_SIDE_CLAMP] :=  UnwinderUnit.unwinderDrv.clamp.toDown_o ;
	alarms.alarmlist[CONST.ALARMS.WEBBUFFER_CLAMP_INFEED] := UnwinderUnit.clamp.toDown_o;
//	alarms.alarmlist[CONST.ALARMS.WEBBUFFER_EMPTY] := NOT emcy_inputs.EMCY_Button3;

	alarms.alarmlist[CONST.ALARMS.WEBBUFFER_NOT_REFERENCED] := NOT webbuffer.axis.ctrl.BasicControl.AxisState.Homed;
	alarms.alarmlist[CONST.ALARMS.SPLICE_TABLE_CLAMP_INFEED] := UnwinderUnit.splicetable.clampBefore.toDown_o ;
	alarms.alarmlist[CONST.ALARMS.SPLICE_TABLE_CLAMP_OUTFEED] := UnwinderUnit.splicetable.clampAfter.toDown_o;
//	alarms.alarmlist[CONST.ALARMS.LONGCUT_CLAMP] := longcutter.webclamp.toDown_o;//12.03.15
//	alarms.alarmlist[CONST.ALARMS.CUT1_DRIVE_SAFETY] := NOT emcy_inputs.EMCY_Button3;
	alarms.alarmlist[CONST.ALARMS.CUT1_NOT_REFERENCED] := NOT cuttingunit1.status.isCalibrated;	// OKrebs 09.12.15
//	alarms.alarmlist[CONST.ALARMS.GRID_TURN_FEEDER_DRIVE_SAFETY] := NOT emcy_inputs.EMCY_Button3;

	alarms.alarmlist[CONST.ALARMS.GRID_WINDDER_LEFT_DIAMETER_WARN] := turngridwinder.gridwinderleft.ctrl.diameterWarning;
	alarms.alarmlist[CONST.ALARMS.GRID_WINDDER_LEFT_DIAMETER_STOP] := turngridwinder.gridwinderleft.ctrl.diameterStop;
	alarms.alarmlist[CONST.ALARMS.GRID_WINDDER_RIGHT_DIAMETER_WARN] := turngridwinder.gridwinderright.ctrl.diameterWarning;
	alarms.alarmlist[CONST.ALARMS.GRID_WINDDER_RIGHT_DIAMETER_STOP] := turngridwinder.gridwinderright.ctrl.diameterStop;
	alarms.alarmlist[CONST.ALARMS.GRID_TURN_FEEDER_NOT_REFERENCED] := NOT turngridwinder.feeder.BasicControl.AxisState.Homed;
//	alarms.alarmlist[CONST.ALARMS.LONGCUT_DRIVE_SAFETY] := longcutter.axis.ctrl.MC_ReadStatus_0.Errorstop;
	alarms.alarmlist[CONST.ALARMS.LONGCUT_AXISERRORSTOP] := longcutter.axis.ctrl.MC_ReadStatus_0.Errorstop;

	//	alarms.alarmlist[CONST.ALARMS.CUT2_DRIVE_SAFETY] := NOT emcy_inputs.EMCY_Button3;
	alarms.alarmlist[CONST.ALARMS.CUT2_NOT_REFERENCED] := NOT cuttingunit2.status.isCalibrated; // OKrebs 09.12.15

	alarms.alarmlist[CONST.ALARMS.PULLBELT_IS_NOT_BELOW] := NOT pullbreakSt.hubctrl.isdown; // OKrebs 09.12.15
//	alarms.alarmlist[CONST.ALARMS.RECIPEDATA_NOT_LOADED] := NOT emcy_inputs.EMCY_Button3;
//	alarms.alarmlist[CONST.ALARMS.RECIPEDATA_REQUEST_TIMEOUT] := NOT emcy_inputs.EMCY_Button3;
//	alarms.alarmlist[CONST.ALARMS.RECIPEDATA_ERROR] := NOT emcy_inputs.EMCY_Button3;

		
		alarms();			
END_ACTION