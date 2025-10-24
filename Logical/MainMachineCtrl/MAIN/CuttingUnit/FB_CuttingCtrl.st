(********************************************************************
 * COPYRIGHT -- Microsoft
 ********************************************************************
 * Programm: MAIN
 * Datei: FB_CuttingCtrl.st
 * Autor: Awalz
 * Erstellt: 19. Mai 2014
 ********************************************************************
 * Implementierung des Programms MAIN
 ********************************************************************) 

 (*<$Description$> TODO: Bitte Kommentar hier einzufügen </$Description$>*)
FUNCTION_BLOCK FB_CuttingCtrl
	ac_cyclicCuttingCtrl;
//	getNextUnitSyncPos( uData := data, machineMaster := machineMaster, markpoints := markpoints, 
//						uAxis := axis.ctrl, scalePerimeter := scalePerimeter, setCutOffset :=setCutOffset, CONST :=CONST);
	CASE StateCtrl OF 
	CTRL_FIRST_START:
		busy := TRUE;
		StateCtrl := CTRL_EMERGENCYSTOP_BEFORE;

		
	CTRL_MANUAL_BEFORE:
		IF BetrCtrl.value = CONST.MACHINEMODES.MANUAL THEN
		(*	clamp.init(clk := clk);*)
			BetrStatus(set := TRUE, value := CONST.MACHINEMODES.MANUAL);
			modeCtrl.mode  := data.recipe.mode;
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

	CTRL_MANUAL://11
		IF BetrCtrl.value <> CONST.MACHINEMODES.MANUAL THEN
			err(reset := TRUE);
			busy := TRUE;
			state := ST_IDLE;
			config(cmd := CONST.CUTTINGUNIT.CMDs.NO_CMD, machineMaster := machineMaster, axis := axis, status := status,data := data, 
					IOs := IOs, powerbridge := powerbridge, scalePerimeter := scalePerimeter,markpoints := markpoints, camtable := camtable, 
					getNextUnitSyncPos := getNextUnitSyncPos, setCutOffset := setCutOffset);
			StateCtrl := CTRL_MANUAL_AFTER;
		ELSE
			ac_manualCU;
		END_IF

	CTRL_MANUAL_AFTER://12
			timer(IN:= FALSE);
//			state := ST_IDLE;
			chkStatus.enable := FALSE;
		
/////////////////////////geaendert um die Stanze automatiech zu koppeln
//			config (cmd := CONST.CUTTINGUNIT.CMDs.CPL_ON, machineMaster := machineMaster,axis := axis, status := status, data := data,
//			IOs := IOs, powerbridge := powerbridge, scalePerimeter := scalePerimeter, getNextCuttPos := getNextCuttPos);
		(*	IF NOT config.busy AND NOT  config.copple THEN*)
				ac_setStateAfterPB;
//			END_IF
		
	CTRL_AUTO_BEFORE:
		IF BetrCtrl.value = CONST.MACHINEMODES.AUTOMATIC THEN
		BetrStatus(set := TRUE, value := CONST.MACHINEMODES.AUTOMATIC);
			(*clamp.init(clk := clk);*)
			err(reset := TRUE);
			modeCtrl.mode  := data.recipe.mode;
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
		(*	modeCtrl(machineMaster := machineMaster, axis := axis, data:= data, status := status);*)
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
		axis.ctrl();
		BetrStatus(set := TRUE,value := CONST.MACHINEMODES.RESET);
		modeCtrl.mode  := CONST.CUTTINGUNIT.MODEs.DISABLE;
		IF BetrCtrl.value = CONST.MACHINEMODES.EMERGENCYSTOP THEN
			StateCtrl := CTRL_EMERGENCYSTOP_BEFORE;
		ELSIF BetrCtrl.value = CONST.MACHINEMODES.SAFETYSTOP THEN
			StateCtrl := CTRL_SAFETYSTOP_BEFORE;
		ELSE
			IF axis.ctrl.busy OR axis.ctrl.Cmd <> CONST.AXIS.NOACTION THEN
				axis.ctrl.Cmd := CONST.AXIS.NOACTION;
			ELSE
				axis.ctrl.Cmd := CONST.AXIS.RESET; 
				StateCtrl := CTRL_RESET;
			END_IF
		END_IF

	CTRL_RESET:
		axis.ctrl();
		(*axis.ctrl(cmd := CONST.AXIS.RESET);**********************)
		IF BetrCtrl.value = CONST.MACHINEMODES.EMERGENCYSTOP THEN
			StateCtrl := CTRL_EMERGENCYSTOP_BEFORE;
		ELSIF BetrCtrl.value = CONST.MACHINEMODES.SAFETYSTOP THEN
			StateCtrl := CTRL_SAFETYSTOP_BEFORE;
		ELSE
			(*IF NOT axis.ctrl.busy THEN*)
				modeCtrl.mode  := CONST.CUTTINGUNIT.MODEs.DISABLE;
				axis.ctrl.Cmd := CONST.AXIS.POWER_OFF;
			(*	axis.ctrl(cmd := CONST.AXIS.POWER_ON);(******************************)
				StateCtrl := CTRL_RESET_AFTER;
			(*END_IF*)
		END_IF

	CTRL_RESET_AFTER://77
		axis.ctrl();
		IF BetrCtrl.value = CONST.MACHINEMODES.RESET THEN
			busy := FALSE;
		ELSE
			busy := TRUE;
		(*	clamp.init(clk := clk);*)
			err(reset := TRUE);
			IF BetrCtrl.value = CONST.MACHINEMODES.EMERGENCYSTOP THEN
				StateCtrl := CTRL_EMERGENCYSTOP_BEFORE;
			ELSIF BetrCtrl.value = CONST.MACHINEMODES.SAFETYSTOP THEN
				StateCtrl := CTRL_SAFETYSTOP_BEFORE;
			ELSIF BetrCtrl.value = CONST.MACHINEMODES.SAFETYSTOP THEN
				StateCtrl := CTRL_SAFETYSTOP_BEFORE;
			ELSIF BetrCtrl.value = CONST.MACHINEMODES.MANUAL THEN
			(*	modeCtrl.mode  := data.recipe.mode;*)
				supplydelay(IN:= TRUE, PT := T#8s);
				IF supplydelay.Q THEN
					axis.ctrl.Cmd := CONST.AXIS.POWER_ON;
					busy := TRUE;
					supplydelay(IN:= FALSE);
					StateCtrl := CTRL_MANUAL_BEFORE;
				END_IF
			ELSIF BetrCtrl.value = CONST.MACHINEMODES.AUTOMATIC THEN
				(*modeCtrl.mode  := data.recipe.mode;*)
				supplydelay(IN:= TRUE, PT := T#8s);
				IF supplydelay.Q THEN
					axis.ctrl.Cmd := CONST.AXIS.POWER_ON;
					busy := TRUE;
					supplydelay(IN:= FALSE);
					StateCtrl := CTRL_AUTO_BEFORE;
				END_IF
			END_IF
		END_IF

	CTRL_SAFETYSTOP_BEFORE://82
			modeCtrl.mode  := CONST.CUTTINGUNIT.MODEs.DISABLE;
		IF BetrCtrl.value = CONST.MACHINEMODES.EMERGENCYSTOP THEN
			StateCtrl := CTRL_EMERGENCYSTOP_BEFORE;
		ELSE
			BetrStatus(set := TRUE,value := CONST.MACHINEMODES.SAFETYSTOP);
			state := ST_IDLE;
			axis.ctrl.Deceleration:= CONST.AXIS.EMERGENCY_DECELERATION;//11.03.15 1111111; (*200m/min in 3 sek*)
			axis.ctrl.Cmd := CONST.AXIS.STOP;
			StateCtrl := CTRL_SAFETYSTOP;
		END_IF

	CTRL_SAFETYSTOP://85
		status.isCalibrated := FALSE; // 14.01.16 OKrebs
		IF BetrCtrl.value = CONST.MACHINEMODES.EMERGENCYSTOP THEN
			StateCtrl := CTRL_EMERGENCYSTOP_BEFORE;
		ELSE
			//12.03.15
			BetrStatus(set := TRUE,value := CONST.MACHINEMODES.SAFETYSTOP);
			IF axis.ctrl.MC_ReadStatus_0.StandStill THEN 
				axis.ctrl.Cmd := CONST.AXIS.POWER_OFF;
			ELSIF axis.ctrl.MC_ReadStatus_0.Disabled OR 
					axis.ctrl.MC_ReadStatus_0.Errorstop OR  axis.ctrl.MC_ReadStatus_0.Error  THEN
				axis.ctrl.Cmd := CONST.AXIS.NOACTION;
				StateCtrl := CTRL_SAFETYSTOP_AFTER;
			END_IF
		END_IF

	CTRL_SAFETYSTOP_AFTER:
		busy := FALSE;
		manualFirst := TRUE;
		IF BetrCtrl.value = CONST.MACHINEMODES.EMERGENCYSTOP THEN
			busy := TRUE;
			StateCtrl := CTRL_EMERGENCYSTOP_BEFORE;
			(*modeCtrl.mode  := data.recipe.mode;*)
		ELSIF BetrCtrl.value = CONST.MACHINEMODES.MANUAL THEN
			modeCtrl.mode  := data.recipe.mode;
			supplydelay(IN:= TRUE, PT := T#8s);
			IF supplydelay.Q THEN
				axis.ctrl.Cmd := CONST.AXIS.POWER_ON;
				busy := TRUE;
				supplydelay(IN:= FALSE);
				StateCtrl := CTRL_MANUAL_BEFORE;
			END_IF

		ELSIF BetrCtrl.value = CONST.MACHINEMODES.AUTOMATIC THEN
		(*	modeCtrl.mode  := data.recipe.mode;*)
			supplydelay(IN:= TRUE, PT := T#8s);
			IF supplydelay.Q THEN
				axis.ctrl.Cmd := CONST.AXIS.POWER_ON;
				busy := TRUE;
				supplydelay(IN:= FALSE);
				StateCtrl := CTRL_AUTO_BEFORE;
			END_IF
		END_IF

	CTRL_EMERGENCYSTOP_BEFORE:
			modeCtrl.mode  := CONST.CUTTINGUNIT.MODEs.DISABLE;
		status.isCoupled := FALSE;
		IF axis.ctrl.MC_ReadStatus_0.ContinuousMotion OR axis.ctrl.MC_ReadStatus_0.DiscreteMotion 
			OR axis.ctrl.MC_ReadStatus_0.SynchronizedMotion OR axis.ctrl.MC_ReadStatus_0.Homing THEN 
			axis.ctrl.Deceleration := CONST.AXIS.EMERGENCY_DECELERATION; (*1666666;*) (*200m/min in 2 sek*)
			axis.ctrl.Cmd := CONST.AXIS.STOP;
			BetrStatus(set := TRUE, value := CONST.MACHINEMODES.EMERGENCYSTOP);
			StateCtrl := CTRL_EMERGENCYSTOP;
		ELSE 
			axis.ctrl.Cmd := CONST.AXIS.NOACTION;
			BetrStatus(set := TRUE, value := CONST.MACHINEMODES.EMERGENCYSTOP);
			StateCtrl := CTRL_EMERGENCYSTOP;
		END_IF

	CTRL_EMERGENCYSTOP://92
		status.isCalibrated := FALSE; // 14.01.16 OKrebs
		IF BetrCtrl.value = CONST.MACHINEMODES.EMERGENCYSTOP THEN
			IF axis.ctrl.MC_ReadStatus_0.StandStill THEN 
				axis.ctrl.Cmd := CONST.AXIS.POWER_OFF;
			ELSIF axis.ctrl.MC_ReadStatus_0.Disabled OR
					axis.ctrl.MC_ReadStatus_0.Errorstop OR  axis.ctrl.MC_ReadStatus_0.Error THEN
				axis.ctrl.Cmd := CONST.AXIS.NOACTION;
			END_IF
		ELSE
			busy := TRUE;
			timer(IN := TRUE, PT := T#2s);
			StateCtrl := CTRL_EMERGENCYSTOP_AFTER;
		END_IF

	CTRL_EMERGENCYSTOP_AFTER://93
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
//	axis.ctrl.BasicControl.Parameter.Deceleration	:= 90000.0; //only for initialization
//	axis.ctrl.BasicControl.Parameter.Acceleration	:= 90000.0;

END_FUNCTION_BLOCK