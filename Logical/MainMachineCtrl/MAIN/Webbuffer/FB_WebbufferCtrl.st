(********************************************************************
 * COPYRIGHT -- Microsoft
 ********************************************************************
 * Programm: MAIN
 * Datei: FB_WebbufferCtrl.st
 * Autor: awalz
 * Erstellt: 26. Juni 2014
 ********************************************************************
 * Implementierung des Programms MAIN
 ********************************************************************) 

(* TODO: Bitte Kommentar hier einfügen *)
FUNCTION_BLOCK FB_WebbufferCtrl
	axis.bufferaxis(machineaxis := machineaxis, data := data, CONST := CONST, dancer := dancer, tensionoffset := torqueoffset);
	axis.refSwitchConfig(Enable := TRUE, Axis := axis.ctrl.AxisREF);
//	machineaxis();
	dancer();
	axis.ctrl();
	emcy_inputs();
	keys(clk := clk);
	torqueoffset(enable := TRUE, limitvisuneg := -50, limitvisupos := 50);

//	IF (keys.up.LDT.rtrig.Q OR keys.down.LDT.rtrig.Q ) AND axis.bufferaxis.MC_BR_VelocityControl_0.Active THEN 
//		axis.bufferaxis.cmd := CONST.AXIS.STOP;(*deaktivierung des FBs Torque*)
//	ELSIF machineaxis.MC_ReadStatus_0.ContinuousMotion THEN
//		axis.bufferaxis.cmd := CONST.AXIS.START;
//	END_IF
	(*aufruf der Action *)

	status.ready := (axis.ctrl.MC_ReadStatus_0.ContinuousMotion OR axis.ctrl.MC_ReadStatus_0.SynchronizedMotion 
				OR axis.ctrl.MC_ReadStatus_0.StandStill) AND NOT axis.ctrl.MC_ReadStatus_0.Disabled;
	status(axisState := axis.ctrl.MC_ReadStatus_0);
	IF axis.ctrl.BasicControl.AxisState.Homed AND (axis.ctrl.MC_ReadStatus_0.StandStill OR axis.ctrl.MC_ReadStatus_0.ContinuousMotion) THEN
		keys.home.LDT.aktion := CONST.LAMP.ON;
	ELSIF axis.ctrl.MC_ReadStatus_0.Disabled THEN 
		keys.home.LDT.aktion := CONST.LAMP.BLINK1000;
	ELSIF axis.ctrl.MC_ReadStatus_0.Errorstop THEN
		keys.home.LDT.aktion := CONST.LAMP.BLINK200;	
	END_IF
	IF axis.ctrl.MC_ReadStatus_0.Errorstop  AND keys.up.LDT.button AND keys.down.LDT.button THEN
		axis.ctrl(cmd := CONST.AXIS.RESET);
	END_IF
	IF (NOT emcy_inputs.EMCY_Door1 OR NOT emcy_inputs.EMCY_Door2 OR NOT emcy_inputs.EMCY_Door3 OR NOT safety.RequestSTO
		OR NOT emcy_inputs.EMCY_Door4 OR NOT emcy_inputs.EMCY_Door5 OR NOT emcy_inputs.EMCY_Door6) AND NOT  axis.ctrl.MC_ReadStatus_0.Disabled THEN
		axis.ctrl(cmd := CONST.AXIS.POWER_OFF);
		axis.bufferaxis.cmd := CONST.AXIS.STOP;
		mechbrakeON_OFF := FALSE;
	ELSIF  emcy_inputs.EMCY_Door1 AND emcy_inputs.EMCY_Door2 AND emcy_inputs.EMCY_Door3 AND emcy_inputs.EMCY_Door4 AND 
		emcy_inputs.EMCY_Door5 AND emcy_inputs.EMCY_Door6 AND axis.ctrl.MC_ReadStatus_0.Disabled AND safety.RequestSTO THEN
		axis.ctrl(cmd := CONST.AXIS.POWER_ON);
		mechbrakeON_OFF := TRUE;

	END_IF
	(* Signal um zu Joggen siehe Mastermodul ac_manual*)
	IF emcy_inputs.EMCY_Door1 AND emcy_inputs.EMCY_Door2 AND emcy_inputs.EMCY_Door3 AND emcy_inputs.EMCY_Door4 AND 
		emcy_inputs.EMCY_Door5 AND emcy_inputs.EMCY_Door6 THEN 
		emcy_inputs.EMCY_DoorsClosed := TRUE;
	ELSE
		emcy_inputs.EMCY_DoorsClosed := FALSE;
	END_IF

CASE StateCtrl OF 
	CTRL_FIRST_START:
		busy := TRUE;
		(*axis.bufferaxis.*)
		StateCtrl := CTRL_EMERGENCYSTOP_BEFORE;
	
		
	CTRL_MANUAL_BEFORE://10

		IF BetrCtrl.value = CONST.MACHINEMODES.MANUAL THEN
			BetrStatus(set := TRUE,value := CONST.MACHINEMODES.MANUAL);
			busy := FALSE;  
			err(reset := TRUE);
			timer(IN:= FALSE);
			state := ST_IDLE;
			firstStart := TRUE;
			brakeholddelay(PT := T#2s);
			IF axis.ctrl.MC_ReadStatus_0.StandStill THEN
				brakeholddelay.IN:= TRUE;	
			END_IF

			IF brakeholddelay.Q AND NOT mechbrakeON_OFF THEN
				brakeholddelay(IN:= FALSE);
				mechbrakeON_OFF := TRUE;
				StateCtrl := CTRL_MANUAL;
			ELSIF mechbrakeON_OFF THEN//25.03.15
				StateCtrl := CTRL_MANUAL;
			END_IF
		ELSIF BetrCtrl.value = CONST.MACHINEMODES.EMERGENCYSTOP THEN
			StateCtrl := CTRL_EMERGENCYSTOP_BEFORE;
		ELSIF BetrCtrl.value = CONST.MACHINEMODES.SAFETYSTOP THEN
			StateCtrl := CTRL_SAFETYSTOP_BEFORE;
		ELSIF BetrCtrl.value = CONST.MACHINEMODES.AUTOMATIC THEN 
			StateCtrl := CTRL_AUTO_BEFORE;
		END_IF
	
	CTRL_MANUAL:
		IF BetrCtrl.value <> CONST.MACHINEMODES.MANUAL THEN
			err(reset := TRUE);
			busy := TRUE;
			StateCtrl := CTRL_MANUAL_AFTER;
		ELSE
			ac_manualbufferCtrl;
			IF axis.ctrl.BasicControl.AxisState.Homed THEN 
				 acBuffercyclic; (* Aufruf der Aktion nur wenn die Achse referenziert ist 04.12.14*)
			END_IF 
		END_IF	
		
		
	CTRL_MANUAL_AFTER:
		
		 acSetModeAfterBuffer;
		
			


	CTRL_AUTO_BEFORE:
		IF BetrCtrl.value = CONST.MACHINEMODES.AUTOMATIC THEN
			BetrStatus(set := TRUE, value := CONST.MACHINEMODES.AUTOMATIC);
			(*clamp.init(clk := clk);
			chkStatus.enable := TRUE;*)
			err(reset := TRUE);
			busy := FALSE;
			state := ST_IDLE;
			brakeholddelay(PT := T#2s);
			IF axis.ctrl.MC_ReadStatus_0.StandStill THEN
				brakeholddelay.IN:= TRUE;
			END_IF
			IF brakeholddelay.Q AND NOT mechbrakeON_OFF THEN
				brakeholddelay(IN:= FALSE);
				mechbrakeON_OFF := TRUE;
				StateCtrl := CTRL_AUTO;
			ELSIF mechbrakeON_OFF THEN//25.03.15
				StateCtrl := CTRL_AUTO;
			END_IF
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
	CTRL_AUTO:
		IF BetrCtrl.value <> CONST.MACHINEMODES.AUTOMATIC THEN
			err(reset := TRUE);
			busy := TRUE;
			StateCtrl := CTRL_AUTO_AFTER;
		ELSE
			IF axis.ctrl.BasicControl.AxisState.Homed THEN 
				 acBuffercyclic; (* Aufruf der Aktion nur wenn die Achse referenziert ist 04.12.14*)
			END_IF 
			(*ac_automatic();*)
		END_IF


	CTRL_AUTO_AFTER:
		(*chkStatus.enable := FALSE;*)
		acSetModeAfterBuffer;

	CTRL_STOP_BEFORE:
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
		BetrStatus.set := TRUE;
		BetrStatus.value := CONST.MACHINEMODES.RESET;
		IF BetrCtrl.value = CONST.MACHINEMODES.EMERGENCYSTOP THEN
			StateCtrl := CTRL_EMERGENCYSTOP_BEFORE;
		ELSIF BetrCtrl.value = CONST.MACHINEMODES.SAFETYSTOP THEN
			StateCtrl := CTRL_SAFETYSTOP_BEFORE;
		ELSE
			IF axis.ctrl.busy  OR axis.ctrl.cmd <> CONST.AXIS.NOACTION THEN
			(*	axis.ctrl(cmd := CONST.AXIS.NOACTION);*)
			ELSE
				mechbrakeON_OFF := FALSE;
				axis.ctrl(cmd := CONST.AXIS.RESET);
				StateCtrl := CTRL_RESET;
			END_IF
		END_IF

	CTRL_RESET: 
		axis.ctrl();
		IF BetrCtrl.value = CONST.MACHINEMODES.EMERGENCYSTOP THEN
			StateCtrl := CTRL_EMERGENCYSTOP_BEFORE;
		ELSIF BetrCtrl.value = CONST.MACHINEMODES.SAFETYSTOP THEN
			StateCtrl := CTRL_SAFETYSTOP_BEFORE;
		ELSE
			(*IF NOT unwinderaxis.busy THEN*)
				mechbrakeON_OFF := FALSE;
				
				axis.ctrl(cmd := CONST.AXIS.POWER_OFF);
				StateCtrl := CTRL_RESET_AFTER;
			(*END_IF*)
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
			ELSIF BetrCtrl.value = CONST.MACHINEMODES.MANUAL THEN
				supplydelay(IN:= TRUE, PT := T#8s);
				IF supplydelay.Q THEN
					axis.ctrl(cmd := CONST.AXIS.POWER_ON);
					busy := TRUE;
					supplydelay(IN:= FALSE);
					StateCtrl := CTRL_MANUAL_BEFORE;
				END_IF
			ELSIF BetrCtrl.value = CONST.MACHINEMODES.AUTOMATIC THEN
				supplydelay(IN:= TRUE, PT := T#8s);
				IF supplydelay.Q THEN
					axis.ctrl(cmd := CONST.AXIS.POWER_ON);
					busy := TRUE;
					supplydelay(IN:= FALSE);
					StateCtrl := CTRL_AUTO_BEFORE;
				END_IF
			END_IF
		END_IF

	CTRL_SAFETYSTOP_BEFORE:
		IF BetrCtrl.value = CONST.MACHINEMODES.EMERGENCYSTOP THEN
			StateCtrl := CTRL_EMERGENCYSTOP_BEFORE;
		ELSE
//			BetrStatus.set := TRUE;
//			BetrStatus.value := CONST.MACHINEMODES.SAFETYSTOP;
//			mechbrakeON_OFF := FALSE;
//			axis.ctrl(cmd := CONST.AXIS.POWER_OFF);(* neue weil die Achse nicht ausgeschaltet wird*)
//			mechbrakeON_OFF := FALSE;
//			state := ST_IDLE;
//			StateCtrl := CTRL_SAFETYSTOP;
			mechbrakeON_OFF := FALSE;
			BetrStatus(set := TRUE,value := CONST.MACHINEMODES.SAFETYSTOP);
			state := ST_IDLE;
			axis.bufferaxis.cmd := CONST.AXIS.STOP;
			axis.ctrl.verzoegerung := 42000.0;
			axis.ctrl.cmd := CONST.AXIS.STOP; 
			StateCtrl := CTRL_SAFETYSTOP;
		END_IF

	CTRL_SAFETYSTOP:
		IF BetrCtrl.value = CONST.MACHINEMODES.EMERGENCYSTOP THEN
			StateCtrl := CTRL_EMERGENCYSTOP_BEFORE;
		ELSE
//			CASE state OF
//			ST_IDLE:
//				mechbrakeON_OFF := FALSE;
//			(*	axis.ctrl.cmd := CONST.AXIS.RESET;*)
//				state := ST_QUIT;
//			ST_QUIT:
//				state := ST_QUIT;
//			(*	axis.ctrl(cmd := CONST.AXIS.RESET);*)
//				StateCtrl := CTRL_SAFETYSTOP_AFTER;
//			END_CASE
			IF axis.bufferaxis.MC_ReadStatus_0.StandStill OR axis.bufferaxis.MC_ReadStatus_0.Disabled  THEN 
				axis.ctrl.cmd := CONST.AXIS.POWER_OFF;
				StateCtrl := CTRL_SAFETYSTOP_AFTER;
			END_IF 
		END_IF

	CTRL_SAFETYSTOP_AFTER:
		busy := FALSE;
		IF BetrCtrl.value = CONST.MACHINEMODES.EMERGENCYSTOP THEN
			busy := TRUE;
			StateCtrl := CTRL_EMERGENCYSTOP_BEFORE;
		ELSIF BetrCtrl.value = CONST.MACHINEMODES.MANUAL THEN
			supplydelay(IN:= TRUE, PT := T#8s);
				IF supplydelay.Q THEN
					axis.ctrl(cmd := CONST.AXIS.POWER_ON);
					busy := TRUE;
					supplydelay(IN:= FALSE);
					StateCtrl := CTRL_MANUAL_BEFORE;
				END_IF
		ELSIF BetrCtrl.value = CONST.MACHINEMODES.AUTOMATIC THEN
				supplydelay(IN:= TRUE, PT := T#8s);
				IF supplydelay.Q THEN
					axis.ctrl(cmd := CONST.AXIS.POWER_ON);
					busy := TRUE;
					supplydelay(IN:= FALSE);
					StateCtrl := CTRL_AUTO_BEFORE;
				END_IF
		END_IF

	CTRL_EMERGENCYSTOP_BEFORE:
//		axis.ctrl(cmd := CONST.AXIS.RESET);
//		mechbrakeON_OFF := FALSE;
//		BetrStatus(set := TRUE,value := CONST.MACHINEMODES.EMERGENCYSTOP);
//		busy := FALSE;
//		StateCtrl := CTRL_EMERGENCYSTOP;
		BetrStatus(set := TRUE,value := CONST.MACHINEMODES.EMERGENCYSTOP);
		mechbrakeON_OFF := FALSE;
		axis.ctrl.verzoegerung:= 1666666; (*200m/min in 2 sek*)
		axis.ctrl.cmd := CONST.AXIS.STOP;
		StateCtrl := CTRL_EMERGENCYSTOP;

	CTRL_EMERGENCYSTOP:
		IF BetrCtrl.value = CONST.MACHINEMODES.EMERGENCYSTOP THEN
			IF axis.ctrl.MC_ReadStatus_0.StandStill OR axis.ctrl.MC_ReadStatus_0.Disabled  THEN 
				axis.ctrl.cmd := CONST.AXIS.POWER_OFF;
			END_IF
		ELSE
			busy := TRUE;
			timer(IN := TRUE, PT := T#2s);
			StateCtrl := CTRL_EMERGENCYSTOP_AFTER;
		END_IF

	CTRL_EMERGENCYSTOP_AFTER:
		timer();
		IF BetrCtrl.value = CONST.MACHINEMODES.EMERGENCYSTOP THEN
			timer(IN := FALSE);
			BetrStatus(set := TRUE,value := CONST.MACHINEMODES.EMERGENCYSTOP);
			busy := FALSE;
			StateCtrl := CTRL_EMERGENCYSTOP;
		ELSIF timer.Q THEN
			timer(IN := FALSE);
			StateCtrl := CTRL_RESET_START;
		END_IF

	ELSE
		;
	END_CASE
END_FUNCTION_BLOCK