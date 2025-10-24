(********************************************************************
 * COPYRIGHT -- Microsoft
 ********************************************************************
 * Programm: MAIN
 * Datei: FB_MainUnwinderCtrl.st
 * Autor: Awalz
 * Erstellt: 7. April 2014
 ********************************************************************
 * Implementierung des Programms MAIN
 ********************************************************************) 

 (*<$Description$> TODO: Bitte Kommentar hier einzufügen </$Description$>*)
FUNCTION_BLOCK FB_MainUnwinderCtrl
	unwinderOp.ctrl(BetrCtrl := BetrCtrl, machineaxis := machineaxis, unwinderaxis := unwinderOp.unwinderaxis, status := unwinderOp.status, buffertofull := buffertofull,
					 clamp := unwinderOp.clamp, lift := unwinderOp.lift, data := unwinderOp.data, clk := clk, webbuffer := webbuffer, IOs := IOs, panel := panel);
	unwinderOp.lift.enable :=  NOT unwinderDrv.lift.buttonDown AND NOT unwinderDrv.lift.buttonUp;
	unwinderDrv.ctrl(BetrCtrl := BetrCtrl,machineaxis := machineaxis, unwinderaxis := unwinderDrv.unwinderaxis,status := unwinderDrv.status, buffertofull := buffertofull,
						clamp := unwinderDrv.clamp,	lift := unwinderDrv.lift, data := unwinderDrv.data, clk := clk, webbuffer := webbuffer, IOs := IOs, panel := panel);
	unwinderDrv.lift.enable := NOT unwinderOp.lift.buttonDown AND NOT unwinderOp.lift.buttonUp;
	webbuffer();
	testpos := webbuffer.axis.ctrl.MC_ReadActualPosition_0.Position;
	feederCtrl(machineaxis := machineaxis, clk := clk);
	feederstatus(axisState := feederCtrl.MC_ReadStatus_0);
	clamp(clk := clk);
	splicetable(clk := clk); 
	emcy_inputs();
//	data.undwinderDRV.recipeData.mode := CONST.UNITMODEs.ENABLE; (* später von der Visu oder dem Rezept freigeben*)
//	data.unwinderOP.recipeData.mode := CONST.UNITMODEs.ENABLE;
//	valveterminal.0 := unwinderOp.clamp.toDown_o;
//	valveterminal.7	:= splicetable.clampAfter.toDown_o;
//	valveterminal.1 := unwinderDrv.clamp.toDown_o;
    
	IF  panel.LDTRESET.LDT.button AND feederCtrl.MC_ReadStatus_0.Errorstop THEN (* prüfen*)
		feederCtrl.cmd := CONST.AXIS.RESET;
	END_IF
	
	
	CASE StateCtrl OF  
		CTRL_FIRST_START:
		busy := TRUE;
		StateCtrl := CTRL_EMERGENCYSTOP_BEFORE;

	CTRL_MANUAL_BEFORE:
		IF BetrCtrl.value = CONST.MACHINEMODES.MANUAL THEN
			unwinderOp.ctrl.BetrCtrl(set := TRUE,value := CONST.MACHINEMODES.MANUAL);
			unwinderDrv.ctrl.BetrCtrl(set := TRUE,value := CONST.MACHINEMODES.MANUAL);
			IF NOT unwinderOp.ctrl.busy AND NOT unwinderDrv.ctrl.busy THEN
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
	
	CTRL_MANUAL:
		IF BetrCtrl.value <> CONST.MACHINEMODES.MANUAL THEN
			err(reset := TRUE);
			busy := TRUE;
			StateCtrl := CTRL_MANUAL_AFTER;
		ELSE
			ac_manualUnwinder; (*Aufruf der Action*)
		END_IF	
		

	CTRL_MANUAL_AFTER:
		(*chkStatus.enable := FALSE;*)
		ac_setStateAfterUnwinder; (*Aufruf der Action*)

	CTRL_AUTO_BEFORE:
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
	CTRL_AUTO:
		IF BetrCtrl.value <> CONST.MACHINEMODES.AUTOMATIC THEN
			err(reset := TRUE);
			busy := TRUE;
			StateCtrl := CTRL_AUTO_AFTER;
		ELSE
			ac_automUnwinder;
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
		BetrStatus(set := TRUE, value := CONST.MACHINEMODES.RESET);
		IF BetrCtrl.value = CONST.MACHINEMODES.EMERGENCYSTOP THEN
			StateCtrl := CTRL_EMERGENCYSTOP_BEFORE;
		ELSIF BetrCtrl.value = CONST.MACHINEMODES.SAFETYSTOP THEN
			StateCtrl := CTRL_SAFETYSTOP_BEFORE;
		ELSE	
			feederCtrl.cmd := CONST.AXIS.POWER_OFF ;
			StateCtrl := CTRL_RESET;
		END_IF

	CTRL_RESET: 
//		unwinderOp.unwinderaxis(machineaxis := machineaxis, dancer := unwinderOp.dancer, status := unwinderOp.status);
//		unwinderDrv.unwinderaxis(machineaxis := machineaxis, dancer := unwinderOp.dancer, status := unwinderOp.status);
		IF BetrCtrl.value = CONST.MACHINEMODES.EMERGENCYSTOP THEN
			StateCtrl := CTRL_EMERGENCYSTOP_BEFORE;
		ELSIF BetrCtrl.value = CONST.MACHINEMODES.SAFETYSTOP THEN
			StateCtrl := CTRL_SAFETYSTOP_BEFORE;
		ELSE
			StateCtrl := CTRL_RESET_AFTER;
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
					feederCtrl.cmd := CONST.AXIS.POWER_ON ;
					StateCtrl := CTRL_MANUAL_BEFORE;
			ELSIF BetrCtrl.value = CONST.MACHINEMODES.AUTOMATIC THEN
					feederCtrl.cmd := CONST.AXIS.POWER_ON ;
					StateCtrl := CTRL_AUTO_BEFORE;
			END_IF
		END_IF

	CTRL_SAFETYSTOP_BEFORE:
		IF BetrCtrl.value = CONST.MACHINEMODES.EMERGENCYSTOP THEN
			StateCtrl := CTRL_EMERGENCYSTOP_BEFORE;
		ELSE
			BetrStatus.set := TRUE;
			BetrStatus.value := CONST.MACHINEMODES.SAFETYSTOP;
			state := ST_IDLE;
			StateCtrl := CTRL_SAFETYSTOP;
		END_IF

	CTRL_SAFETYSTOP:
		IF BetrCtrl.value = CONST.MACHINEMODES.EMERGENCYSTOP THEN
			StateCtrl := CTRL_EMERGENCYSTOP_BEFORE;
		ELSE
			CASE state OF
			ST_IDLE:
				IF NOT unwinderOp.ctrl.busy AND NOT unwinderDrv.ctrl.busy THEN
					state := ST_QUIT;
				END_IF
			ST_QUIT:
				state := ST_IDLE;
				BetrStatus(set := TRUE, value := CONST.MACHINEMODES.SAFETYSTOP);
				unwinderOp.ctrl.BetrCtrl(set := TRUE,value := CONST.MACHINEMODES.SAFETYSTOP);
				unwinderDrv.ctrl.BetrCtrl(set := TRUE,value := CONST.MACHINEMODES.SAFETYSTOP);
				feederCtrl.cmd := CONST.AXIS.POWER_OFF ;
				StateCtrl := CTRL_SAFETYSTOP_AFTER;
			END_CASE
		END_IF

	CTRL_SAFETYSTOP_AFTER:
		busy := FALSE;
		IF BetrCtrl.value = CONST.MACHINEMODES.EMERGENCYSTOP THEN
			busy := TRUE;
			StateCtrl := CTRL_EMERGENCYSTOP_BEFORE;
		ELSIF BetrCtrl.value = CONST.MACHINEMODES.MANUAL THEN
//			supplydelay(IN:= TRUE, PT := T#8s);
//				IF supplydelay.Q THEN
//					unwinderOp.unwinderaxis.cmd := CONST.AXIS.POWER_ON;
//					unwinderDrv.unwinderaxis.cmd := CONST.AXIS.POWER_ON;
//					busy := TRUE;
//					supplydelay(IN:= FALSE);
					feederCtrl.cmd := CONST.AXIS.POWER_ON ;
					StateCtrl := CTRL_MANUAL_BEFORE;
		ELSIF BetrCtrl.value = CONST.MACHINEMODES.AUTOMATIC THEN
//				supplydelay(IN:= TRUE, PT := T#8s);
//				IF supplydelay.Q THEN
//					unwinderOp.unwinderaxis.cmd := CONST.AXIS.POWER_ON;
//					unwinderDrv.unwinderaxis.cmd := CONST.AXIS.POWER_ON;
//					busy := TRUE;
//					supplydelay(IN:= FALSE);
					feederCtrl.cmd := CONST.AXIS.POWER_ON ;
					StateCtrl := CTRL_AUTO_BEFORE;
		END_IF

	CTRL_EMERGENCYSTOP_BEFORE:
		unwinderOp.ctrl.BetrCtrl(set := TRUE,value := CONST.MACHINEMODES.EMERGENCYSTOP);
		unwinderDrv.ctrl.BetrCtrl(set := TRUE,value := CONST.MACHINEMODES.EMERGENCYSTOP);
		(*axis.drvCtrl.resetRelease(ref := axis.ctrl.ref);*)
		IF NOT unwinderOp.ctrl.busy AND NOT unwinderDrv.ctrl.busy THEN

			IF unwinderOp.ctrl.BetrStatus.value = CONST.MACHINEMODES.EMERGENCYSTOP 
				AND unwinderDrv.ctrl.BetrStatus.value = CONST.MACHINEMODES.EMERGENCYSTOP THEN
				BetrStatus(set := TRUE, value := CONST.MACHINEMODES.EMERGENCYSTOP);
				StateCtrl := CTRL_EMERGENCYSTOP;
			END_IF

		END_IF

	CTRL_EMERGENCYSTOP:
		IF BetrCtrl.value = CONST.MACHINEMODES.EMERGENCYSTOP THEN
			busy := FALSE;
		ELSE
			busy := TRUE;
			StateCtrl:= CTRL_RESET_START;
		END_IF


	END_CASE
	
		
END_FUNCTION_BLOCK