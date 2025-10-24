(********************************************************************
 * COPYRIGHT -- Microsoft
 ********************************************************************
 * Programm: MAIN
 * Datei: FB_TurnGridUnitCtrl.st
 * Autor: awalz
 * Erstellt: 25. Juni 2014
 ********************************************************************
 * Implementierung des Programms MAIN
 ********************************************************************) 

(* TODO: Bitte Kommentar hier einfügen *)
FUNCTION_BLOCK FB_TurnGridUnitCtrl
	gridwinderright.ctrl(BetrCtrl := BetrCtrl, machineaxis := machineaxis, axis := gridwinderright.axis,
					 status := gridwinderright.status, data := gridwinderright.data);
	gridwinderleft.ctrl(BetrCtrl := BetrCtrl, machineaxis := machineaxis, axis := gridwinderleft.axis,
					 status := gridwinderleft.status,  data := gridwinderleft.data);
	refSwitchConfig(Enable := TRUE); // OKrebs // 13.04.17
	SwitchConfig.refSwitchChannelName := ADR('DigitalInput08');
	SwitchConfig.refSwitchDeviceName := ADR('SL1.IF1.ST16.IF1.ST6');
	SwitchConfig.Execute := TRUE;
	SwitchConfig();
	feeder();
	feederstatus(axisState := feeder.MC_ReadStatus_0);
	TurnGrWinKeysbox(clk := clk);
//	ac_manualTurnGrd; (*Aufruf der Action*) // OKrebs 26.04.17
 	IF feeder.MC_ReadActualPosition_0.Position > 170000 AND feeder.MC_ReadActualPosition_0.Position < 190000 AND feeder.MC_ReadStatus_0.DiscreteMotion  THEN
				gridwinderright.data.recipeData.mode := CONST.UNITMODEs.AXIS_OFF;
				gridwinderleft.data.recipeData.mode := CONST.UNITMODEs.ENABLE;
	ELSIF (feeder.MC_ReadActualPosition_0.Position > 350000 OR feeder.MC_ReadActualPosition_0.Position < 10000) AND feeder.MC_ReadStatus_0.DiscreteMotion  THEN
				gridwinderright.data.recipeData.mode := CONST.UNITMODEs.ENABLE;
				gridwinderleft.data.recipeData.mode := CONST.UNITMODEs.AXIS_OFF;
	ELSE
		
 	END_IF
 
 
 	IF TurnGrWinKeysbox.GridWinleftkey.buttonDown.LDT.button AND TurnGrWinKeysbox.GridWinleftkey.buttonDown.LDT.button AND feeder.MC_ReadStatus_0.Disabled THEN
		feeder.cmd := CONST.AXIS.POWER_ON;
	ELSIF TurnGrWinKeysbox.GridWinleftkey.buttonDown.LDT.button AND TurnGrWinKeysbox.GridWinleftkey.buttonDown.LDT.button AND feeder.MC_ReadStatus_0.Errorstop THEN
		feeder.cmd := CONST.AXIS.RESET;
	END_IF
	IF feeder.MC_ReadStatus_0.StandStill THEN
		TurnGrWinKeysbox.feederturnkey.LDT.aktion := CONST.LAMP.ON;
	ELSIF feeder.MC_ReadStatus_0.Disabled THEN
		TurnGrWinKeysbox.feederturnkey.LDT.aktion := CONST.LAMP.BLINK1000;
	ELSIF feeder.MC_ReadStatus_0.Errorstop THEN
		TurnGrWinKeysbox.feederturnkey.LDT.aktion := CONST.LAMP.BLINK200;
	END_IF
//	IF NOT feeder.MC_ReadStatus_0.Disabled THEN 
//		IF TurnGrWinKeysbox.feederturnkey.LDT.rtrig.Q THEN
//			 feeder(cmd :=  CONST.AXIS.JOG_POS, velocity := 0.024);
//			axisstep := ST_STOP;
//		ELSE 

//	IF gridwinderright.data.recipeData.mode = CONST.UNITMODEs.ENABLE THEN 
	R_TRIG_feederturnkey.CLK := TurnGrWinKeysbox.feederturnkey.LDT.button;
	R_TRIG_feederturnkey();
	
	CASE axisstep OF 

		ST_IDLE:
			IF NOT feeder.BasicControl.AxisState.Homed AND feeder.MC_ReadStatus_0.StandStill THEN // OKrebs // 13.04.17
				IF FeederHomeButton THEN
					feeder.BasicControl.Parameter.HomeMode := mcHOME_ABS_SWITCH;
					feeder.BasicControl.Parameter.HomePosition := 0.0;
					feeder(cmd := CONST.AXIS.CALIBR);
				END_IF
			ELSIF NOT panel.LDTStop.LDT.button THEN
				FeederHomeButton := FALSE;
				axisstep := ST_STOP;			
			ELSIF feeder.BasicControl.AxisState.Homed AND NOT feeder.MC_ReadStatus_0.Disabled AND NOT feeder.MC_ReadStatus_0.Homing THEN // OKrebs // 13.04.17	
				IF R_TRIG_feederturnkey.Q OR test THEN
					IF  (feeder.MC_ReadActualPosition_0.Position < 179000) OR (feeder.MC_ReadActualPosition_0.Position > 359000) THEN
						feeder(cmd :=  CONST.AXIS.SETPOS, velocity := 1.8, position := 180000);  (*Position aus Rezept*)(*5U/min/60s *360000*16666*)
						merker := TRUE;
					ELSE 
						feeder(cmd :=  CONST.AXIS.SETPOS, velocity := 1.8, position := 0);  (*Position aus Rezept*)(*5U/min/60s *360000*16666*)
						merker := TRUE;
					END_IF
				ELSIF NOT TurnGrWinKeysbox.feederturnkey.LDT.button AND merker AND NOT test THEN 
					axisstep := ST_STOP;
				END_IF	
			END_IF // OKrebs // 13.04.17
		ST_STOP: 	
			feeder(cmd := CONST.AXIS.STOP, verzoegerung := feeder.BasicControl.Parameter.Deceleration);
			merker := FALSE;
			axisstep := ST_NOACTION;

		ST_NOACTION: 
         	feeder(cmd := CONST.AXIS.NOACTION);
		 	axisstep := ST_IDLE;
	END_CASE


CASE StateCtrl OF  
		CTRL_FIRST_START:
		busy := TRUE;
		StateCtrl := CTRL_EMERGENCYSTOP_BEFORE;

	CTRL_MANUAL_BEFORE:
		IF BetrCtrl.value = CONST.MACHINEMODES.MANUAL THEN
			gridwinderright.ctrl.BetrCtrl(set := TRUE,value := CONST.MACHINEMODES.MANUAL);
			gridwinderleft.ctrl.BetrCtrl(set := TRUE,value := CONST.MACHINEMODES.MANUAL);
			IF NOT gridwinderright.ctrl.busy AND NOT gridwinderleft.ctrl.busy THEN
				BetrStatus(set := TRUE, value := BetrCtrl.value);
				busy := FALSE;  
				err(reset := TRUE);
				state := ST_IDLE;
				StateCtrl := CTRL_MANUAL;
			END_IF
		ELSIF BetrCtrl.value = CONST.MACHINEMODES.EMERGENCYSTOP THEN
			StateCtrl := CTRL_EMERGENCYSTOP_BEFORE;
		ELSIF BetrCtrl.value = CONST.MACHINEMODES.SAFETYSTOP THEN
			StateCtrl := CTRL_SAFETYSTOP_BEFORE;
		ELSIF BetrCtrl.value = CONST.MACHINEMODES.AUTOMATIC THEN
			StateCtrl := CTRL_AUTO_BEFORE;
		END_IF
	
	CTRL_MANUAL://11
		IF BetrCtrl.value <> CONST.MACHINEMODES.MANUAL THEN
			err(reset := TRUE);
			busy := TRUE;
			StateCtrl := CTRL_MANUAL_AFTER;
		ELSE
		(*	ac_manualTurnGrd; (*Aufruf der Action*)
		END_IF	
		

	CTRL_MANUAL_AFTER://12
		(*chkStatus.enable := FALSE;*)
		ac_setStateAfterUnwinder; (*Aufruf der Action*)

	CTRL_AUTO_BEFORE://20
		IF BetrCtrl.value = CONST.MACHINEMODES.AUTOMATIC THEN
			BetrStatus(set := TRUE, value := CONST.MACHINEMODES.AUTOMATIC);
			(*clamp.init(clk := clk);
			chkStatus.enable := TRUE;*)
			err(reset := TRUE);
			busy := FALSE;
			state := ST_IDLE;
			StateCtrl := CTRL_AUTO;
		ELSIF BetrCtrl.value = CONST.MACHINEMODES.EMERGENCYSTOP THEN
			StateCtrl := CTRL_EMERGENCYSTOP_BEFORE;
		ELSIF BetrCtrl.value = CONST.MACHINEMODES.SAFETYSTOP THEN
			StateCtrl := CTRL_SAFETYSTOP_BEFORE;
		ELSIF BetrCtrl.value = CONST.MACHINEMODES.MANUAL THEN
			StateCtrl := CTRL_MANUAL_BEFORE;
		END_IF

	(* ******************************** *)
	(* *********** AUTO *************** *)
	(* ******************************** *)
	CTRL_AUTO://22
		IF BetrCtrl.value <> CONST.MACHINEMODES.AUTOMATIC THEN
			err(reset := TRUE);
			busy := TRUE;
			StateCtrl := CTRL_AUTO_AFTER;
		ELSE
			(*ac_automatic();*)
		END_IF


	CTRL_AUTO_AFTER://23
		(*chkStatus.enable := FALSE;*)
		state := ST_IDLE;
		ac_setStateAfterUnwinder;

	CTRL_STOP_BEFORE://50
		IF BetrCtrl.value = CONST.MACHINEMODES.EMERGENCYSTOP THEN
			StateCtrl := CTRL_EMERGENCYSTOP_BEFORE;
		ELSIF BetrCtrl.value = CONST.MACHINEMODES.SAFETYSTOP THEN
			StateCtrl := CTRL_SAFETYSTOP_BEFORE;
		ELSE
			state := ST_IDLE;
			StateCtrl := CTRL_STOP;
		END_IF

	CTRL_STOP:
		IF BetrCtrl.value = CONST.MACHINEMODES.EMERGENCYSTOP THEN
			StateCtrl := CTRL_EMERGENCYSTOP_BEFORE;
		ELSIF BetrCtrl.value = CONST.MACHINEMODES.SAFETYSTOP THEN
			StateCtrl := CTRL_SAFETYSTOP_BEFORE;
		ELSE
			CASE state OF
			ST_IDLE:
				state := ST_QUIT;

			ST_QUIT:
				state := ST_IDLE;
				StateCtrl := CTRL_STOP_AFTER;
			END_CASE
		END_IF

	CTRL_STOP_AFTER:
		IF BetrCtrl.value = CONST.MACHINEMODES.EMERGENCYSTOP THEN
			StateCtrl := CTRL_EMERGENCYSTOP_BEFORE;
		ELSIF BetrCtrl.value = CONST.MACHINEMODES.SAFETYSTOP THEN
			StateCtrl := CTRL_SAFETYSTOP_BEFORE;
		ELSIF BetrCtrl.value = CONST.MACHINEMODES.MANUAL THEN
			StateCtrl := CTRL_MANUAL_BEFORE;
		ELSIF BetrCtrl.value = CONST.MACHINEMODES.AUTOMATIC THEN
			StateCtrl := CTRL_AUTO_BEFORE;
		END_IF

	CTRL_RESET_START:
		BetrStatus(set := TRUE, value := CONST.MACHINEMODES.RESET);
		IF BetrCtrl.value = CONST.MACHINEMODES.EMERGENCYSTOP THEN
			StateCtrl := CTRL_EMERGENCYSTOP_BEFORE;
		ELSIF BetrCtrl.value = CONST.MACHINEMODES.SAFETYSTOP THEN
			StateCtrl := CTRL_SAFETYSTOP_BEFORE;
		ELSE
			IF feeder.busy OR feeder.cmd <> CONST.AXIS.NOACTION THEN
				feeder(cmd := CONST.AXIS.NOACTION); 
			ELSE 
				feeder.cmd := CONST.AXIS.RESET;
				StateCtrl := CTRL_RESET;
			END_IF
		END_IF

	CTRL_RESET: 

		IF BetrCtrl.value = CONST.MACHINEMODES.EMERGENCYSTOP THEN
			StateCtrl := CTRL_EMERGENCYSTOP_BEFORE;
		ELSIF BetrCtrl.value = CONST.MACHINEMODES.SAFETYSTOP THEN
			StateCtrl := CTRL_SAFETYSTOP_BEFORE;
		ELSE
			(*IF NOT feeder.busy THEN*)
				feeder.cmd := CONST.AXIS.NOACTION;
				StateCtrl := CTRL_RESET_AFTER;
		(*	END_IF*)
		END_IF

	CTRL_RESET_AFTER:
		IF BetrCtrl.value = CONST.MACHINEMODES.RESET THEN
			busy := FALSE;
		ELSE
			busy := TRUE;
			(*clamp.init(clk := clk);
			err.reset();*)
			err(reset := TRUE);
			IF BetrCtrl.value = CONST.MACHINEMODES.EMERGENCYSTOP THEN
				StateCtrl := CTRL_EMERGENCYSTOP_BEFORE;
			ELSIF BetrCtrl.value = CONST.MACHINEMODES.SAFETYSTOP THEN
				StateCtrl := CTRL_SAFETYSTOP_BEFORE;
			ELSIF BetrCtrl.value = CONST.MACHINEMODES.SAFETYSTOP THEN
				StateCtrl := CTRL_SAFETYSTOP_BEFORE;
			ELSIF BetrCtrl.value = CONST.MACHINEMODES.MANUAL THEN
					supplydelay(IN:= TRUE, PT := T#8s);
				IF supplydelay.Q THEN
					feeder(cmd := CONST.AXIS.POWER_ON);
					busy := TRUE;
					supplydelay(IN:= FALSE);
					StateCtrl := CTRL_MANUAL_BEFORE;
				END_IF	
			ELSIF BetrCtrl.value = CONST.MACHINEMODES.AUTOMATIC THEN
				supplydelay(IN:= TRUE, PT := T#8s);
				IF supplydelay.Q THEN
					feeder(cmd := CONST.AXIS.POWER_ON);
					busy := TRUE;
					supplydelay(IN:= FALSE);
					StateCtrl := CTRL_AUTO_BEFORE;
				END_IF		
			END_IF
		END_IF

	CTRL_SAFETYSTOP_BEFORE://82
		IF BetrCtrl.value = CONST.MACHINEMODES.EMERGENCYSTOP THEN
			StateCtrl := CTRL_EMERGENCYSTOP_BEFORE;
		ELSE
			feeder.verzoegerung	:= CONST.AXIS.EMERGENCY_DECELERATION;
			feeder.cmd := CONST.AXIS.STOP;//24.03.15
			BetrStatus.set := TRUE;
			BetrStatus.value := CONST.MACHINEMODES.SAFETYSTOP;
			state := ST_IDLE;
			StateCtrl := CTRL_SAFETYSTOP;
		END_IF

	CTRL_SAFETYSTOP://85
		IF BetrCtrl.value = CONST.MACHINEMODES.EMERGENCYSTOP THEN
			StateCtrl := CTRL_EMERGENCYSTOP_BEFORE;
		ELSE
		BetrStatus(set := TRUE, value := CONST.MACHINEMODES.SAFETYSTOP);
			IF feeder.MC_ReadStatus_0.StandStill THEN //24.03.15
				feeder.cmd := CONST.AXIS.POWER_OFF;
			ELSIF feeder.MC_ReadStatus_0.Disabled THEN
				feeder.cmd := CONST.AXIS.NOACTION;
				StateCtrl := CTRL_SAFETYSTOP_AFTER;
			END_IF
//			CASE state OF
//			ST_IDLE:
//				IF NOT gridwinderright.ctrl.busy AND NOT gridwinderleft.ctrl.busy THEN
//					state := ST_QUIT;
//				END_IF
//			ST_QUIT:
//				state := ST_IDLE;
//				BetrStatus(set := TRUE, value := CONST.MACHINEMODES.SAFETYSTOP);
//				StateCtrl := CTRL_SAFETYSTOP_AFTER;
//			END_CASE
		END_IF

	CTRL_SAFETYSTOP_AFTER:
		busy := FALSE;
		IF BetrCtrl.value = CONST.MACHINEMODES.EMERGENCYSTOP THEN
			busy := TRUE;
			StateCtrl := CTRL_EMERGENCYSTOP_BEFORE;
		ELSIF BetrCtrl.value = CONST.MACHINEMODES.MANUAL THEN
				supplydelay(IN:= TRUE, PT := T#8s);
				IF supplydelay.Q THEN
					feeder(cmd := CONST.AXIS.POWER_ON);
					busy := TRUE;
					supplydelay(IN:= FALSE);
					StateCtrl := CTRL_MANUAL_BEFORE;
				END_IF
		ELSIF BetrCtrl.value = CONST.MACHINEMODES.AUTOMATIC THEN
				supplydelay(IN:= TRUE, PT := T#8s);
				IF supplydelay.Q THEN
					feeder(cmd := CONST.AXIS.POWER_ON);
					busy := TRUE;
					supplydelay(IN:= FALSE);
					feeder(cmd := CONST.AXIS.POWER_ON);
					StateCtrl := CTRL_AUTO_BEFORE;
				END_IF
		END_IF

	CTRL_EMERGENCYSTOP_BEFORE:
		gridwinderleft.ctrl.BetrCtrl(set := TRUE,value := CONST.MACHINEMODES.EMERGENCYSTOP);
		gridwinderright.ctrl.BetrCtrl(set := TRUE,value := CONST.MACHINEMODES.EMERGENCYSTOP);
			(*feeder.cmd := CONST.AXIS.POWER_OFF;*)//24.03.15
		feeder.verzoegerung	:= CONST.AXIS.EMERGENCY_DECELERATION;//24.03.15
		feeder.cmd := CONST.AXIS.STOP;
		IF NOT gridwinderright.ctrl.busy AND NOT gridwinderright.ctrl.busy THEN

			IF gridwinderright.ctrl.BetrStatus.value = CONST.MACHINEMODES.EMERGENCYSTOP 
				AND gridwinderleft.ctrl.BetrStatus.value = CONST.MACHINEMODES.EMERGENCYSTOP THEN
				BetrStatus(set := TRUE, value := CONST.MACHINEMODES.EMERGENCYSTOP);
				StateCtrl := CTRL_EMERGENCYSTOP;
			END_IF

		END_IF

	CTRL_EMERGENCYSTOP:
		
		IF BetrCtrl.value = CONST.MACHINEMODES.EMERGENCYSTOP THEN
			IF feeder.MC_ReadStatus_0.StandStill THEN
				feeder.cmd := CONST.AXIS.POWER_OFF;
				busy := FALSE;
			ELSIF feeder.MC_ReadStatus_0.Disabled THEN	
				feeder.cmd := CONST.AXIS.NOACTION;	
				busy := FALSE;
			END_IF
		ELSE
			busy := TRUE;
			StateCtrl:= CTRL_RESET_START;
		END_IF


	END_CASE
	feeder.BasicControl.Parameter.Deceleration	:= 59000.0; //only for initialization
	feeder.BasicControl.Parameter.Acceleration	:= 59000.0;
END_FUNCTION_BLOCK