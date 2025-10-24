(********************************************************************
 * COPYRIGHT -- Microsoft
 ********************************************************************
 * Programm: MAIN
 * Datei: FB_ConveyorCtrl.st
 * Autor: Awalz
 * Erstellt: 12. Mai 2014
 ********************************************************************
 * Implementierung des Programms MAIN
 ********************************************************************) 

 (*<$Description$> TODO: Bitte Kommentar hier einzufügen </$Description$>*)
FUNCTION_BLOCK FB_ConveyorCtrl
	axis.ctrl();
//	mode := CONST.UNITMODEs.ENABLE;
	chkStatus(setMode := mode, status := status);
	(*axis.setGearRatio();*)
	axis.setGearRatio(limitvisuneg := -80, limitvisupos :=400(*700*), limitrationeg := 1000, limitratiopos := 5000);
	emcy_inputs();
	panel();
	counters();
	status(axisState := axis.ctrl.MC_ReadStatus_0);
	status.ready := axis.ctrl.MC_ReadStatus_0.SynchronizedMotion;
 //24.07.18 //OKrebs // Falls das Band sich nicht mehr manuell bewegen laesst
	IF (config.state = 40) AND visuReset AND config.busy THEN
		axis.MC_BR_Phasing_0.Enable := FALSE;
		config.state := 0;
		config.busy := FALSE;
	END_IF
/////////////////////////////////////
	IF axis.ctrl.MC_ReadStatus_0.Errorstop AND panel.LDTRESET.LDT.button THEN
		axis.ctrl.cmd := CONST.AXIS.RESET;
		status.isCoupled := FALSE; // OKrebs // 24.07.18
		manualFirst	:= TRUE; // OKrebs // 24.07.18
	ELSIF axis.ctrl.MC_ReadStatus_0.Disabled AND panel.LDTRESET.LDT.ftrig.Q AND cmdCtrl.value = CONST.AXIS.NOACTION THEN
		axis.ctrl.cmd := CONST.AXIS.NOACTION;
	END_IF

	IF (*axis.ctrl.MC_ReadStatus_0.SynchronizedMotion AND*) axis.setGearRatio.enable THEN 
	axis.cplOn(RatioNumerator := axis.setGearRatio.ratioNumeratorOut,
			Execute := axis.setGearRatio.trigger ,RatioDenominator := axis.setGearRatio.ratioDenominator,
			Acceleration := 40000, Deceleration := 40000);
	END_IF
	CASE StateCtrl OF
	CTRL_FIRST_START:
		busy := TRUE;
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
			(*manualFirst := TRUE;*)
			axis.ctrl.BasicControl.Parameter.Deceleration	:= 100000.0;
			axis.ctrl.BasicControl.Parameter.Acceleration	:= 100000.0;
//			axis.setGearRatio.init := TRUE; // OKrebs 09.12.15
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
//		ELSIF axis.ctrl.MC_ReadStatus_0.StandStill THEN
//			axis.ctrl.cmd := CONST.AXIS.START;
//				timer(IN := TRUE, PT := T#8s);
//				IF timer.Q THEN
		ELSE
				ac_manualConv;
		END_IF
		(*ELSE 
			StateCtrl := CTRL_RESET_START;*)
		(*END_IF*)

	CTRL_MANUAL_AFTER:
		timer(IN:= FALSE);
		chkStatus.enable := FALSE;
		axis.ctrl.cmd := CONST.AXIS.NOACTION;
		ac_setStateAfterPB;
		
	CTRL_AUTO_BEFORE:
		IF BetrCtrl.value = CONST.MACHINEMODES.AUTOMATIC THEN
		BetrStatus(set := TRUE, value := CONST.MACHINEMODES.AUTOMATIC);
			(*clamp.init(clk := clk);*)
			err(reset := TRUE);
			chkStatus.enable := TRUE;
			busy := FALSE;
			state := ST_IDLE;
			axis.ctrl.BasicControl.Parameter.Deceleration	:= 100000.0;
			axis.ctrl.BasicControl.Parameter.Acceleration	:= 100000.0;
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
			;(*ac_automatic();*)
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
		ELSE
			IF axis.ctrl.busy OR axis.ctrl.cmd <> CONST.AXIS.NOACTION  THEN
				axis.ctrl(cmd := CONST.AXIS.NOACTION);
//			ELSIF axis.ctrl.MC_ReadStatus_0.Disabled THEN
//				axis.ctrl(cmd := CONST.AXIS.RESET); 
//				StateCtrl := CTRL_RESET;
			ELSE
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
//			IF NOT axis.ctrl.busy THEN (* auskommentiert am 26.06..14*)
//				axis.ctrl(cmd := CONST.AXIS.NOACTION);
//				StateCtrl := CTRL_RESET_AFTER;
//			END_IF
			axis.ctrl(cmd := CONST.AXIS.POWER_OFF);
			StateCtrl := CTRL_RESET_AFTER;
		END_IF

	CTRL_RESET_AFTER:
		IF BetrCtrl.value = CONST.MACHINEMODES.RESET THEN
			busy := FALSE;
		ELSE
			busy := TRUE;
		(*	clamp.init(clk := clk);*)
			err(reset := TRUE);
			manualFirst := TRUE;
			IF BetrCtrl.value = CONST.MACHINEMODES.EMERGENCYSTOP THEN
				StateCtrl := CTRL_EMERGENCYSTOP_BEFORE;
			ELSIF BetrCtrl.value = CONST.MACHINEMODES.SAFETYSTOP THEN
				StateCtrl := CTRL_SAFETYSTOP_BEFORE;
			ELSIF BetrCtrl.value = CONST.MACHINEMODES.SAFETYSTOP THEN
				StateCtrl := CTRL_SAFETYSTOP_BEFORE;
			ELSIF BetrCtrl.value = CONST.MACHINEMODES.MANUAL  AND safety.valid THEN
				supplydelay(IN:= TRUE, PT := T#8s);
				IF supplydelay.Q THEN
					axis.ctrl(cmd := CONST.AXIS.POWER_ON);
					busy := TRUE;
					supplydelay(IN:= FALSE);
					StateCtrl := CTRL_MANUAL_BEFORE;
				END_IF
			ELSIF BetrCtrl.value = CONST.MACHINEMODES.AUTOMATIC  AND safety.valid THEN
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
		status.isCoupled := FALSE;
		status.ready := FALSE;
//		IF BetrCtrl.value = CONST.MACHINEMODES.EMERGENCYSTOP THEN
//			StateCtrl := CTRL_EMERGENCYSTOP_BEFORE;
//		ELSE
//			BetrStatus(set := TRUE,value := CONST.MACHINEMODES.SAFETYSTOP);
//			state := ST_IDLE;
//			axis.ctrl.verzoegerung	:= 1600000.0;
//			axis.ctrl(cmd := CONST.AXIS.STOP); 
//			StateCtrl := CTRL_SAFETYSTOP;
			//		END_IF	status.isCoupled := FALSE;
		//12.03.15
		IF BetrCtrl.value = CONST.MACHINEMODES.EMERGENCYSTOP THEN
				StateCtrl := CTRL_EMERGENCYSTOP_BEFORE;
		ELSE
			BetrStatus(set := TRUE,value := CONST.MACHINEMODES.SAFETYSTOP);
			state := ST_IDLE;
			manualFirst := FALSE;
			axis.ctrl.verzoegerung	:= CONST.AXIS.EMERGENCY_DECELERATION;
			axis.ctrl.cmd := CONST.AXIS.STOP; 
			StateCtrl := CTRL_SAFETYSTOP;
		END_IF		

		CTRL_SAFETYSTOP:
	
		IF BetrCtrl.value = CONST.MACHINEMODES.EMERGENCYSTOP THEN
			StateCtrl := CTRL_EMERGENCYSTOP_BEFORE;
		ELSE
			BetrStatus(set := TRUE,value := CONST.MACHINEMODES.SAFETYSTOP);
			IF axis.ctrl.MC_ReadStatus_0.StandStill THEN 
				axis.ctrl.cmd := CONST.AXIS.POWER_OFF;
			ELSIF axis.ctrl.MC_ReadStatus_0.Disabled THEN
				axis.ctrl.cmd := CONST.AXIS.NOACTION;
				StateCtrl := CTRL_SAFETYSTOP_AFTER;
			END_IF
		END_IF


	CTRL_SAFETYSTOP_AFTER:
		busy := FALSE;
		manualFirst := TRUE;
		status.ready := FALSE;
		IF BetrCtrl.value = CONST.MACHINEMODES.EMERGENCYSTOP THEN
			busy := TRUE;
			StateCtrl := CTRL_EMERGENCYSTOP_BEFORE;
		ELSIF BetrCtrl.value = CONST.MACHINEMODES.MANUAL  AND safety.valid THEN
				IF axis.ctrl.MC_ReadStatus_0.Errorstop THEN
					axis.ctrl(cmd := CONST.AXIS.RESET);
				END_IF
				supplydelay(IN:= TRUE, PT := T#8s);
				IF supplydelay.Q THEN
					axis.ctrl(cmd := CONST.AXIS.POWER_ON);
					(*axis.ctrl(cmd := CONST.AXIS.NOACTION);*)
					busy := TRUE;
					supplydelay(IN:= FALSE);
					StateCtrl := CTRL_MANUAL_BEFORE;
				END_IF
		ELSIF BetrCtrl.value = CONST.MACHINEMODES.AUTOMATIC  AND safety.valid THEN
				IF axis.ctrl.MC_ReadStatus_0.Errorstop THEN
					axis.ctrl(cmd := CONST.AXIS.RESET);
				END_IF
				supplydelay(IN:= TRUE, PT := T#8s);
				IF supplydelay.Q THEN
					axis.ctrl(cmd := CONST.AXIS.POWER_ON);
				(*	axis.ctrl(cmd := CONST.AXIS.NOACTION);*)
					busy := TRUE;
					supplydelay(IN:= FALSE);
					StateCtrl := CTRL_AUTO_BEFORE;
				END_IF
		END_IF

	CTRL_EMERGENCYSTOP_BEFORE:
//		status.isCoupled := FALSE;
//		status.ready := FALSE;
//		axis.ctrl(cmd := CONST.AXIS.POWER_OFF);
//		BetrStatus(set := TRUE, value := CONST.MACHINEMODES.EMERGENCYSTOP);
//		busy := FALSE;
//		StateCtrl := CTRL_EMERGENCYSTOP;
		status.isCoupled := FALSE;
		status.ready := FALSE;
		manualFirst := TRUE;
		BetrStatus(set := TRUE, value := CONST.MACHINEMODES.EMERGENCYSTOP);
		IF  axis.ctrl.MC_ReadStatus_0.ContinuousMotion OR axis.ctrl.MC_ReadStatus_0.DiscreteMotion
			OR axis.ctrl.MC_ReadStatus_0.SynchronizedMotion THEN //alle Zustände in denen die Achse sich bewegen kann
			axis.ctrl.verzoegerung:= CONST.AXIS.EMERGENCY_DECELERATION; (*200m/min in 3 sek*); (* von 200m/min in 2 sek*)
			axis.ctrl.cmd := CONST.AXIS.STOP;
			state := ST_IDLE;
			StateCtrl := CTRL_EMERGENCYSTOP;
		ELSE //wenn die Maschine eingeschaltet wird
			axis.ctrl.cmd := CONST.AXIS.NOACTION;
			state := ST_IDLE;
			StateCtrl := CTRL_EMERGENCYSTOP;
		END_IF
		
	CTRL_EMERGENCYSTOP:
		status.isCoupled := FALSE;
		status.ready := FALSE;
		IF BetrCtrl.value = CONST.MACHINEMODES.EMERGENCYSTOP THEN
			IF axis.ctrl.MC_ReadStatus_0.StandStill THEN 
				axis.ctrl.cmd := CONST.AXIS.POWER_OFF;
				busy := FALSE;
			ELSIF axis.ctrl.MC_ReadStatus_0.Disabled THEN
				axis.ctrl.cmd := CONST.AXIS.NOACTION;
				busy := FALSE;
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



END_FUNCTION_BLOCK