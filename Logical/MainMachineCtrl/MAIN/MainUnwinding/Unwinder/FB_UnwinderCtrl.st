(********************************************************************
 * COPYRIGHT -- Microsoft
 ********************************************************************
 * Programm: MAIN
 * Datei: FB_UnwinderCtrl.st
 * Autor: awalz
 * Erstellt: 24. Juni 2014
 ********************************************************************
 * Implementierung des Programms MAIN
 ********************************************************************) 

(* TODO: Bitte Kommentar hier einfügen *)
FUNCTION_BLOCK FB_UnwinderCtrl
	(* nicht vergessen die Sollposition des Bahnpuffers vorgeben*)
	webbuffer();(* die Lage des Bahnspeichers für die Kraftumschaltung*)
	IOs(panel := panel);(* Abfrage ob die die Maschine im Inlinemode ist*)
	unwinderaxis(machineaxis := machineaxis, data := data,startdiameter := 560);
//	unwinderaxis.WNCCalcDiam_0.actDcrPos := webbuffer.axis.ctrl.MC_ReadActualPosition_0.Position/1000;
	status.ready := (unwinderaxis.MC_ReadStatus_0.ContinuousMotion OR unwinderaxis.MC_ReadStatus_0.StandStill) AND NOT unwinderaxis.MC_ReadStatus_0.Disabled;
	status(axisState := unwinderaxis.MC_ReadStatus_0);
	(*dancer();*)
	clamp( clk := clk);
	testpos := webbuffer.axis.ctrl.MC_ReadActualPosition_0.Position;
	
	unwinderaxis.bufferUpDownKeys := webbuffer.keys.up.LDT.button OR webbuffer.keys.down.LDT.button; // Abfrage der hoch und runter Tasten des Bahnspeichers //OKrebs 16.09.14
	
	buffertofullRtrig(CLK := IOs.inline (*OR buffertofull*));
	IF IOs.inline THEN
		IF buffertofullRtrig.Q AND webbuffer.axis.ctrl.MC_ReadActualPosition_0.Position < 5800 THEN (* Position gilt noch zu definieren*)
			unwinderaxis.mode := TRUE;
		ELSIF buffertofull AND webbuffer.axis.ctrl.MC_ReadActualPosition_0.Position < 5800 THEN
			unwinderaxis.mode := TRUE;
		ELSIF  webbuffer.axis.ctrl.MC_ReadActualPosition_0.Position > 5800 THEN
			unwinderaxis.mode := FALSE;
		END_IF
	ELSE
		unwinderaxis.mode := FALSE;  
	END_IF
	IF data.recipeData.mode = CONST.UNITMODEs.ENABLE THEN  
		IF data.recipeData.warnDiam > unwinderaxis.LCRLimit_0.out  THEN
			diameterWarning := TRUE;
		ELSE 
			diameterWarning := FALSE;
		END_IF	
		IF data.recipeData.stopDiam > unwinderaxis.LCRLimit_0.out THEN
			diameterStop := TRUE;
		ELSE 
			diameterStop := FALSE;
		END_IF
//		diameterStop := SEL((data.recipeData.stopDiam > unwinderaxis.WNCCalcDiam_0.actDiam AND unwinderaxis.WNCCalcDiam_0.actDiam > 0 ), FALSE, TRUE);	
//		diameterWarning := SEL ((data.recipeData.warnDiam > unwinderaxis.WNCCalcDiam_0.actDiam AND unwinderaxis.WNCCalcDiam_0.actDiam > 0), FALSE, TRUE);	
	ELSE 
		diameterStop := FALSE;
		diameterWarning := FALSE;
	END_IF
(*	data.recipeData.mode := CONST.UNITMODEs.ENABLE; *)(* später von der Visu oder dem Rezept freigeben*)
	lift();
CASE StateCtrl OF 
	CTRL_FIRST_START:
		busy := TRUE;
		StateCtrl := CTRL_EMERGENCYSTOP_BEFORE;

	CTRL_MANUAL_BEFORE:
		IF BetrCtrl.value = CONST.MACHINEMODES.MANUAL THEN
			BetrStatus(set := TRUE,value := CONST.MACHINEMODES.MANUAL);
			busy := FALSE;  
			(*clamp.init(clk := clk);*)
			(*chkStatus.enable := TRUE;*)
			err(reset := TRUE);
			timer(IN:= FALSE);
			state := ST_IDLE;
			firstStart := TRUE;
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
		ELSE
			ac_manualUnwinderCtrl; (*Aufruf der Action*)
		END_IF	
		

	CTRL_MANUAL_AFTER:
		(*chkStatus.enable := FALSE;*)
		ac_setStateAfterUnwinder; (*Aufruf der Action*)

	CTRL_AUTO_BEFORE:
		IF BetrCtrl.value = CONST.MACHINEMODES.AUTOMATIC THEN
			BetrStatus(set := TRUE, value := CONST.MACHINEMODES.AUTOMATIC);
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
	CTRL_AUTO:
		IF BetrCtrl.value <> CONST.MACHINEMODES.AUTOMATIC THEN
			err(reset := TRUE);
			busy := TRUE;
			StateCtrl := CTRL_AUTO_AFTER;
		ELSE
			ac_automUnwinderCtrl;
		END_IF


	CTRL_AUTO_AFTER:
		(*chkStatus.enable := FALSE;*)
		state := ST_IDLE;
		ac_setStateAfterUnwinder;

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
			IF unwinderaxis.busy  OR unwinderaxis.cmd <> CONST.AXIS.NOACTION THEN
				unwinderaxis(cmd := CONST.AXIS.NOACTION, data := data, machineaxis := machineaxis, (*dancer := dancer,*) (*status := status*));
			ELSE
				unwinderaxis(cmd := CONST.AXIS.RESET, data := data, machineaxis := machineaxis, (*dancer := dancer,*)(* status := status*));
				StateCtrl := CTRL_RESET;
			END_IF
		END_IF

	CTRL_RESET: 
		unwinderaxis(machineaxis := machineaxis, data := data, (*dancer := dancer,*)(* status := status*));
		IF BetrCtrl.value = CONST.MACHINEMODES.EMERGENCYSTOP THEN
			StateCtrl := CTRL_EMERGENCYSTOP_BEFORE;
		ELSIF BetrCtrl.value = CONST.MACHINEMODES.SAFETYSTOP THEN
			StateCtrl := CTRL_SAFETYSTOP_BEFORE;
		ELSE
			(*IF NOT unwinderaxis.busy THEN*)
				unwinderaxis.cmd := CONST.AXIS.POWER_OFF;
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
//			ELSIF BetrCtrl.value = CONST.MACHINEMODES.SAFETYSTOP THEN
//				StateCtrl := CTRL_SAFETYSTOP_BEFORE;
			ELSIF BetrCtrl.value = CONST.MACHINEMODES.SAFETYSTOP THEN
				StateCtrl := CTRL_SAFETYSTOP_BEFORE;
			ELSIF BetrCtrl.value = CONST.MACHINEMODES.MANUAL THEN
			supplydelay(IN:= TRUE, PT := T#8s);
				IF supplydelay.Q THEN
					unwinderaxis.cmd := CONST.AXIS.POWER_ON;
					busy := TRUE;
					supplydelay(IN:= FALSE);
					StateCtrl := CTRL_MANUAL_BEFORE;
				END_IF
			ELSIF BetrCtrl.value = CONST.MACHINEMODES.AUTOMATIC THEN
				supplydelay(IN:= TRUE, PT := T#8s);
				IF supplydelay.Q THEN
					unwinderaxis.cmd := CONST.AXIS.POWER_ON;
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
			BetrStatus.set := TRUE;
			BetrStatus.value := CONST.MACHINEMODES.SAFETYSTOP;
			unwinderaxis.cmd := CONST.AXIS.POWER_OFF;(* neue weil die Achse nicht ausgeschaltet wird*)
			state := ST_IDLE;
			StateCtrl := CTRL_SAFETYSTOP;
		END_IF

	CTRL_SAFETYSTOP:
		IF BetrCtrl.value = CONST.MACHINEMODES.EMERGENCYSTOP THEN
			StateCtrl := CTRL_EMERGENCYSTOP_BEFORE;
		ELSE
			CASE state OF
			ST_IDLE:
				unwinderaxis.cmd := CONST.AXIS.RESET;
				state := ST_QUIT;
			ST_QUIT:
				state := ST_QUIT;
				StateCtrl := CTRL_SAFETYSTOP_AFTER;
			END_CASE
		END_IF

	CTRL_SAFETYSTOP_AFTER:
		busy := FALSE;
		IF BetrCtrl.value = CONST.MACHINEMODES.EMERGENCYSTOP THEN
			busy := TRUE;
			StateCtrl := CTRL_EMERGENCYSTOP_BEFORE;
		ELSIF BetrCtrl.value = CONST.MACHINEMODES.MANUAL THEN
			supplydelay(IN:= TRUE, PT := T#8s);
				IF supplydelay.Q THEN
					unwinderaxis.cmd := CONST.AXIS.POWER_ON;
					busy := TRUE;
					supplydelay(IN:= FALSE);
					StateCtrl := CTRL_MANUAL_BEFORE;
				END_IF
		ELSIF BetrCtrl.value = CONST.MACHINEMODES.AUTOMATIC THEN
				supplydelay(IN:= TRUE, PT := T#8s);
				IF supplydelay.Q THEN
					unwinderaxis.cmd := CONST.AXIS.POWER_ON;
					busy := TRUE;
					supplydelay(IN:= FALSE);
					StateCtrl := CTRL_AUTO_BEFORE;
				END_IF
		END_IF

	CTRL_EMERGENCYSTOP_BEFORE:
		(*axis.drvCtrl.resetRelease(ref := axis.ctrl.ref);*)
		BetrStatus(set := TRUE,value := CONST.MACHINEMODES.EMERGENCYSTOP);
		(*mode.status.set(value := CONST.MACHINEMODES.EMERGENCYSTOP);*)
		busy := FALSE;
		StateCtrl := CTRL_EMERGENCYSTOP;

	CTRL_EMERGENCYSTOP:
		unwinderaxis.cmd := CONST.AXIS.POWER_OFF;
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