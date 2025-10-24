(********************************************************************
 * COPYRIGHT -- Microsoft
 ********************************************************************
 * Programm: MAIN
 * Datei: FB_LongcutterCtrl.st
 * Autor: awalz
 * Erstellt: 29. Juni 2014
 ********************************************************************
 * Implementierung des Programms MAIN
 ********************************************************************) 

(* TODO: Bitte Kommentar hier einfügen *)
FUNCTION_BLOCK FB_LongcutterCtrl
	axis.ctrl();
	cutterUp(clk := clk, );(*cutterUp.enable wird dierekt vom EIngang 202A3Input6 geschaltet*)
	discmovesupp(clk := clk); 
	movebutton(clk := clk);
	webclamp(clk := clk);
	status(axisState := axis.ctrl.MC_ReadStatus_0);
	status.ready := axis.ctrl.MC_ReadStatus_0.SynchronizedMotion;
	emcy_inputs();
	IF emcy_inputs.EMCY_Door1 THEN 
		emcy_inputs.EMCY_DoorsClosed := TRUE;
	ELSE 
		emcy_inputs.EMCY_DoorsClosed := FALSE;
	
	END_IF
	chkStatus(setMode := mode, status := status);
	axis.setGearRatio(limitvisuneg := -20, limitvisupos := 50, limitrationeg := 800, limitratiopos := 1500);
	IF machineMaster.MC_ReadStatus_0.ContinuousMotion THEN
		discmovesupp.toDown_o := FALSE;	
	END_IF
//	IF axis.ctrl.MC_ReadStatus_0.SynchronizedMotion AND axis.setGearRatio.enable THEN 
//	
//		
//	END_IF
	axis.cplOn.Execute := axis.setGearRatio.trigger OR movebutton.LDT.ftrig.Q OR axisCpl; // 25.07.18 // OKrebs

	axis.cplOn(RatioNumerator := axis.setGearRatio.ratioNumeratorOut,
				(*Execute := axis.setGearRatio.trigger, 25.07.18 OKrebs*) RatioDenominator := axis.setGearRatio.ratioDenominator,
					Acceleration := 40000, Deceleration := 40000);
	
//	IF  movebutton.LDT.ftrig.Q THEN	// 25.07.18 // OKrebs
//		axis.cplOn.Execute := TRUE; // 25.07.18 // OKrebs
//	END_IF							// 25.07.18 // OKrebs

////12.08.14 jog set commando  for Longcutter 
	IF movebutton.LDT.button THEN 
		cmdCtrl.value := CONST.CUTTINGUNIT.CMDs.MOVEFW;
	ELSIF movebutton.LDT.ftrig.Q THEN ////12.08.14 jog reset commando  for Longcutter 
		cmdCtrl.value := CONST.CUTTINGUNIT.CMDs.NO_CMD;
	END_IF
////21.08.14 Um Achse zu reseten//
	IF cmdCtrl.value = CONST.CUTTINGUNIT.CMDs.RESET THEN
		axis.ctrl.cmd := CONST.AXIS.RESET;
	ELSIF cmdCtrl.value = CONST.CUTTINGUNIT.CMDs.NO_CMD THEN
		axis.ctrl.cmd := CONST.AXIS.NOACTION;
	END_IF
	status.axiserror := axis.ctrl.MC_ReadStatus_0.Errorstop;
	IF	mode = CONST.UNITMODEs.AXIS_OFF OR  NOT emcy_inputs.EMCY_Door1 THEN
				status(mode := mode,axisState := axis.ctrl.MC_ReadStatus_0 );
				axis.ctrl(cmd:= CONST.AXIS.POWER_OFF);
				status.isCoupled := FALSE;
				state := ST_AXIS_OFF;
	ELSIF	mode = CONST.UNITMODEs.ENABLE AND axis.ctrl.MC_ReadStatus_0.Disabled AND  emcy_inputs.EMCY_Door1 THEN
				status(mode := mode,axisState := axis.ctrl.MC_ReadStatus_0 );
				status.isCoupled := FALSE;
				axis.ctrl(cmd:= CONST.AXIS.POWER_ON);
				stateCPL := cpl_idle;
	ELSIF	mode = CONST.UNITMODEs.DISABLE AND NOT axis.ctrl.MC_ReadStatus_0.Disabled AND  emcy_inputs.EMCY_Door1 THEN
				status(mode := mode,axisState := axis.ctrl.MC_ReadStatus_0 );
				status.isCoupled := FALSE;
				axis.ctrl(cmd:= CONST.AXIS.POWER_ON);
				state := ST_AXIS_ON;
	END_IF
//////////////////////
	CASE stateCPL OF
		cpl_idle :
			IF axis.ctrl.MC_ReadStatus_0.StandStill THEN
				axisCpl := TRUE;
//				axis.cplOn.Execute := TRUE; // 25.07.18 // OKrebs
				stateCPL := clp_cpl;
			END_IF
		clp_cpl:
			axisCpl := FALSE;
				;
		END_CASE
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
			manualFirst := TRUE;
			StateCtrl := CTRL_MANUAL;
//			axis.setGearRatio.init := TRUE;
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

			(*	END_IF*)
		ELSE 
			ac_manualLongCut; 
		END_IF

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
//			cutterUp.buttomToggle.LDT.button := TRUE;
//			cutterUp(clk := clk );
			axis.ctrl(cmd := CONST.AXIS.POWER_OFF);
			StateCtrl := CTRL_RESET_AFTER;
		END_IF

	CTRL_RESET_AFTER:
		IF BetrCtrl.value = CONST.MACHINEMODES.RESET THEN
			busy := FALSE;
		ELSE
			busy := TRUE;
			cutterUp(clk := clk, init := TRUE);
			err(reset := TRUE);
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
		IF axis.ctrl.MC_ReadStatus_0.Errorstop THEN
			axis.ctrl.cmd := CONST.AXIS.RESET;
		END_IF		
		IF BetrCtrl.value = CONST.MACHINEMODES.EMERGENCYSTOP THEN
			busy := TRUE;
			StateCtrl := CTRL_EMERGENCYSTOP_BEFORE;
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

	CTRL_EMERGENCYSTOP_BEFORE:
		status.isCoupled := FALSE;
		status.ready := FALSE;
		cutterUp(clk := clk, init := TRUE);
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
	axis.ctrl.BasicControl.Parameter.Deceleration	:= 40000.0; //only for initialization
	axis.ctrl.BasicControl.Parameter.Acceleration	:= 40000.0;
END_FUNCTION_BLOCK