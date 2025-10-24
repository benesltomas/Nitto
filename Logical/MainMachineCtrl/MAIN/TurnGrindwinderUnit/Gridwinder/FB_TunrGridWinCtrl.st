(********************************************************************
 * COPYRIGHT -- Microsoft
 ********************************************************************
 * Programm: MAIN
 * Datei: FB_TunrGridWinCtrl.st
 * Autor: Awalz
 * Erstellt: 5. Juni 2014
 ********************************************************************
 * Implementierung des Programms MAIN
 ********************************************************************) 

 (*<$Description$> TODO: Bitte Kommentar hier einzufügen </$Description$>*)
FUNCTION_BLOCK FB_TunrGridWinCtrl
	axis(machineaxis := machineaxis, data := data);
	axis.startdiameter := 110; (* Anfangsdurchmesser setzten*)
	status(axisState := axis.MC_ReadStatus_0);
	(*ac_manualGridWin*);
	IF data.recipeData.mode = CONST.UNITMODEs.ENABLE THEN 
		IF data.recipeData.warnDiam < axis.LCRLimit_0.out THEN
			diameterWarning := TRUE;
		ELSE 
			diameterWarning := FALSE;
		END_IF
		IF data.recipeData.stopDiam < axis.LCRLimit_0.out THEN
			diameterStop := TRUE;
		ELSE 
			diameterStop := FALSE;
		END_IF
//		diameterWarning := SEL ((data.recipeData.warnDiam < axis.WNCCalcDiam_0.actDiam AND axis.WNCCalcDiam_0.actDiam > 0), FALSE, TRUE); 
//		diameterStop := SEL((data.recipeData.stopDiam < axis.WNCCalcDiam_0.actDiam AND axis.WNCCalcDiam_0.actDiam > 0), FALSE, TRUE);	
	ELSE 
		diameterStop := FALSE;
		diameterWarning := FALSE;
	END_IF
	chkStatus(setMode := data.recipeData.mode, status := status);
//	clamp(clk := clk);
	CASE StateCtrl OF
	CTRL_FIRST_START:
		busy := TRUE;
		(*axis.ctrl.BasicControl.Command.Power := TRUE;*)
		StateCtrl := CTRL_EMERGENCYSTOP_BEFORE;
		
		
	CTRL_MANUAL_BEFORE:
		IF BetrCtrl.value = CONST.MACHINEMODES.MANUAL THEN
		(*	clamp.init(clk := clk);*)
			BetrStatus(set := TRUE, value := CONST.MACHINEMODES.MANUAL);
			chkStatus.enable := TRUE;
			err(reset := TRUE);
			busy := FALSE;
			timer(IN:= FALSE);
			state := ST_IDLE;
			manualFirst := TRUE;
			StateCtrl := CTRL_MANUAL;
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
	(*ELSIF axis.ctrl.MC_ReadStatus_0.StandStill THEN
				timer(IN := TRUE, PT := T#8s);
				IF timer.Q THEN
					ac_manualPB;
				END_IF*)
		ELSE 
			ac_manualGridWin;
		END_IF

	CTRL_MANUAL_AFTER:
		timer(IN:= FALSE);
		chkStatus.enable := FALSE;
		ac_TurnGridwinSetAfter;
		
	CTRL_AUTO_BEFORE:
		IF BetrCtrl.value = CONST.MACHINEMODES.AUTOMATIC THEN
		BetrStatus(set := TRUE, value := CONST.MACHINEMODES.AUTOMATIC);
			(*clamp.init(clk := clk);*)
			err(reset := TRUE);
			chkStatus.enable := TRUE;
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
	CTRL_AUTO:
		IF BetrCtrl.value <> CONST.MACHINEMODES.AUTOMATIC THEN
			err(reset := TRUE);
			busy := TRUE;
			StateCtrl := CTRL_AUTO_AFTER;
		ELSE
			ac_manualGridWin;
		END_IF


	CTRL_AUTO_AFTER:
		chkStatus.enable := FALSE;
		state := ST_IDLE;
		ac_setStateAfterPB;

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
		BetrStatus(set := TRUE,value := CONST.MACHINEMODES.RESET);
		IF BetrCtrl.value = CONST.MACHINEMODES.EMERGENCYSTOP THEN
			StateCtrl := CTRL_EMERGENCYSTOP_BEFORE;
		ELSIF BetrCtrl.value = CONST.MACHINEMODES.SAFETYSTOP THEN
			StateCtrl := CTRL_SAFETYSTOP_BEFORE;
		ELSE;
			IF axis.busy OR  axis.cmd <> CONST.AXIS.NOACTION THEN
				axis.cmd := CONST.AXIS.NOACTION;
			ELSE
				axis.cmd := CONST.AXIS.RESET;
				StateCtrl := CTRL_RESET;
			END_IF
		END_IF 

	CTRL_RESET:
	(*	axis.ctrl();*)
		(*axis.ctrl(cmd := CONST.AXIS.RESET);**********************)
		IF BetrCtrl.value = CONST.MACHINEMODES.EMERGENCYSTOP THEN
			StateCtrl := CTRL_EMERGENCYSTOP_BEFORE;
		ELSIF BetrCtrl.value = CONST.MACHINEMODES.SAFETYSTOP THEN
			StateCtrl := CTRL_SAFETYSTOP_BEFORE;
		ELSE
			IF NOT axis.busy AND axis.MC_ReadStatus_0.Disabled THEN
				axis.cmd := CONST.AXIS.NOACTION;
				StateCtrl := CTRL_RESET_AFTER;
			END_IF
		END_IF

	CTRL_RESET_AFTER:
		IF BetrCtrl.value = CONST.MACHINEMODES.RESET THEN
			busy := FALSE;
		ELSE
			busy := TRUE;
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
					axis.cmd := CONST.AXIS.POWER_ON;
					busy := TRUE;
					supplydelay(IN:= FALSE);
					StateCtrl := CTRL_MANUAL_BEFORE;
				END_IF
			ELSIF BetrCtrl.value = CONST.MACHINEMODES.AUTOMATIC  THEN
				supplydelay(IN:= TRUE, PT := T#8s);
				IF supplydelay.Q THEN
					axis.cmd := CONST.AXIS.POWER_ON;			
					busy := TRUE;
					supplydelay(IN:= FALSE);
					StateCtrl := CTRL_AUTO_BEFORE;
				END_IF
			END_IF
		END_IF

	CTRL_SAFETYSTOP_BEFORE:
		status.isCoupled := FALSE;
		status.ready := FALSE;
		IF BetrCtrl.value = CONST.MACHINEMODES.EMERGENCYSTOP THEN
			StateCtrl := CTRL_EMERGENCYSTOP_BEFORE;
		ELSE
			BetrStatus(set := TRUE,value := CONST.MACHINEMODES.SAFETYSTOP);
			state := ST_IDLE;
			axis.deceleration := 42000.0;
			axis.cmd := CONST.AXIS.STOP; 
			StateCtrl := CTRL_SAFETYSTOP;
		END_IF
		
	CTRL_SAFETYSTOP:
		timer(PT := T#1600ms);	
		IF BetrCtrl.value = CONST.MACHINEMODES.EMERGENCYSTOP THEN
			StateCtrl := CTRL_EMERGENCYSTOP_BEFORE;
		ELSE
			timer(IN := TRUE);
//			CASE state OF
//			ST_IDLE:
//				state := ST_QUIT;
//
//			ST_QUIT:
//				state := ST_QUIT;
//				axis.cmd := CONST.AXIS.RESET;
//				StateCtrl := CTRL_SAFETYSTOP_AFTER;
			IF  timer.Q THEN
				axis.cmd := CONST.AXIS.POWER_OFF;	
				timer(IN := FALSE);
				StateCtrl := CTRL_SAFETYSTOP_AFTER;
			END_IF
	(*		END_CASE*)
		END_IF

	CTRL_SAFETYSTOP_AFTER:
		busy := FALSE;
		manualFirst := TRUE;
		status.ready := FALSE;
		IF BetrCtrl.value = CONST.MACHINEMODES.EMERGENCYSTOP THEN
			busy := TRUE;
			StateCtrl := CTRL_EMERGENCYSTOP_BEFORE;
		ELSIF BetrCtrl.value = CONST.MACHINEMODES.MANUAL THEN
				IF axis.MC_ReadStatus_0.Errorstop THEN
					axis.cmd := CONST.AXIS.RESET;
				END_IF
				supplydelay(IN:= TRUE, PT := T#8s);
				IF supplydelay.Q THEN
					axis.cmd := CONST.AXIS.POWER_ON;
					busy := TRUE;
					supplydelay(IN:= FALSE);
					StateCtrl := CTRL_MANUAL_BEFORE;
				END_IF
		ELSIF BetrCtrl.value = CONST.MACHINEMODES.AUTOMATIC  THEN
				IF axis.MC_ReadStatus_0.Errorstop THEN
					axis.cmd := CONST.AXIS.RESET;
				END_IF
				supplydelay(IN:= TRUE, PT := T#8s);
				IF supplydelay.Q THEN
					axis.cmd := CONST.AXIS.POWER_ON;
					busy := TRUE;
					supplydelay(IN:= FALSE);
					StateCtrl := CTRL_AUTO_BEFORE;
				END_IF
		
		
		END_IF

	CTRL_EMERGENCYSTOP_BEFORE:
		status.ready := FALSE;
		axis.cmd := CONST.AXIS.POWER_OFF;
		BetrStatus(set := TRUE, value := CONST.MACHINEMODES.EMERGENCYSTOP);
		busy := FALSE;
		StateCtrl := CTRL_EMERGENCYSTOP;

	CTRL_EMERGENCYSTOP:
		IF BetrCtrl.value = CONST.MACHINEMODES.EMERGENCYSTOP THEN
			;
		ELSE
			busy := TRUE;
			timer(IN := TRUE, PT := T#2s);
			StateCtrl := CTRL_EMERGENCYSTOP_AFTER;
		END_IF

	CTRL_EMERGENCYSTOP_AFTER:
		timer();
		IF BetrCtrl.value = CONST.MACHINEMODES.EMERGENCYSTOP THEN
			timer(IN := FALSE);
			BetrStatus(set := TRUE , value := CONST.MACHINEMODES.EMERGENCYSTOP);
			busy := FALSE;
			StateCtrl := CTRL_EMERGENCYSTOP;
		ELSIF timer.Q THEN
			timer(IN := FALSE);
			StateCtrl := CTRL_RESET_START;
		END_IF

	ELSE
		;
	END_CASE


	axis.BasicControl.Parameter.Deceleration	:= 20000.0; //only for initialization
	axis.BasicControl.Parameter.Acceleration	:= 20000.0;
//	gridwinderright.axis.BasicControl.Parameter.Deceleration:= 20000.0; //only for initialization
//	gridwinderright.axis.BasicControl.Parameter.Acceleration:= 20000.0;
//	feeder.BasicControl.Parameter.Acceleration := 20000;
//	feeder.BasicControl.Parameter.Deceleration := 20000;
END_FUNCTION_BLOCK