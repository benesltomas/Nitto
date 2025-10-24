(********************************************************************
 * COPYRIGHT -- Microsoft
 ********************************************************************
 * Programm: MAIN
 * Datei: acmanualLongCut.st
 * Autor: awalz
 * Erstellt: 30. Juni 2014
 ********************************************************************
 * Implementierung des Programms MAIN
 ********************************************************************) 

(* Fügt eine neue Aktion zum IEC Programm oder Bibliothek *)
ACTION ac_manualLongCut:
		axis.ctrl();
		config( machineMasterCtrl := machineMaster, axis := axis, status := status);
	CASE state OF
	ST_IDLE:
		IF config.busy OR config.cmd <> CONST.CUTTINGUNIT.CMDs.NO_CMD THEN
			config(cmd := CONST.CUTTINGUNIT.CMDs.NO_CMD, machineMasterCtrl := machineMaster, axis := axis, status := status);
		ELSIF manualFirst  OR mode <> status.mode (*OR NewData *)THEN
			IF NOT status.isCoupled AND mode = CONST.UNITMODEs.ENABLE (*AND axis.ctrl.MC_ReadStatus_0.Disabled *)THEN
				axis.ctrl(cmd:= CONST.AXIS.POWER_ON);
				IF axis.ctrl.MC_ReadStatus_0.StandStill THEN
					status(mode := mode,axisState := axis.ctrl.MC_ReadStatus_0 );
					config(cmd := CONST.CUTTINGUNIT.CMDs.CPL_ON, machineMasterCtrl := machineMaster, axis := axis, status := status);
					state := ST_CPL_WAIT;
				END_IF
			ELSIF mode = CONST.UNITMODEs.DISABLE AND status.isCoupled THEN
				status(mode := mode,axisState := axis.ctrl.MC_ReadStatus_0 );
				config(cmd := CONST.CUTTINGUNIT.CMDs.CPL_OFF, machineMasterCtrl := machineMaster, axis := axis, status := status);
				state := ST_CPL_WAIT;
//			ELSIF	mode = CONST.UNITMODEs.AXIS_OFF THEN
//				status(mode := mode,axisState := axis.ctrl.MC_ReadStatus_0 );
//				axis.ctrl(cmd:= CONST.AXIS.POWER_OFF);
//				status.isCoupled := FALSE;
//				state := ST_AXIS_OFF;
//			ELSIF	mode = CONST.UNITMODEs.DISABLE AND axis.ctrl.MC_ReadStatus_0.Disabled THEN
//				status(mode := mode,axisState := axis.ctrl.MC_ReadStatus_0 );
//				status.isCoupled := FALSE;
//				axis.ctrl(cmd:= CONST.AXIS.POWER_ON);
//				state := ST_AXIS_ON;
////////////////////////
			ELSIF cmdCtrl.value = CONST.CUTTINGUNIT.CMDs.MOVEFW (*OR cmdCtrl.value = CONST.CUTTINGUNIT.CMDs.MOVEBW*) THEN
				cmdStatus(set := TRUE, value := cmdCtrl.value);
				busy := TRUE;
				state := ST_MOVE_START;
//////////////////////////					
			ELSE
				NewData := FALSE;
				manualFirst := FALSE;
			END_IF
		ELSIF cmdCtrl.value <> CONST.CUTTINGUNIT.CMDs.NO_CMD THEN
			cmdStatus(set := TRUE, value := cmdCtrl.value);
			busy := TRUE;
			state := ST_FUNCTION_START;
		END_IF

	ST_CPL_WAIT:
		config( machineMasterCtrl := machineMaster, axis := axis, status := status);
		(*status(mode := mode);*)
		IF NOT config.busy THEN
			IF config.err.flag THEN
				err := config.err;
				err.state := state;
				state := ST_ERROR;
			ELSE
				manualFirst := FALSE;
				axis.setGearRatio.init := TRUE;  // OKrebs 09.12.15
				state := ST_IDLE;
			END_IF
			config(cmd := CONST.CUTTINGUNIT.CMDs.NO_CMD, machineMasterCtrl := machineMaster, axis := axis, status := status );
		END_IF

	ST_FUNCTION_START:
		IF config.busy OR config.cmd <> CONST.CUTTINGUNIT.CMDs.NO_CMD THEN
			config(cmd := CONST.CUTTINGUNIT.CMDs.NO_CMD, machineMasterCtrl := machineMaster, axis := axis, status := status);
		ELSE
			config(cmd := cmdStatus.value, machineMasterCtrl := machineMaster, axis := axis, status := status);
			state := ST_FUNCTION;
		END_IF

	ST_FUNCTION:
		config( machineMasterCtrl := machineMaster, axis := axis, status := status);
		IF NOT config.busy THEN
			IF config.err.flag THEN
				err := config.err;
				err.state := state;
			END_IF
			config(cmd := CONST.CUTTINGUNIT.CMDs.NO_CMD, machineMasterCtrl := machineMaster, axis := axis, status := status );
			state := ST_FUNCTION_QUIT;
		END_IF
////12.08.14/////	
	ST_MOVE_START:
			config(cmd := cmdStatus.value, machineMasterCtrl  := machineMaster, axis := axis, status := status);
			state := ST_MOVE;

	ST_MOVE:
//		config (machineMaster := machineMaster, axis := axis, status := status, data := data, IOs := IOs, powerbridge := powerbridge, 
//				scalePerimeter := scalePerimeter, getNextCuttPos := getNextCuttPos);
		IF cmdCtrl.value = CONST.CUTTINGUNIT.CMDs.NO_CMD THEN
			config(cmd := CONST.CUTTINGUNIT.CMDs.NO_CMD, machineMasterCtrl := machineMaster, axis := axis, status := status);
			state := ST_MOVE_QUIT;
			
		ELSE
			config(cmd := cmdStatus.value, machineMasterCtrl := machineMaster, axis := axis, status := status);
		END_IF
		
	ST_MOVE_QUIT:
		config(cmd := CONST.CUTTINGUNIT.CMDs.NO_CMD, machineMasterCtrl := machineMaster, axis := axis, status := status);
		IF NOT config.busy THEN
			busy := FALSE;
			cmdStatus(set := TRUE, value := CONST.CUTTINGUNIT.CMDs.NO_CMD);
			state := ST_IDLE;
		END_IF

////////////////////////////////
	ST_AXIS_OFF:
	(*	status(mode := mode);*)
		IF mode <> CONST.UNITMODEs.AXIS_OFF THEN
			state := ST_IDLE;
		END_IF
	ST_AXIS_ON:
	(*	status(mode := mode);*)
		IF mode <> CONST.UNITMODEs.DISABLE THEN
			state := ST_IDLE;
		END_IF

	ST_FUNCTION_QUIT:
		busy := FALSE;
		IF cmdCtrl.value = CONST.CUTTINGUNIT.CMDs.NO_CMD THEN
			cmdStatus(set :=TRUE, value := CONST.CUTTINGUNIT.CMDs.NO_CMD);
			state := ST_IDLE;
		END_IF

	ST_ERROR:
		err.flag := TRUE;
		busy := FALSE;
		IF BetrCtrl.value <> CONST.MACHINEMODES.MANUAL THEN
			state := ST_IDLE;
			err(reset := TRUE);
			busy := TRUE;
			StateCtrl := CTRL_MANUAL_AFTER;
		END_IF
	END_CASE

	(*axis.calcGearRatio(enable := ( data.torqueCtrlOn  AND axis.ctrl.ref.Status.Coupled), axisRef := axis.ctrl.ref, zugRegelWert := zugRegelWert);*) 
END_ACTION